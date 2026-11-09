import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Drawer: a bar button that opens a strip holding the bar widgets listed in
// this entry's `items` in ~/.config/omarchy/shell.json, e.g.
//
//   { "id": "parker.drawer",
//     "items": [ "omarchy.weather", { "id": "omarchy.clock", "format": "HH:mm" } ] }
//
// Items are plain widget ids or full layout entries (id + inline settings),
// so an entry can be moved from bar.layout into the drawer unchanged.
//
// Hosted widgets are loaded from their plugin's barWidget entry point and get
// `hostBar`, a stand-in for the bar that forwards to this widget's own bar
// facade except for popouts (coordinated inside the drawer, so opening a
// hosted panel does not close the drawer), tooltips (drawn here, since the
// bar only draws tooltips for its own window) and settings writes (stored
// back into this entry's `items`).
BarWidget {
  id: root

  // ---- configuration -------------------------------------------------------

  readonly property var items: normalizeItems(setting("items", []))
  readonly property string closedIcon: String(setting("icon", "󰅀"))
  readonly property string openIcon: String(setting("iconOpen", "󰅃"))
  readonly property string tooltip: String(setting("tooltip", "Drawer"))

  readonly property string omarchyPath: Quickshell.env("OMARCHY_PATH") || "/usr/share/omarchy"
  readonly property string home: Quickshell.env("HOME") || ""

  // id -> file URL of that plugin's barWidget entry point.
  property var widgetUrls: ({})
  property bool resolved: false
  // Ids in display order. Only reassigned when the id list really changes,
  // so a settings-only change (e.g. a hosted clock saving its format) updates
  // the hosted widget in place instead of rebuilding every widget.
  property var itemIds: []

  // ---- popout state ---------------------------------------------------------

  property bool drawerOpen: false
  // Popout owner of whichever hosted widget has its panel open, if any.
  property var hostedPopout: null

  // Shape the bar's popout coordinator and `omarchy-shell shell toggle
  // parker.drawer` look for: open / close / opened on the widget root.
  readonly property bool opened: drawerOpen
  readonly property bool popoutSwitchClosing: false

  readonly property var barWindow: button.QsWindow.window

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function normalizeItems(raw) {
    var out = []
    if (!Array.isArray(raw)) return out
    for (var i = 0; i < raw.length; i++) {
      var it = raw[i]
      if (typeof it === "string" && it.trim() !== "") out.push({ id: it.trim() })
      else if (it && typeof it === "object" && !Array.isArray(it) && typeof it.id === "string" && it.id !== "") out.push(it)
    }
    return out
  }

  function entrySettings(entry) {
    var copy = {}
    for (var key in entry) if (key !== "id") copy[key] = entry[key]
    return copy
  }

  function syncItemIds() {
    var ids = items.map(function(e) { return e.id })
    if (JSON.stringify(ids) !== JSON.stringify(itemIds)) itemIds = ids
    // A newly listed id may belong to a plugin installed since the last scan.
    for (var i = 0; i < ids.length; i++) {
      if (resolved && !widgetUrls[ids[i]] && !resolver.running) { resolver.running = true; break }
    }
  }

  onItemsChanged: syncItemIds()
  Component.onCompleted: {
    syncItemIds()
    resolver.running = true
  }

  // ---- open / close -------------------------------------------------------

  function open() {
    if (drawerOpen) return
    drawerOpen = true
    if (bar) bar.requestPopout(root)
  }

  function close() {
    closeHosted()
    tooltipState.clear()
    if (!drawerOpen) return
    drawerOpen = false
    if (bar && bar.activePopout === root) bar.releasePopout(root)
  }

  function closeForPopoutSwitch() { close() }
  function toggle() { drawerOpen ? close() : open() }

  function closeHosted() {
    var owner = hostedPopout
    if (!owner) return
    if ("close" in owner) owner.close()
    if (hostedPopout === owner) hostedPopout = null
  }

  // Mirrors Bar.requestPopout, scoped to the widgets in this drawer.
  function requestHostedPopout(owner) {
    if (!owner || hostedPopout === owner) return
    if (!drawerOpen) open()
    var previous = hostedPopout
    if (previous) {
      if ("closeForPopoutSwitch" in previous) previous.closeForPopoutSwitch()
      else if ("close" in previous) previous.close()
    }
    hostedPopout = owner
  }

  function releaseHostedPopout(owner) {
    if (hostedPopout === owner) hostedPopout = null
  }

  function hostedWidgets(id) {
    var win = windowLoader.item
    return win && win.content ? win.content.hostedWidgets(id) : []
  }

  // Left/right in a hosted panel moves to the next hosted widget with a panel.
  function switchHostedPanel(owner, direction) {
    var panels = hostedWidgets("").filter(function(w) {
      return w.visible && typeof w.open === "function" && typeof w.close === "function" && w.opened !== undefined
    })
    var index = panels.indexOf(owner)
    if (index < 0 || panels.length < 2) return false
    var next = panels[(index + (direction < 0 ? -1 : 1) + panels.length) % panels.length]
    next.open()
    return true
  }

  // Store a hosted widget's settings back into this entry's `items`.
  function updateItemSettings(id, settings) {
    if (!bar || !bar.shell || typeof bar.shell.updateEntryInline !== "function") return false
    var mine = entrySettings(root.settings || {})
    var list = Array.isArray(mine.items) ? mine.items.slice() : []
    for (var i = 0; i < list.length; i++) {
      var current = list[i]
      var currentId = typeof current === "string" ? current : (current && current.id)
      if (currentId !== id) continue
      var next = { id: id }
      for (var key in settings) if (key !== "id") next[key] = settings[key]
      list[i] = next
      mine.items = list
      return bar.shell.updateEntryInline(root.moduleName, mine)
    }
    return false
  }

  // Another bar panel taking over calls close() through the bar's popout
  // coordinator. (Watching activePopout instead would race: the bar briefly
  // clears it while handing over to this drawer.)
  onBarChanged: if (!bar) close()

  // ---- widget id -> entry point --------------------------------------------

  // Read every bar-widget manifest: stock plugins first, then the user's own
  // plugins, so a clone (or a third-party widget) wins on an id clash.
  Process {
    id: resolver
    command: ["bash", "-c", `
      shopt -s nullglob
      for f in "$1"/shell/plugins/*/manifest.json "$1"/shell/plugins/*/*/manifest.json \\
               "$1"/shell/plugins/*/*.manifest.json "$1"/shell/plugins/*/*/*.manifest.json \\
               "$2"/.config/omarchy/plugins/*/manifest.json; do
        jq -r --arg d "\${f%/*}" '
          select(((.kinds // []) | index("bar-widget")) and ((.entryPoints.barWidget // null) | type) == "string")
          | [.id, $d + "/" + .entryPoints.barWidget] | @tsv' "$f" 2>/dev/null
      done
    `, "drawer-resolve", root.omarchyPath, root.home]
    stdout: StdioCollector {
      onStreamFinished: {
        var map = {}
        var lines = String(text || "").split("\n")
        for (var i = 0; i < lines.length; i++) {
          var parts = lines[i].split("\t")
          if (parts.length !== 2 || !parts[0] || parts[1].indexOf("/") !== 0) continue
          map[parts[0]] = "file://" + parts[1]
        }
        root.widgetUrls = map
        root.resolved = true
      }
    }
  }

  // ---- the bar button -------------------------------------------------------

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.drawerOpen ? root.openIcon : root.closedIcon
    slotSize: Style.bar.statusSlot
    tooltipText: root.drawerOpen ? "" : root.tooltip
    onPressed: function(b) {
      if (b === Qt.LeftButton || b === Qt.MiddleButton) root.toggle()
    }
  }

  // ---- what hosted widgets see as their bar ------------------------------

  QtObject {
    id: hostShell

    readonly property var barConfig: root.bar && root.bar.shell ? root.bar.shell.barConfig : ({})
    readonly property var bar: root.bar && root.bar.shell ? root.bar.shell.bar : null

    function serviceFor(id) { return root.bar && root.bar.shell ? root.bar.shell.serviceFor(id) : null }
    function firstPartyServiceFor(id) {
      return root.bar && root.bar.shell && typeof root.bar.shell.firstPartyServiceFor === "function"
        ? root.bar.shell.firstPartyServiceFor(id) : null
    }
    function summon(id, payload) { return root.bar && root.bar.shell ? root.bar.shell.summon(id, payload) : false }
    function hide(id) { return root.bar && root.bar.shell ? root.bar.shell.hide(id) : false }
    function toggle(id, payload) { return root.bar && root.bar.shell ? root.bar.shell.toggle(id, payload) : false }
    function isPluginOpen(id) { return root.bar && root.bar.shell ? root.bar.shell.isPluginOpen(id) : false }
    function updateEntryInline(id, settings) { return root.updateItemSettings(String(id || ""), settings || {}) }
    function mutateShellConfig(mutator) { return false }
  }

  QtObject {
    id: hostBar

    readonly property color foreground: root.bar ? root.bar.foreground : Color.foreground
    readonly property color barForeground: foreground
    readonly property color background: Color.popups.background
    readonly property color urgent: root.bar ? root.bar.urgent : Color.urgent
    readonly property string fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
    readonly property string position: root.bar ? root.bar.position : "top"
    readonly property bool vertical: root.bar ? root.bar.vertical : false
    readonly property int barSize: root.bar ? root.bar.barSize : Style.bar.sizeHorizontal
    readonly property bool transparent: false
    readonly property bool foregroundAnimationEnabled: true
    readonly property bool centerSectionRevealHeld: true
    readonly property bool centerHoverRevealSuppressed: false
    readonly property var activePopout: root.hostedPopout
    readonly property var clickTargets: root.bar ? root.bar.clickTargets : []
    readonly property var layoutConfig: root.bar ? root.bar.layoutConfig : ({})
    readonly property var shell: hostShell

    function run(command) { if (root.bar) root.bar.run(command) }
    function shellQuote(value) { return "'" + String(value).replace(/'/g, "'\\''") + "'" }
    function showTooltip(target, text) { tooltipState.show(target, text) }
    function hideTooltip(target) { tooltipState.hide(target) }
    function registerClickTarget(target) { if (root.bar) root.bar.registerClickTarget(target) }
    function unregisterClickTarget(target) { if (root.bar) root.bar.unregisterClickTarget(target) }
    function requestPopout(owner) { root.requestHostedPopout(owner) }
    function releasePopout(owner) { root.releaseHostedPopout(owner) }
    function switchPanelFrom(owner, direction) { return root.switchHostedPanel(owner, direction) }
    function targetBelongsToWindow(target, window) {
      return root.bar ? root.bar.targetBelongsToWindow(target, window) : false
    }
    function moduleWidgets(id) { return root.hostedWidgets(String(id || "")) }
    function setCenterHoverRevealSuppressed(value) {}
  }

  QtObject {
    id: tooltipState

    property var target: null
    property string text: ""
    property bool shown: false

    function show(t, s) {
      clear()
      if (!t || !s) return
      target = t
      text = String(s)
      tooltipTimer.restart()
    }
    function hide(t) { if (target === t) clear() }
    function clear() {
      tooltipTimer.stop()
      shown = false
      target = null
      text = ""
    }
  }

  Timer {
    id: tooltipTimer
    interval: 400
    onTriggered: tooltipState.shown = !!tooltipState.target && tooltipState.target.tooltipHovered === true
  }

  // ---- the drawer surface -------------------------------------------------

  // Created on first open, then kept: hosted widgets keep their state (and
  // their background refreshes) between opens, and a desktop without a
  // layer-shell backend still gets a working bar button.
  property bool everOpened: false
  onDrawerOpenChanged: if (drawerOpen) everOpened = true

  // Only the drawer itself refers to these; DrawerWindow reads them here.
  readonly property QtObject hostBarApi: hostBar
  readonly property QtObject tooltipModel: tooltipState
  readonly property Item anchorButton: button

  LazyLoader {
    id: windowLoader
    active: root.everOpened

    // Loaded by URL, not by type name: a layer-shell window type is resolved
    // only here, on first open, never while the bar widget itself loads.
    // (LazyLoader compiles its source as soon as it is set, active or not.)
    source: root.everOpened ? Qt.resolvedUrl("DrawerWindow.qml") : ""
    onItemChanged: if (item) item.drawer = root
  }
}
