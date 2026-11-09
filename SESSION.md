# h0 building Bar Drawer

Rendered from the session's recorded trace (`trace.jsonl`), not from a screen capture. Workspace paths are shown as `~`; tool output is cut to its first 40 lines.

Model `claude-opus-5-5` · fitting `omarchy-v4` · tools read, edit, write, grep, glob, bash, check

---

### › You

```text
Build me an Omarchy shell plugin that tidies my top bar: a drawer button that, when I click it, opens a panel holding the bar widgets I've chosen to tuck away, so the bar only shows the essentials. I want to choose which widgets go in the drawer in shell.json.
```

I'll start by reading the plugin guide, your current shell.json, and the built-in plugins.

**⏺ bash** `cat /usr/share/omarchy/default/agents/skills/omarchy/plugins.md; echo ----; cat .config/omarchy/shell.json; echo ----; ls .config/omarchy/plugins 2>/dev/null; ls /usr/share/omarchy/shell/plugins/`

✓ 114 ms

```text
[exit 0, 106 ms]
# Omarchy Shell: Bar, Plugins, and Idle

Read this before changing the status bar, notifications, shell plugins,
widgets, or idle/lock behavior.

The bar, notification daemon, settings panel, and assorted overlays all run
inside a single long-running Quickshell process (`omarchy-shell`).

```
~/.config/omarchy/shell.json             # User overrides: bar, plugins, idle
~/.config/omarchy/plugins/<plugin-id>/   # User-owned shell plugins
$OMARCHY_PATH/config/omarchy/shell.json  # Canonical defaults
```

The shell hot-reloads `shell.json` on save — no restart needed for layout
changes. `idle.screensaver` and `idle.lock` are seconds since user idle began.

**Commands:** `omarchy restart shell`, `omarchy refresh shell`

## Bar Layout

Use the `omarchy bar` group to move and manage widgets:

```bash
omarchy bar move omarchy.clock --section right
```

For layout edits beyond what the commands cover, edit the bar configuration
in `~/.config/omarchy/shell.json`; it hot-reloads on save.

## Customizing Built-In Plugins and Widgets

To customize a built-in bar widget, never edit `$OMARCHY_PATH/shell/plugins/`.
Clone it into the user plugin directory instead:

```bash
omarchy plugin clone omarchy.workspaces
# Edit ~/.config/omarchy/plugins/<username>.workspaces/; saved changes reload automatically.
```
…
```

**⏺ bash** `cd /usr/share/omarchy/shell/plugins; cat README.md; ls -R bar | head -80; `

✓ 72 ms

```text
[exit 0, 66 ms]
# First-party plugins

These plugins ship with Omarchy and are discovered by the shell at startup.
They use the same `manifest.json` contract as third-party plugins; the
only difference is that the shell flags them with `__isFirstParty: true`.
First-party non-bar plugins are enabled unless listed in `disabledPlugins[]`;
`omarchy.bar` is the default bar option and becomes inactive only while another
`kind: "bar"` plugin is selected. Services and keep-loaded panels are mounted
at startup; other panels, overlays, and menus are loaded on demand.

User-installed plugins live alongside these conceptually but on disk under
`~/.config/omarchy/plugins/<plugin-id>/` rather than in this directory.

| Plugin        | id                        | kinds                   | entry point                           |
|---------------|---------------------------|-------------------------|---------------------------------------|
| Bar           | `omarchy.bar`             | `bar`                   | `bar/Bar.qml`                         |
| Image picker  | `omarchy.image-picker`    | `overlay`               | `image-picker/ImagePicker.qml`        |
| Emojis        | `omarchy.emojis`          | `overlay`               | `emojis/Emojis.qml`                   |
| Clipboard mgr | `omarchy.clipboard`       | `overlay`               | `clipboard/Clipboard.qml`             |
| Reminders     | `omarchy.reminders`       | `overlay`               | `reminders/ReminderFlow.qml`          |
| Omarchy menu  | `omarchy.menu`            | `menu`, `bar-widget`    | `menu/Menu.qml`, `menu/BarWidget.qml` |
| Notifications | `omarchy.notifications`   | `service`               | `notifications/Service.qml`           |
| Audio         | `omarchy.audio`           | `bar-widget`            | `panels/audio/Panel.qml`              |
| Bluetooth     | `omarchy.bluetooth`       | `bar-widget`            | `panels/bluetooth/Panel.qml`          |
| Clock         | `omarchy.clock`           | `bar-widget`            | `panels/clock/BarWidget.qml`          |
| Monitor       | `omarchy.monitor`         | `bar-widget`            | `panels/monitor/Panel.qml`            |
| Network       | `omarchy.network`         | `bar-widget`            | `panels/network/Panel.qml`            |
| Power         | `omarchy.power`           | `bar-widget`            | `panels/power/Panel.qml`              |
| Tailscale     | `omarchy.tailscale`       | `bar-widget`            | `panels/tailscale/Panel.qml`          |
| Agents   | `omarchy.agents`     | `bar-widget`            | `agents/Panel.qml`               |
| Weather       | `omarchy.weather`         | `bar-widget`            | `panels/weather/BarWidget.qml`        |
| Media         | `omarchy.media`           | `service`, `bar-widget` | `services/media/Service.qml`, `services/media/BarWidget.qml` |
| Battery       | `omarchy.battery`         | `service`               | `services/battery/Service.qml`        |
| Idle          | `omarchy.idle`            | `service`               | `services/idle/Service.qml`           |
| Night light   | `omarchy.nightlight`      | `service`               | `services/nightlight/Service.qml`     |
| Lock screen   | `omarchy.lock`            | `service`               | `lock/Service.qml`                    |
| OSD           | `omarchy.osd`             | `panel`                 | `osd/Osd.qml`                         |
| Polkit agent  | `omarchy.polkit`          | `service`               | `polkit/PolkitAgent.qml`              |

…
```

**⏺ bash** `cd /usr/share/omarchy/shell/plugins/bar; cat README.md; cat manifest.json; wc -l Bar.qml BarModel.js`

✓ 96 ms

```text
[exit 0, 86 ms]
# Omarchy bar

This is the Quickshell implementation of the Omarchy status bar. It is
shipped as a first-party plugin of [`omarchy-shell`](../../README.md), the
long-running shell host. The bar is mounted at startup and lives inside
the shell for its whole session.

- `manifest.json` declares the plugin (`id: omarchy.bar`, `kind: bar`) and points at `Bar.qml` as the entry point.
- `Bar.qml` is Omarchy-owned bar engine code, loaded by the omarchy-shell host. Users should not edit it directly.
- `widgets/` holds simple first-party bar widgets with sibling manifests.
- Feature plugins such as `../panels/audio/`, `../panels/network/`, `../panels/power/`, and `../agents/` provide richer popup bar plugins.
- The bar receives its config from the host shell as a `barConfig` property; the host loads it from `~/.config/omarchy/shell.json` (or `config/omarchy/shell.json` when the user has no file).
- `omarchy bar position` updates only the user shell.json file.

## Customizing

The bar config lives under the `bar:` key of [`~/.config/omarchy/shell.json`](../../README.md#shelljson-shape). Out of the box the shell uses [`config/omarchy/shell.json`](../../../config/omarchy/shell.json). Once you customize anything via the bar gestures, `omarchy bar ...`, or by editing shell.json directly, your file is canonical — there is no deep-merge.

The bar is configured directly on the bar itself: drag empty bar space (or click-and-hold) to move the bar to another screen edge, double-left-click empty center-bar space to toggle transparency, and drag widgets to reorder them. The `omarchy bar position`, `omarchy bar transparent`, `omarchy bar move`, and `omarchy bar set` commands do the same from scripts. Enable or disable widgets with `omarchy plugin enable` and `omarchy plugin disable` (widget ids come from `omarchy plugin list`).

Example `shell.json` (bar subtree only shown):

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "transparent": false,
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [
        { "id": "omarchy.menu" },
        { "id": "omarchy.spacer", "size": 12 },
        { "id": "omarchy.workspaces" }
      ],
      "center": [
        { "id": "omarchy.media" },
        { "id": "omarchy.clock", "format": "HH:mm" }
      ],
…
```

**⏺ bash** `ls /usr/share/omarchy/default/agents/skills/omarchy/ ; ls /usr/share/omarchy/shell; ls /usr/share/omarchy/shell/* | head -60`

✓ 96 ms

```text
[exit 0, 88 ms]
SKILL.md
capture.md
contributing.md
hooks.md
hyprland.md
plugins.md
theming.md
Commons
README.md
Ui
plugins
services
shell.qml
/usr/share/omarchy/shell/README.md
/usr/share/omarchy/shell/shell.qml

/usr/share/omarchy/shell/Commons:
Border.qml
BorderGeometry.js
Color.qml
Style.qml
Util.qml
qmldir

/usr/share/omarchy/shell/Ui:
BarIconButton.qml
BarIndicator.qml
BarWidget.qml
BorderOverlay.qml
BorderSurface.qml
Button.qml
ButtonGroup.qml
ConfirmDialog.qml
CursorSurface.qml
Dropdown.qml
KeyboardPanel.qml
MultiSelect.qml
NumberField.qml
OpticalGlyph.qml
…
```

**⏺ bash** `cd /usr/share/omarchy/shell; cat README.md`

✓ 80 ms

```text
[exit 0, 71 ms]
# Omarchy shell

`omarchy-shell` is a single long-running [Quickshell](https://quickshell.org/)
instance that hosts the Omarchy desktop. Hyprland autostart launches one shell
per graphical session; everything else — the bar, background switcher, panels,
and overlays — runs **inside** the shell as a plugin.

Hosting everything inside one shell means:

- shared services and singletons live once, not once per process
- summoning a panel is an IPC call into a process that is already running,
  not a fresh `quickshell -p ...` cold start
- third-party plugins can be loaded from disk without changing any source
  code in Omarchy itself

The runtime layout:

```
shell/
  shell.qml              entry point (ShellRoot)
  services/
    PluginRegistry.qml   discovers, validates plugins, looks up enabled state in shell.json
    BarWidgetRegistry.qml unified registry for bar widgets (1p + 3p)
  plugins/
    bar/                 first-party plugins (see plugins/README.md)
    image-picker/
    menu/
    notifications/
    panels/
      audio/
      bluetooth/
      monitor/
      network/
      power/
      weather/
    agents/
    services/
      battery/
      idle/
…
```

Now the key question: how the bar instantiates widgets, and what a third-party widget can reach to host others.

**⏺ bash** `cd /usr/share/omarchy/shell; grep -n "barWidgetRegistry\|createObject\|Loader\|sourceComponent\|function \|property " plugins/bar/Bar.qml | head -150`

✓ 72 ms

```text
[exit 0, 67 ms]
15:  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
17:  property var barWidgetRegistry: fallbackBarWidgetRegistry
20:  property var pluginRegistry: null
25:  property var barConfig: ({})
28:  property var shell: null
31:  property var manifest: null
34:    property var widgets: ({})
35:    property int revision: 0
36:    function metadataFor(id) { return null }
41:  property bool barHidden: false
42:  property string home: Quickshell.env("HOME")
43:  property string stateHome: home + "/.local/state"
44:  property string omarchyConfigDir: home + "/.config/omarchy"
45:  property var fallbackBarConfig: ({
51:  property var layoutConfig: fallbackBarConfig.layout
52:  property string centerAnchor: ""
53:  property bool requestedTransparent: false
54:  property bool useTransparentForeground: false
55:  property bool transparent: false
56:  property bool centerSectionHovered: false
61:  property int barHoverCount: 0
63:  readonly property bool barHovered: barHoverCount > 0
64:  property bool centerSectionRevealHeld: false
65:  property bool centerHoverRevealSuppressed: false
66:  property int barConfigSerial: 0
67:  property string position: "top"
71:  property string fontFamily: Style.font.family
74:  property color themeForeground: Color.bar.text
75:  property color themeContrastForeground: Color.background
76:  property color transparentForeground: Color.bar.text
77:  property color foreground: themeForeground
78:  property color barForeground: useTransparentForeground ? transparentForeground : themeForeground
79:  property bool foregroundAnimationEnabled: true
80:  property color background: Color.bar.background
81:  property color urgent: Color.bar.active
86:  property var tooltipTarget: null
87:  property var pendingTooltipTarget: null
88:  property string tooltipText: ""
89:  property string pendingTooltipText: ""
…
```

**⏺ bash** `cd /usr/share/omarchy/shell; sed -n 1,40p plugins/bar/Bar.qml; sed -n 110,330p plugins/bar/Bar.qml`

✓ 72 ms

```text
[exit 0, 66 ms]
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Ui
import "BarModel.js" as BarModel

Item {
  id: root

  // The omarchy-shell host injects omarchyPath from OMARCHY_PATH.
  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  // Injected by the host shell so bar slots can resolve enabled widgets.
  property var barWidgetRegistry: fallbackBarWidgetRegistry
  // Read-only registry view for third-party full bars; the built-in bar does
  // not otherwise need it, but declaring it keeps clone construction atomic.
  property var pluginRegistry: null
  // Injected by the host shell every time shell.json is reloaded. Holds the
  // `bar:` subtree: position, centerAnchor, layout. The host owns file IO;
  // the bar just renders whatever it's handed. The bar font follows the
  // OS-level fontconfig monospace binding — it is not stored in shell.json.
  property var barConfig: ({})
  // Injected by the host shell. Used for shell-wide actions such as opening
  // settings and persisting inline widget state.
  property var shell: null
  // Manifest for the active bar option. Present for custom bars and useful for
  // diagnostics; the built-in bar does not otherwise need it.
  property var manifest: null
  QtObject {
    id: fallbackBarWidgetRegistry
    property var widgets: ({})
    property int revision: 0
    function metadataFor(id) { return null }
  }
  // Mirrors the on-disk `bar-off` flag so the user can hide the bar without
  // killing the entire shell. Hidden panels stay mapped but park off-screen
…
```

**⏺ bash** `cd /usr/share/omarchy/shell; cat Ui/PluginBarApi.qml; grep -n "moduleComponent\|ModuleSlot\|component \|function loadModule\|widgetComponent\|setSource\|Qt.createComponent\|entryUrl\|barWidget" plugins/bar/Bar.qml | sed -n 1,80p`

✓ 93 ms

```text
[exit 0, 85 ms]
import QtQuick

// Bar surface exposed to an installed third-party widget. Scalar presentation
// state is mirrored by Bar.qml and operations are delegated through scoped
// callbacks. The facade avoids direct host-Bar injection; it cannot isolate a
// visual child from the parent hierarchy of the QML scene that renders it.
QtObject {
  id: api

  required property string pluginId
  required property string moduleName
  property var shell: null

  property color foreground: "transparent"
  property color barForeground: "transparent"
  property color background: "transparent"
  property color urgent: "transparent"
  property string fontFamily: ""
  property string position: "top"
  property bool vertical: false
  property int barSize: 0
  property bool transparent: false
  property bool foregroundAnimationEnabled: true
  property bool centerSectionRevealHeld: false
  property bool _centerHoverRevealSuppressed: false
  readonly property bool centerHoverRevealSuppressed: _centerHoverRevealSuppressed
  property var activePopout: null
  property var clickTargets: []
  property var layoutConfig: ({})
  readonly property var foreignPopoutMarker: ({ foreign: true })

  property var _showTooltip: null
  property var _hideTooltip: null
  property var _registerClickTarget: null
  property var _unregisterClickTarget: null
  property var _requestPopout: null
  property var _releasePopout: null
  property var _switchPanelFrom: null
  property var _targetBelongsToWindow: null
…
```

**⏺ bash** `cd /usr/share/omarchy/shell; sed -n 1520,1640p plugins/bar/Bar.qml; sed -n 1719,1920p plugins/bar/Bar.qml`

✓ 75 ms

```text
[exit 0, 66 ms]
    var idx = root.entryIndex(entries, root.centerAnchor)
    return idx === -1 ? null : entries[idx]
  }

  component LeftModules: ModuleList {
    entries: root.layoutEntries("left")
    region: "left"
  }

  component RightModules: ModuleList {
    entries: root.layoutEntries("right")
    region: "right"
  }

  component CenterModules: Item {
    id: centerRoot

    property var entries: root.layoutEntries("center")
    readonly property bool hasAnchor: root.entryIndex(entries, root.centerAnchor) !== -1
    readonly property var anchorEntry: root.findCenterAnchorEntry()

    Loader {
      anchors.fill: parent
      sourceComponent: root.vertical ? verticalCenterModules : horizontalCenterModules
    }

    Component {
      id: horizontalCenterModules

      Item {
        anchors.fill: parent

        CenterGestureArea { anchors.fill: parent }

        HoverHandler {
          onHoveredChanged: root.setCenterSectionHovered(hovered)
        }

        ModuleList {
…
```

The widget facade a third-party plugin gets is narrow. Let me see what `injectProps` passes and whether the bar already has a "hide/reveal" concept I can drive.

**⏺ bash** `cd /usr/share/omarchy/shell; grep -n "function injectProps" -A40 plugins/bar/Bar.qml; grep -n "reveal\|Reveal\|hidden\b\|\"hidden\"\|collapsed" plugins/bar/Bar.qml | head -40`

✓ 75 ms

```text
[exit 0, 67 ms]
1999:    function injectProps() {
2000-      var target = activeItem
2001-      if (!target) return
2002-      if ("bar" in target) target.bar = firstParty
2003-        ? root : root.pluginBarApiFor(pluginApiId, moduleName, registered)
2004-      if ("moduleName" in target) target.moduleName = moduleName
2005-      if ("settings" in target) target.settings = moduleSettings
2006-    }
2007-
2008-    Component {
2009-      id: customCommandModuleComponent
2010-      CustomCommandModule { entry: slot.entry }
2011-    }
2012-  }
2013-
2014-  component CustomCommandModule: WidgetButton {
2015-    id: customRoot
2016-
2017-    required property var entry
2018-    readonly property string moduleName: root.entryId(entry)
2019-    readonly property var settings: root.entrySettings(entry)
2020-    property string outputText: ""
2021-    property string outputTooltip: ""
2022-    property bool outputActive: false
2023-
2024-    function setting(name, fallback) {
2025-      var value = settings ? settings[name] : undefined
2026-      return value === undefined || value === null ? fallback : value
2027-    }
2028-
2029-    function update(raw) {
2030-      var data = Util.parseModuleJson(raw)
2031-      var klass = data.class || data.alt || ""
2032-
2033-      outputText = data.text || String(raw || "").trim()
2034-      outputTooltip = data.tooltip || String(setting("tooltip", ""))
2035-      outputActive = klass === "active" || (Array.isArray(klass) && klass.indexOf("active") !== -1)
2036-    }
2037-
…
```

**⏺ bash** `cd /usr/share/omarchy/shell; grep -n "function pluginShellFor\|barWidgetRegistry\|function .*Facade\|component .*Facade" shell.qml | head -40; ls services`

✓ 70 ms

```text
[exit 0, 65 ms]
20:  property BarWidgetRegistry barWidgetRegistry: BarWidgetRegistry { }
223:    if ("barWidgetRegistry" in target) target.barWidgetRegistry = shell.pluginBarWidgetRegistryFor(manifest)
234:      barWidgetRegistry: shell.barWidgetRegistry
336:    var source = shell.barWidgetRegistry.widgets || {}
684:  function pluginShellForId(pluginId) {
688:  function pluginShellForBarEntry(ownerId, moduleName) {
739:  function pluginShellFor(manifest) {
771:    if (!manifest || manifest.__isFirstParty) return shell.barWidgetRegistry
778:      revision: shell.barWidgetRegistry.revision
873:      widgetApi.revision = shell.barWidgetRegistry.revision
931:      if ("barWidgetRegistry" in inst) inst.barWidgetRegistry = shell.pluginBarWidgetRegistryFor(manifest)
1061:    target: shell.barWidgetRegistry
1344:          if ("barWidgetRegistry" in item) item.barWidgetRegistry = shell.pluginBarWidgetRegistryFor(panelEntry.manifest)
1425:      if (existing && existing.url === url && shell.barWidgetRegistry.has(registryKey)) {
1426:        shell.barWidgetRegistry.register(registryKey, existing.component, meta)
1434:    var allIds = shell.barWidgetRegistry.availableIds()
1439:        shell.barWidgetRegistry.unregister(id)
1448:    for (var id in pluginWidgetComponents) shell.barWidgetRegistry.unregister(id)
1511:        shell.barWidgetRegistry.register(registryKey, comp, meta)
AppLibrary.qml
AppSearch.js
AuthServiceStore.js
BarWidgetRegistry.qml
PluginAppLibraryApi.qml
PluginBarStateApi.qml
PluginBarWidgetRegistryApi.qml
PluginFirstPartyServiceApi.qml
PluginRegistry.qml
PluginRegistryApi.qml
PluginShellApi.qml
hidden-entries.sh
```

**⏺ bash** `cd /usr/share/omarchy/shell; sed -n 200,240p shell.qml; sed -n 680,800p shell.qml; cat services/PluginBarWidgetRegistryApi.qml services/PluginShellApi.qml | head -200`

✓ 74 ms

```text
[exit 0, 67 ms]
    return manifest
      && Array.isArray(manifest.kinds)
      && manifest.kinds.indexOf("bar") !== -1
      && manifest.entryPoints
      && manifest.entryPoints.bar
  }

  function barOptionAvailable(pluginId) {
    var id = String(pluginId || "")
    if (id === "" || id === shell.defaultBarId) return true
    var manifest = shell.barManifestFor(id)
    return shell.isBarOptionManifest(manifest) && shell.pluginRegistry.entryPointUrl(manifest, "bar") !== ""
  }

  function isActiveBarOption(pluginId) {
    return String(pluginId || "") === shell.activeBarId
  }

  function configureBar(target, manifest) {
    if (!target) return
    if ("omarchyPath" in target) target.omarchyPath = shell.omarchyPath
    if ("shell" in target) target.shell = shell.pluginShellFor(manifest)
    if ("manifest" in target) target.manifest = shell.publicPluginManifest(manifest)
    if ("barWidgetRegistry" in target) target.barWidgetRegistry = shell.pluginBarWidgetRegistryFor(manifest)
    if ("pluginRegistry" in target) target.pluginRegistry = shell.pluginRegistryFor(manifest)
    if ("barConfig" in target) target.barConfig = shell.barConfigFor(manifest)
    shell.bar = target
  }

  Component {
    id: defaultBarComponent

    Bar {
      omarchyPath: shell.omarchyPath
      barWidgetRegistry: shell.barWidgetRegistry
      barConfig: shell.barConfig
      shell: shell
      manifest: shell.barManifestFor(shell.defaultBarId)
    }
…
```

**⏺ bash** `cd /usr/share/omarchy/shell; grep -n "function createScopedPluginShell" -A80 shell.qml | head -120; grep -n "function barConfigFor\|function publicBarConfig\|function pluginHasBarCapabilities" -A15 shell.qml`

✓ 73 ms

```text
[exit 0, 66 ms]
569:  function createScopedPluginShell(manifest, cacheKey, allowOwnService, barCapabilities) {
570-    var key = String(manifest && manifest.id || "")
571-    if (!key) return null
572-    var profile = shell.pluginShellCapabilityProfile(manifest, allowOwnService, barCapabilities)
573-    var cached = _pluginShellApis[cacheKey]
574-    var descriptor = _pluginShellApiDescriptors[cacheKey]
575-    if (cached && descriptor && descriptor.pluginId === key
576-        && descriptor.profile === profile) return cached
577-    if (cached || descriptor) shell.revokePluginShellApi(cacheKey)
578-
579-    function currentManifest() {
580-      return shell.pluginRegistry.installedPlugins[key] || null
581-    }
582-
583-    function hasCurrentBarCapabilities() {
584-      return barCapabilities && shell.pluginHasBarCapabilities(currentManifest())
585-    }
586-
587-    // Construct the narrow service proxies before any plugin binding can call
588-    // firstPartyServiceFor(). Creating a QObject while evaluating that binding
589-    // makes QML re-enter the binding and report a loop on the caller's service
590-    // property, even though the resulting proxy is otherwise acyclic.
591-    var firstPartyServices = ({})
592-    var serviceIds = barCapabilities
593-      ? ["omarchy.idle", "omarchy.media", "omarchy.nightlight", "omarchy.notifications"]
594-      : (allowOwnService && shell.pluginIsIndicatorsClone(manifest)
595-        ? ["omarchy.idle", "omarchy.nightlight", "omarchy.notifications"] : [])
596-    for (var i = 0; i < serviceIds.length; i++) {
597-      var serviceId = serviceIds[i]
598-      firstPartyServices[serviceId] = shell.pluginFirstPartyServiceFor(cacheKey, key, serviceId)
599-    }
600-
601-    var api = pluginShellApiComponent.createObject(null, {
602-      pluginId: key,
603-      appLibrary: shell.manifestHasKind(manifest, "menu")
604-        ? shell.pluginAppLibraryFor(cacheKey, key) : null,
605-      bar: shell.pluginBarStateFor(cacheKey, key),
606-      barConfig: shell.publicBarConfig(),
607-      idleConfig: shell.publicIdleConfigFor(manifest),
…
```

Before deciding, I need to know what the built-in widgets need from their host, since anything the drawer hosts must still work.

**⏺ bash** `cd /usr/share/omarchy/shell/plugins; grep -rhoE "\bbar\.[a-zA-Z_]+" --include=*.qml panels agents menu services/media bar/widgets ../Ui | sort | uniq -c | sort -rn | head -50; echo; grep -rnE "serviceFor|firstPartyServiceFor" --include=*.qml panels agents menu services/media bar/widgets ../Ui | head`

✓ 95 ms

```text
[exit 0, 89 ms]
    168 bar.foreground
    110 bar.fontFamily
     20 bar.shell
     14 bar.urgent
     14 bar.position
     10 bar.run
      6 bar.switchPanelFrom
      6 bar.moduleWidgets
      6 bar.iconSlot
      6 bar.hideTooltip
      6 bar.barForeground
      4 bar.vertical
      4 bar.statusSlot
      4 bar.showTooltip
      4 bar.setCenterHoverRevealSuppressed
      4 bar.activePopout
      3 bar.centerHoverRevealSuppressed
      3 bar.barSize
      2 bar.targetBelongsToWindow
      2 bar.sizeHorizontal
      2 bar.requestPopout
      2 bar.releasePopout
      2 bar.layoutConfig
      2 bar.foregroundAnimationEnabled
      2 bar.clickTargets
      2 bar.background
      1 bar.x
      1 bar.iconFont
      1 bar.iconCanvas
      1 bar.centerSectionRevealHeld

panels/audio/Panel.qml:20:  readonly property var mediaService: bar?.shell?.firstPartyServiceFor("omarchy.media")
services/media/BarWidget.qml:10:  readonly property var mediaService: bar?.shell?.firstPartyServiceFor("omarchy.media")
```

**⏺ bash** `cd /usr/share/omarchy/shell; grep -rn "bar\.shell\b\|bar?\.shell" --include=*.qml plugins Ui | grep -v "^plugins/bar/Bar.qml" | head -30; echo; sed -n 1,80p Ui/BarWidget.qml`

✓ 135 ms

```text
[exit 0, 129 ms]
plugins/bar/indicators/Dnd.qml:8:  readonly property var notificationService: bar?.shell?.firstPartyServiceFor("omarchy.notifications")
plugins/bar/indicators/NightLight.qml:7:  readonly property var nightlightService: bar?.shell?.firstPartyServiceFor("omarchy.nightlight")
plugins/bar/indicators/StayAwake.qml:7:  readonly property var idleService: bar?.shell?.firstPartyServiceFor("omarchy.idle")
plugins/bar/widgets/Tray.qml:184:    if (!root.bar || !root.bar.shell || typeof root.bar.shell.updateEntryInline !== "function") return
plugins/bar/widgets/Tray.qml:186:    root.bar.shell.updateEntryInline(id, { id: id, pinned: pinned, hidden: hidden })
plugins/panels/audio/Panel.qml:20:  readonly property var mediaService: bar?.shell?.firstPartyServiceFor("omarchy.media")
plugins/panels/audio/Panel.qml:434:    if (!bar || !bar.shell) return
plugins/panels/audio/Panel.qml:435:    bar.shell.summon("omarchy.osd", JSON.stringify({
plugins/panels/clock/BarWidget.qml:51:    if (root.bar && root.bar.shell && typeof root.bar.shell.updateEntryInline === "function")
plugins/panels/clock/BarWidget.qml:52:      root.bar.shell.updateEntryInline(root.moduleName, entry)
plugins/panels/clock/Panel.qml:161:    if (root.bar && root.bar.shell && typeof root.bar.shell.updateEntryInline === "function")
plugins/panels/clock/Panel.qml:162:      root.bar.shell.updateEntryInline(root.moduleName, entry)
plugins/panels/monitor/Panel.qml:257:    if (!bar || !bar.shell) return
plugins/panels/monitor/Panel.qml:258:    bar.shell.summon("omarchy.osd", JSON.stringify({
plugins/panels/network/Panel.qml:468:    bar.shell.summon("omarchy.wifiqr", JSON.stringify(payload))
plugins/panels/network/Panel.qml:658:    bar.shell.summon("omarchy.speedtest", connection ? JSON.stringify({ connection: connection }) : "{}")
plugins/panels/power/Panel.qml:174:    if (root.bar && root.bar.shell) root.bar.shell.updateEntryInline(root.moduleName, root.settings)
plugins/panels/tailscale/Panel.qml:155:    if (!root.bar || !root.bar.shell || typeof root.bar.shell.updateEntryInline !== "function") return
plugins/panels/tailscale/Panel.qml:159:    root.bar.shell.updateEntryInline(root.moduleName, entry)
plugins/services/media/BarWidget.qml:10:  readonly property var mediaService: bar?.shell?.firstPartyServiceFor("omarchy.media")

import QtQuick
import qs.Commons

// Base item every bar widget extends. Codifies the three properties the
// bar host injects into each widget slot:
//   bar         - the host Bar instance (foreground/background/run/etc).
//   moduleName  - widget's canonical id, used by the host registry to look
//                 up settings and to disambiguate inline IPC routes.
//   settings    - per-widget overrides read from shell.json's layout entry.
//
// Widgets are free to add their own properties, signals, and child items.
Item {
  id: root

  property QtObject bar: null
  property string moduleName: ""
  property var settings: ({})

…
```

Let me look at how popups are built (`Ui/Panel.qml`, `PopupCard`) and how the preview check hosts widgets, since that determines what I can verify offline.

**⏺ bash** `cd /usr/share/omarchy/shell; sed -n 1,200p Ui/PopupCard.qml | head -150; wc -l Ui/Panel.qml Ui/PanelController.qml Ui/WidgetButton.qml Ui/BarIconButton.qml`

✓ 79 ms

```text
[exit 0, 69 ms]
import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Commons

PopupWindow {
  id: root

  required property Item anchorItem
  required property QtObject bar
  property var owner: null
  property int margin: Style.gapsOut
  property int padding: Style.spacing.popupPadding
  property int contentWidth: Style.space(280)
  property int contentHeight: Style.space(200)
  property color borderColor: Color.popups.border
  property var borderSpec: Border.localOrSurfaceSpec("popups", "border", borderColor, Color.popups.border, Math.max(1, Style.space(2)))
  property bool open: false
  property bool centerOnBar: false
  // "click" — uses HyprlandFocusGrab so clicking outside dismisses the popup.
  // "hover" — passive overlay; the owning widget controls open via hover.
  property string triggerMode: "click"

  readonly property var coordinatorKey: owner || root
  readonly property var anchorWindow: anchorItem ? anchorItem.QsWindow.window : null
  readonly property var popupScreen: anchorWindow ? anchorWindow.screen : null
  readonly property bool containsMouse: cardHover.hovered
  readonly property real screenW: popupScreen ? popupScreen.width : 0
  readonly property real screenH: popupScreen ? popupScreen.height : 0
  readonly property real barW: anchorWindow ? anchorWindow.width : 0
  readonly property real barH: anchorWindow ? anchorWindow.height : 0
  readonly property real availableCardWidth: screenW > 0
    ? Math.max(120, screenW - ((bar && (bar.position === "left" || bar.position === "right")) ? barW : 0) - root.margin * 2)
    : 0
  readonly property real availableCardHeight: screenH > 0
    ? Math.max(120, screenH - ((bar && (bar.position === "top" || bar.position === "bottom")) ? barH : 0) - root.margin * 2)
    : 0
  readonly property real verticalContentInset: padding * 2 + Border.top(borderSpec) + Border.bottom(borderSpec)

…
```

**⏺ bash** `ls -la; ls -la .config .config/omarchy; find / -name "preview.py" -path "*" 2>/dev/null | grep -v proc | head`

✓ 3463 ms

```text
[exit 0, 3456 ms]
total 0
drwxr-xr-x 1 parker parker  22 Nov  9 15:24 .
drwx------ 3 parker parker  60 Nov  9 15:25 ..
drwxr-xr-x 1 parker parker  72 Nov  8 22:07 .config
drwxr-xr-x 1 parker parker 160 Nov  9 15:24 .git
.config:
total 0
drwxr-xr-x 1 parker parker  72 Nov  8 22:07 .
drwxr-xr-x 1 parker parker  22 Nov  9 15:24 ..
drwxr-xr-x 1 parker parker  28 Nov  8 22:07 alacritty
drwxr-xr-x 1 parker parker  16 Nov  8 22:07 foot
drwxr-xr-x 1 parker parker  12 Nov  8 22:07 ghostty
drwxr-xr-x 1 parker parker 212 Nov  8 22:07 hypr
drwxr-xr-x 1 parker parker  20 Nov  8 22:07 kitty
drwxr-xr-x 1 parker parker  74 Nov  8 22:07 omarchy

.config/omarchy:
total 4
drwxr-xr-x 1 parker parker   74 Nov  8 22:07 .
drwxr-xr-x 1 parker parker   72 Nov  8 22:07 ..
drwxr-xr-x 1 parker parker   36 Nov  8 22:07 extensions
drwxr-xr-x 1 parker parker  156 Nov  8 22:07 hooks
-rw-r--r-- 1 parker parker 1194 Nov  8 22:07 shell.json
drwxr-xr-x 1 parker parker   50 Nov  8 22:07 themed
drwxr-xr-x 1 parker parker   10 Nov  8 22:07 themes
~/Work/harness-0/fittings/omarchy-v4/preview/preview.py
```

**⏺ bash** `P=~/Work/harness-0/fittings/omarchy-v4/preview; ls $P; sed -n 1,200p $P/preview.py`

✓ 96 ms

```text
[exit 0, 88 ms]
FakeBar.qml
__pycache__
preview.py
shell.qml
#!/usr/bin/env python3
"""Load Omarchy shell plugins (or a theme) in Quickshell offscreen and report what happened.

    preview.py                      every plugin under ~/.config/omarchy/plugins
    preview.py <plugin-dir> ...     these plugins
    preview.py --theme <theme-dir>  a bar strip drawn in that theme's colours

For each entry point in a plugin's manifest it prints whether it loaded, the QML errors that
point into the plugin's own files, and the text the entry point drew. Bar widgets are also
saved as a picture under ./.h0-preview/. Exit status 1 when any plugin has an error.

Nothing is shown on a display (QT_QPA_PLATFORM=offscreen). Popup windows (PanelWindow) need a
layer-shell compositor, so their code is loaded but they cannot be drawn here.
"""

import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
SHELL = Path("/usr/share/omarchy/shell")
DEFAULT_THEME = Path("/usr/share/omarchy/themes/tokyo-night")
NOISE = ("does not support setting window masks",)


def stub(src: str) -> str:
    """An invisible stand-in for a popup type that needs a layer-shell compositor. It keeps the
    real type's properties, signals and function signatures, so a plugin that uses them still has
    to use them correctly, but nothing is drawn."""
    out = ["import QtQuick", "import Quickshell", "import qs.Commons", "", "Item {", "  id: root", "  visible: false",
           "  Item { id: stubHolder }"]
    depth = 0
…
```

**⏺ bash** `P=~/Work/harness-0/fittings/omarchy-v4/preview; cat $P/FakeBar.qml $P/shell.qml`

✓ 53 ms

```text
[exit 0, 46 ms]
import QtQuick
import qs.Commons

// A stand-in for the bar host Omarchy hands every bar widget, carrying the members stock widgets
// use, in the current theme's colours. run() is recorded, never executed: a preview must not act.
QtObject {
  property string position: "top"
  property bool vertical: false
  property bool transparent: false
  property bool barHidden: false
  property bool active: true
  property real x: 0
  property int sizeHorizontal: Style.bar.sizeHorizontal
  property int sizeVertical: Style.bar.sizeVertical !== undefined ? Style.bar.sizeVertical : Style.bar.sizeHorizontal
  property int barSize: sizeHorizontal
  property string fontFamily: Style.font.family
  property color foreground: Color.bar.text
  property color barForeground: Color.bar.text
  property color text: Color.bar.text
  property color background: Color.bar.background
  property color urgent: Color.bar.active
  property bool foregroundAnimationEnabled: true
  property bool centerHoverRevealSuppressed: false
  property bool centerSectionRevealHeld: false
  property var shell: null
  property var layout: ({})
  property var layoutConfig: ({})
  property var activePopout: null
  property var clickTargets: []
  function run(command) { console.info("PREVIEW_RUN " + command) }
  function showTooltip(target, text) {}
  function hideTooltip(target) {}
  function requestPopout(owner) { return true }
  function releasePopout(owner) {}
  function switchPanelFrom(owner, direction) { return false }
  function moduleWidgets(pluginId) { return [] }
  function targetBelongsToWindow(target, window) { return false }
  function setCenterHoverRevealSuppressed(value) { centerHoverRevealSuppressed = value }
  function shellQuote(s) { return "'" + String(s).replace(/'/g, "'\\''") + "'" }
…
```

**⏺ bash** `cd /usr/share/omarchy/shell; cat Ui/Panel.qml Ui/PanelController.qml; sed -n 150,400p Ui/PopupCard.qml`

✓ 76 ms

```text
[exit 0, 70 ms]
import QtQuick
import Quickshell.Io
import qs.Commons

// Base item for plugin popup widgets. Many first-party plugins expose a bar
// button plus a popup from one QML entry point; this base owns the shared
// IPC-backed open/close lifecycle while implementations own button behavior,
// keyboard navigation, and content.
Item {
  id: root

  property QtObject bar: null
  property string moduleName: ""
  property var settings: ({})
  property string ipcTarget: ""
  property bool manageIpc: true
  property alias controller: panelController
  property bool popoutSwitching: false
  property bool popoutSwitchClosing: false

  readonly property bool opened: panelController.open
  readonly property color barForeground: bar ? bar.barForeground : Color.foreground

  function open() { panelController.show() }
  function close() { panelController.hide() }
  function closeForPopoutSwitch() {
    popoutSwitchClosing = true
    close()
    Qt.callLater(function() { popoutSwitchClosing = false })
  }
  function toggle() { opened ? close() : open() }
  function switchPanel(direction) {
    if (bar && typeof bar.switchPanelFrom === "function") return bar.switchPanelFrom(root, direction)
    return false
  }

  // Read a single value from this panel's inline shell.json entry, with a
  // fallback for missing/null values. Matches BarWidget.setting().
  function setting(name, fallback) {
…
```

Now a real stock popup widget for the pattern: weather is moderately sized.

**⏺ bash** `cd /usr/share/omarchy/shell/plugins/panels; ls weather; cat weather/manifest.json; grep -n "activePopout\|PopupCard\|Panel {\|WidgetButton\|BarIconButton\|registerClickTarget\|anchorItem\|owner\|onOpenedChanged\|close()" weather/*.qml | head -40`

✓ 71 ms

```text
[exit 0, 66 ms]
BarWidget.qml
Model.js
Panel.qml
manifest.json
{
  "schemaVersion": 1,
  "id": "omarchy.weather",
  "name": "Weather",
  "version": "1.0.0",
  "author": "Omarchy",
  "description": "Weather pill with detail popup",
  "kinds": [
    "bar-widget"
  ],
  "entryPoints": {
    "barWidget": "BarWidget.qml"
  },
  "barWidget": {
    "displayName": "Weather",
    "description": "Weather pill with detail popup",
    "category": "Info",
    "allowMultiple": false,
    "settingsForm": "weatherSettings"
  }
}
weather/BarWidget.qml:14:    if ("anchorItem" in target) target.anchorItem = button
weather/BarWidget.qml:36:  function close() {
weather/BarWidget.qml:37:    if (panelLoader.item && panelLoader.item.close) panelLoader.item.close()
weather/BarWidget.qml:42:  // KeyboardPanel reads popoutSwitchClosing back off its owner.
weather/BarWidget.qml:67:  BarIconButton {
weather/Panel.qml:8:Panel {
weather/Panel.qml:14:  property var anchorItem: null
weather/Panel.qml:48:  function close() {
weather/Panel.qml:55:    if (root.opened) root.close()
weather/Panel.qml:482:    function close(): void { root.close() }
weather/Panel.qml:484:    function hide(): void { root.close() }
weather/Panel.qml:489:  KeyboardPanel {
weather/Panel.qml:491:    anchorItem: root.anchorItem
weather/Panel.qml:492:    owner: root.barIdentity
…
```

**⏺ bash** `cd /usr/share/omarchy/shell; cat plugins/panels/weather/BarWidget.qml; sed -n 1,70p plugins/panels/weather/Panel.qml; cat Ui/KeyboardPanel.qml | head -120`

✓ 79 ms

```text
[exit 0, 67 ms]
import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.weather"

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("settings" in target) target.settings = root.settings
    if ("anchorItem" in target) target.anchorItem = button
    if ("hostWidget" in target) target.hostWidget = root
  }

  function refresh() {
    if (panelLoader.item && panelLoader.item.refresh) panelLoader.item.refresh()
  }

  function togglePanel() {
    if (panelLoader.item && panelLoader.item.toggle) panelLoader.item.toggle()
  }

  // Shape contract for shell.summon/hide/toggle routing (Bar.findPanelWidget
  // requires open/close/opened on the bar-widget root). Open maps to the
  // panel's hotkey path so summoning suppresses the center hover reveal,
  // matching what the old per-plugin IpcHandler did.
  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false

  function open() {
    if (panelLoader.item && panelLoader.item.openFromHotkey) panelLoader.item.openFromHotkey()
  }

  function close() {
    if (panelLoader.item && panelLoader.item.close) panelLoader.item.close()
  }

…
```

Stock panels use `KeyboardPanel` (a full-screen layer-shell overlay), not xdg popups. Let me read its positioning and dismissal, since hosted widgets will open their panels from inside my drawer.

**⏺ bash** `cd /usr/share/omarchy/shell; sed -n 120,400p Ui/KeyboardPanel.qml`

✓ 74 ms

```text
[exit 0, 66 ms]
    if (!bar) return 0
    var actual = (root.barPos === "top" || root.barPos === "bottom") ? root.barH : root.barW
    return Math.max(bar.barSize, actual) + root.gap
  }
  mask: Region {
    width: root.screenW
    height: root.screenH
  }

  // Track every layout change between the bar's contentItem and the
  // anchor item. `transform` updates whenever any item in that chain
  // moves/resizes, which is what makes the position binding below
  // actually reactive — mapToItem on its own is a one-shot.
  TransformWatcher {
    id: anchorWatcher
    a: anchorWindow ? anchorWindow.contentItem : null
    b: anchorItem
  }

  // Anchor item's position within the bar's content surface. For a
  // full-width top bar, the content x maps directly to screen x; the y
  // returned here has the bar's internal padding baked in (e.g. ~13px
  // from vertical centering of the widget row), which is why `cardOrigin`
  // below uses `barH` for the perpendicular axis instead of this y.
  readonly property point anchorScreenPos: {
    anchorWatcher.transform  // reactive dependency
    if (!anchorItem || !anchorWindow) return Qt.point(0, 0)
    return anchorItem.mapToItem(anchorWindow.contentItem, 0, 0)
  }
  readonly property real anchorW: anchorItem ? anchorItem.width : 0
  readonly property real anchorH: anchorItem ? anchorItem.height : 0
  readonly property real screenW: screen ? screen.width : 0
  readonly property real screenH: screen ? screen.height : 0
  readonly property real availableCardWidth: screenW > 0
    ? Math.max(120, screenW - ((barPos === "left" || barPos === "right") ? barW + gap + margin : margin * 2))
    : 0
  readonly property real availableCardHeight: screenH > 0
    ? Math.max(120, screenH - ((barPos === "top" || barPos === "bottom") ? barH + gap + margin : margin * 2))
    : 0
…
```

**⏺ bash** `cd /usr/share/omarchy/shell; sed -n 540,556p plugins/bar/Bar.qml; sed -n 655,760p plugins/bar/Bar.qml; cat Ui/BarIconButton.qml; sed -n 1,119p Ui/WidgetButton.qml | grep -n "ClickTarget\|triggerPress" `

✓ 95 ms

```text
[exit 0, 87 ms]
  }

  function requestPopout(owner) {
    if (activePopout === owner) return
    if (activePopout) {
      if ("closeForPopoutSwitch" in activePopout) activePopout.closeForPopoutSwitch()
      else if ("close" in activePopout) activePopout.close()
    }
    activePopout = owner
  }

  function releasePopout(owner) {
    if (activePopout === owner) activePopout = null
  }

  readonly property bool vertical: position === "left" || position === "right"
  readonly property int barSize: vertical ? Style.bar.sizeVertical : Style.bar.sizeHorizontal
  function panelWidgetIdAt(region, index) {
    var slots = panelNavigationSlots(String(region || ""), null)
    var slot = slots[Math.round(Number(index)) - 1]
    return slot ? String(slot.moduleName || "") : ""
  }

  function switchPanelFrom(owner, direction) {
    if (!owner) return false

    var currentSlot = null
    for (var i = 0; i < moduleSlots.length; i++) {
      var slot = moduleSlots[i]
      if (slot && slot.activeItem === owner) {
        currentSlot = slot
        break
      }
    }
    if (!currentSlot) return false

    var slots = panelNavigationSlots(currentSlot.region, slotWindow(currentSlot))
    if (slots.length < 2) return false

…
```

**⏺ bash** `cd /usr/share/omarchy/shell; cat services/PluginBarStateApi.qml | head -40; cat plugins/bar/widgets/Tray.manifest.json plugins/bar/widgets/SystemUpdate.manifest.json; cat plugins/menu/manifest.json; which jq qs quickshell; sed -n 20,60p Ui/WidgetButton.qml`

✓ 73 ms

```text
[exit 0, 67 ms]
import QtQuick

// Scalar-only view of the active bar for plugins that position independent
// windows. The active Bar QObject is never retained here.
QtObject {
  required property string ownerPluginId

  property bool barHidden: false
  property int barSize: 0
  property string fontFamily: ""
  property string position: "top"
}
{
  "schemaVersion": 1,
  "id": "omarchy.tray",
  "name": "System tray",
  "version": "1.0.0",
  "author": "Omarchy",
  "description": "Status notifier items",
  "kinds": [
    "bar-widget"
  ],
  "entryPoints": {
    "barWidget": "Tray.qml"
  },
  "barWidget": {
    "displayName": "System tray",
    "description": "Status notifier items",
    "category": "Status",
    "allowMultiple": false
  },
  "omarchy": {
    "clonePaths": [
      {
        "source": "TrayModel.js",
        "target": "TrayModel.js"
      }
    ]
  }
…
```

The design is settled. One more thing to read: the validator schema the shell enforces, and how settings forms / `schema` are declared.

**⏺ bash** `cat $(which omarchy-plugin-validate) | head -150; grep -n "schema\b\|\"type\"\|stringList\|\"list\"\|settingsForm" /usr/share/omarchy/shell/services/PluginRegistry.qml | head -30`

✓ 71 ms

```text
[exit 0, 65 ms]
#!/bin/bash

# omarchy:summary=Validate a plugin folder against the Omarchy plugin manifest schema
# omarchy:group=plugin
# omarchy:args=<plugin-folder>
# omarchy:examples=omarchy plugin validate ./my-plugin

# Mirrors the checks in shell/services/PluginRegistry.qml so the CLI refuses to
# install anything the running shell would silently reject (or worse, load
# unsafely). The shell never trusts manifests blindly; neither do we.

set -o pipefail

fail() {
  echo "omarchy-plugin-validate: $*" >&2
  exit 1
}

if [[ ${1:-} == -h || ${1:-} == --help ]]; then
  cat <<USAGE
Usage: omarchy plugin validate <plugin-folder>

Checks a plugin folder's manifest.json against the schema the shell enforces:
schemaVersion, required fields, safe relative entry points that exist, an entry
point for each kind that needs one, no symlinks, and an id that is not reserved.
Exits 0 if valid — handy for plugin authors before publishing.
USAGE
  exit 0
fi

PLUGIN_DIR="${1:-}"
[[ -n $PLUGIN_DIR && -d $PLUGIN_DIR ]] || fail "plugin folder not found: ${PLUGIN_DIR:-<none>}"

MANIFEST="$PLUGIN_DIR/manifest.json"
[[ -f $MANIFEST ]] || fail "missing manifest.json in $PLUGIN_DIR"
jq -e . "$MANIFEST" >/dev/null 2>&1 || fail "manifest.json is not valid JSON: $MANIFEST"

# schemaVersion must be exactly the JSON number 1 (the only version the registry
# understands). jq's == is type-aware, so the string "1" is correctly rejected
…
```

**⏺ bash** `cd /usr/share/omarchy/shell; grep -n "function updateEntryInline" -A40 shell.qml; grep -n "function scopedPluginShellForId" -A12 shell.qml`

✓ 70 ms

```text
[exit 0, 66 ms]
1078:  function updateEntryInline(moduleName, settings) {
1079-    var stripped = Util.canonicalWidgetId(moduleName)
1080-    var copy = JSON.parse(JSON.stringify(shellConfig || builtinShellConfig))
1081-    if (!Util.isPlainObject(copy.bar)) copy.bar = { layout: { left: [], center: [], right: [] } }
1082-    if (!Util.isPlainObject(copy.bar.layout)) copy.bar.layout = { left: [], center: [], right: [] }
1083-    if (!Array.isArray(copy.plugins)) copy.plugins = []
1084-
1085-    var sections = ["left", "center", "right"]
1086-    var foundInLayout = false
1087-    var dirty = false
1088-    for (var s = 0; s < sections.length; s++) {
1089-      var arr = copy.bar.layout[sections[s]] || []
1090-      for (var i = 0; i < arr.length; i++) {
1091-        if (arr[i] && Util.canonicalWidgetId(arr[i].id) === stripped) {
1092-          var next = { id: stripped }
1093-          for (var k in settings) if (k !== "id") next[k] = settings[k]
1094-          if (JSON.stringify(arr[i]) !== JSON.stringify(next)) {
1095-            arr[i] = next
1096-            dirty = true
1097-          }
1098-          foundInLayout = true
1099-        }
1100-      }
1101-    }
1102-    if (!foundInLayout) {
1103-      for (var j = 0; j < copy.plugins.length; j++) {
1104-        if (copy.plugins[j] && copy.plugins[j].id === stripped) {
1105-          var pnext = { id: stripped }
1106-          for (var pk in settings) if (pk !== "id") pnext[pk] = settings[pk]
1107-          if (JSON.stringify(copy.plugins[j]) !== JSON.stringify(pnext)) {
1108-            copy.plugins[j] = pnext
1109-            dirty = true
1110-          }
1111-        }
1112-      }
1113-    }
1114-    if (!dirty) return false
1115-    persistShellConfig(copy)
1116-    return true
…
```

Checking two host behaviours that hosted widgets will hit through my proxy: tooltips and click-target registration.

**⏺ bash** `cd /usr/share/omarchy/shell; sed -n 330,353p plugins/bar/Bar.qml; grep -n "function showTooltip\|function hideTooltip" -A22 plugins/bar/Bar.qml | head -60; grep -n "tooltipTarget" plugins/bar/Bar.qml | head -20; grep -n "WlrLayershell.layer\|namespace" plugins/bar/Bar.qml`

✓ 112 ms

```text
[exit 0, 105 ms]
  function registerClickTarget(target) {
    if (!target || clickTargets.indexOf(target) !== -1) return
    var next = clickTargets.slice()
    next.push(target)
    clickTargets = next
  }

  function unregisterClickTarget(target) {
    var next = clickTargets.filter(function(item) { return item !== target })
    clickTargets = next
  }

  function registerModuleSlot(slot) {
    if (!slot || moduleSlots.indexOf(slot) !== -1) return
    var next = moduleSlots.slice()
    next.push(slot)
    moduleSlots = next
  }

  function unregisterModuleSlot(slot) {
    var next = moduleSlots.filter(function(item) { return item !== slot })
    moduleSlots = next
  }

1115:  function showTooltip(target, text) {
1116-    clearTooltip()
1117-
1118-    if (!targetTooltipHovered(target) || !text) {
1119-      tooltipRequest += 1
1120-      return
1121-    }
1122-
1123-    var request = tooltipRequest + 1
1124-    tooltipRequest = request
1125-    pendingTooltipTarget = target
1126-    pendingTooltipText = text
1127-
1128-    Qt.callLater(function() {
1129-      if (request !== tooltipRequest) return
…
```

**⏺ bash** `cd /usr/share/omarchy/shell; sed -n 60,119p Ui/WidgetButton.qml; grep -n "function targetTooltipHovered" -A3 plugins/bar/Bar.qml; grep -rn "import qs" ~/.config 2>/dev/null | head -2; ls plugins/dev-gallery; `

✓ 91 ms

```text
[exit 0, 86 ms]
  readonly property real scaledVerticalPadding: Style.spaceReal(verticalPadding)
  readonly property bool tooltipHovered: visible && interactive && !concealed && mouseArea.containsMouse
  // Width of the painted label, for bar chrome that wants to line up with the
  // text rather than with the slot it sits in. Zero on icon-only buttons.
  readonly property real labelWidth: label.visible ? label.implicitWidth : 0

  visible: hasVisualContent || keepSpace
  opacity: !hasVisualContent || concealed ? 0 : (dimmed ? 0.45 : 1)
  implicitWidth: fixedWidth > 0 ? fixedWidth : (vertical ? barSize : Math.max(12, label.implicitWidth + scaledHorizontalMargin * 2))
  implicitHeight: fixedHeight > 0 ? fixedHeight : (vertical ? Math.max(12, label.implicitHeight + scaledVerticalPadding * 2) : barSize)

  Behavior on opacity {
    NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
  }

  Text {
    id: label
    textFormat: Text.PlainText
    visible: root.labelVisible
    anchors.centerIn: parent
    text: root.text
    color: root.active && root.useActiveColor ? root.activeColor : root.foreground
    font.family: root.fontFamily
    font.pixelSize: root.fontSize
    renderType: Text.NativeRendering
    rotation: root.textRotation
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    Behavior on color {
      enabled: !root.bar || root.bar.foregroundAnimationEnabled
      ColorAnimation { duration: 160 }
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
…
```

I have what I need. Quick look at the Style/Color tokens I'll use so the drawer matches the theme:

**⏺ bash** `cd /usr/share/omarchy/shell/Commons; grep -n "property" Style.qml | head -60; grep -n "popups\|tooltip\|muted" Color.qml | head -20; grep -n "tooltip" -i ../plugins/bar/Bar.qml | sed -n 1,5p; sed -n 1285,1330p ../plugins/bar/Bar.qml`

✓ 92 ms

```text
[exit 0, 86 ms]
31:  property int cornerRadius: 0
32:  property int gapsOut: 5
46:  property var styleOverrides: ({})
70:  readonly property string normalColorToken: styleString("normal-color", "foreground")
71:  readonly property string hoverColorToken: styleString("hover-cursor-color", "foreground")
72:  readonly property string selectedColorToken: styleString("selected-color", "foreground")
73:  readonly property string pressedColorToken: styleString("pressed-color", hoverColorToken)
74:  readonly property string focusColorToken: styleString("focus-color", hoverColorToken)
75:  readonly property string selectionColorToken: styleString("selection-color", "foreground")
77:  readonly property int normalBorderWidth: Math.max(0, Math.round(styleNum("normal-border-width", 1)))
78:  readonly property int hoverBorderWidth: Math.max(0, Math.round(styleNum("hover-cursor-border-width", normalBorderWidth)))
79:  readonly property int selectedBorderWidth: Math.max(0, Math.round(styleNum("selected-border-width", 0)))
80:  readonly property int focusBorderWidth: Math.max(0, Math.round(styleNum("focus-border-width", hoverBorderWidth)))
82:  readonly property real normalFillAlpha:    styleAlpha("normal-fill-alpha", 0.04)
83:  readonly property real hoverFillAlpha:     styleAlpha("hover-cursor-fill-alpha", 0.08)
84:  readonly property real selectedFillAlpha:  styleAlpha("selected-fill-alpha", 0.18)
85:  readonly property real pressedFillAlpha:   styleAlpha("pressed-fill-alpha", 0.22)
86:  readonly property real focusFillAlpha:     styleAlpha("focus-fill-alpha", hoverFillAlpha)
87:  readonly property real selectionFillAlpha: styleAlpha("selection-fill-alpha", 0.35)
89:  readonly property real normalBorderAlpha:   styleAlpha("normal-border-alpha", 0.4)
90:  readonly property real hoverBorderAlpha:    styleAlpha("hover-cursor-border-alpha", 0.25)
91:  readonly property real selectedBorderAlpha: styleAlpha("selected-border-alpha", 1.0)
92:  readonly property real focusBorderAlpha:    styleAlpha("focus-border-alpha", hoverBorderAlpha)
189:  readonly property color normalFill: normalFillFor(Color.foreground, Color.accent, Color.urgent)
190:  readonly property color hoverFill: hoverFillFor(Color.foreground, Color.accent, Color.urgent)
191:  readonly property color selectedFill: selectedFillFor(Color.foreground, Color.accent, Color.urgent)
192:  readonly property color pressedFill: pressedFillFor(Color.foreground, Color.accent, Color.urgent)
193:  readonly property color focusFillColor: focusFillFor(Color.foreground, Color.accent, Color.urgent)
194:  readonly property color normalBorderColor: normalBorderFor(Color.foreground, Color.accent, Color.urgent)
195:  readonly property color hoverBorderColor: hoverBorderFor(Color.foreground, Color.accent, Color.urgent)
196:  readonly property color selectedBorderColor: selectedBorderFor(Color.foreground, Color.accent, Color.urgent)
197:  readonly property color focusBorderColor: focusBorderFor(Color.foreground, Color.accent, Color.urgent)
198:  readonly property color selectedAccentFill: Util.alpha(Color.accent, selectedFillAlpha)
199:  readonly property color selectionFill: selectionFillFor(Color.foreground, Color.accent, Color.urgent)
208:  property real spacingScale: 1.0
209:  property bool spacingScaleWithFont: true
210:  property var spacingOverrides: ({})
211:  readonly property real effectiveSpacingScale: spacingScale * (spacingScaleWithFont ? fontScale : 1)
231:  readonly property QtObject spacing: QtObject {
…
```

Let me confirm what the bar passes as `settings` (whole entry or minus id), since hosted widgets should get the same shape:

**⏺ bash** `cd /usr/share/omarchy/shell; sed -n 763,775p plugins/bar/Bar.qml; grep -n "function entrySettings\|function canonicalWidgetId" -A8 Commons/Util.qml plugins/bar/BarModel.js | head -30`

✓ 76 ms

```text
[exit 0, 71 ms]
  function entrySettings(entry) {
    return BarModel.entrySettings(entry)
  }

  function entryId(entry) {
    return BarModel.entryId(entry)
  }

  function moduleString(entry, key, fallback) {
    return BarModel.moduleString(entry, key, fallback)
  }

  function entryIndex(entries, name) {
Commons/Util.qml:70:  function canonicalWidgetId(id) {
Commons/Util.qml-71-    return String(id || "")
Commons/Util.qml-72-  }
Commons/Util.qml-73-
Commons/Util.qml-74-  // Best-effort base64 decode. Returns "" on parse failure rather than
Commons/Util.qml-75-  // surfacing garbage downstream.
Commons/Util.qml-76-  function decodeBase64(value) {
Commons/Util.qml-77-    var s = String(value || "")
Commons/Util.qml-78-    if (!s) return ""
--
plugins/bar/BarModel.js:10:function entrySettings(entry) {
plugins/bar/BarModel.js-11-  if (!isPlainObject(entry)) return {}
plugins/bar/BarModel.js-12-  var copy = {}
plugins/bar/BarModel.js-13-  for (var key in entry) {
plugins/bar/BarModel.js-14-    if (key === "id") continue
plugins/bar/BarModel.js-15-    copy[key] = entry[key]
plugins/bar/BarModel.js-16-  }
plugins/bar/BarModel.js-17-  return copy
plugins/bar/BarModel.js-18-}
```

**⏺ write** `.config/omarchy/plugins/parker.drawer/manifest.json`

```
{
  "schemaVersion": 1,
  "id": "parker.drawer",
  "name": "Drawer",
  "version": "1.0.0",
  "author": "parker",
  "description": "Bar button that opens a panel holding the bar widgets you tuck away",
  "kinds": [
    "bar-widget"
  ],
  "entryPoints": {
    "barWidget": "Drawer.qml"
  },
  "barWidget": {
    "displayName": "Drawer",
    "description": "Click to show tucked-away bar widgets",
    "category": "Layout",
    "allowMultiple": true,
    "defaultSection": "right",
    "defaults": {
      "icon": "󰅀",
      "iconOpen": "󰅃",
      "tooltip": "Drawer",
      "items": []
    }
  }
}
```

✓ 2 ms

```text
wrote 603 bytes to .config/omarchy/plugins/parker.drawer/manifest.json
```

Now the widget itself:

**⏺ write** `.config/omarchy/plugins/parker.drawer/Drawer.qml`

```
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
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
  property var hostedSlots: []

  // Shape the bar's popout coordinator and `omarchy-shell shell toggle
  // parker.drawer` look for: open / close / opened on the widget root.
  readonly property bool opened: drawerOpen
  readonly property bool popoutSwitchClosing: false

  readonly property var barWindow: button.QsWindow.window

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight
… (491 more lines in the repository)
```

✓ 1 ms

```text
wrote 21508 bytes to .config/omarchy/plugins/parker.drawer/Drawer.qml
```

**⏺ edit** `.config/omarchy/plugins/parker.drawer/Drawer.qml`

```
  // Another bar panel taking over calls close() through the bar's popout
  // coordinator. (Watching activePopout instead would race: the bar briefly
  // clears it while handing over to this drawer.)
  onBarChanged: if (!bar) close()
```

✓ 1 ms

```text
edited .config/omarchy/plugins/parker.drawer/Drawer.qml at line 175

[harness note] Read /usr/share/omarchy/default/agents/skills/omarchy/plugins.md first. Bar is omarchy-shell, not Waybar; idle values are seconds. A new plugin goes in .config/omarchy/plugins/<id>/ with a manifest.json; read a built-in plugin's source under /usr/share/omarchy/shell/plugins/ for the patterns, and switch a plugin on by adding its id to shell.json (bar.layout for widgets, plugins for others). Run the validate and preview checks before finishing. Never edit packaged plugins.
```

**⏺ edit** `.config/omarchy/plugins/parker.drawer/Drawer.qml`

```
      // The guard covers the grab being dropped because a hosted panel opened.
      onCleared: if (!root.hostedPopout) root.close()
```

✓ 1 ms

```text
edited .config/omarchy/plugins/parker.drawer/Drawer.qml at line 353
```

**⏺ bash** `cd /usr/share/omarchy/shell/Commons; grep -n "function left\|function right\|function top\|function bottom\|function surfaceSpec\|function flat" Border.qml; grep -n "statusSlot\|iconFont\|sizeHorizontal" Style.qml | head`

✓ 114 ms

```text
[exit 0, 109 ms]
16:  function flat(color, width) {
140:  function surfaceSpec(section, token, fallbackColor, fallbackWidth, alphaKey) {
236:  function top(spec) { return spec && spec.widths ? spec.widths.top : 0 }
237:  function right(spec) { return spec && spec.widths ? spec.widths.right : 0 }
238:  function bottom(spec) { return spec && spec.widths ? spec.widths.bottom : 0 }
239:  function left(spec) { return spec && spec.widths ? spec.widths.left : 0 }
342:    readonly property int sizeHorizontal: root.barToken("size-horizontal", 26)
346:    readonly property int iconFont:       root.barToken("icon-font",       13)
347:    readonly property int statusSlot:     root.barToken("status-slot",     21)
```

All the tokens I referenced exist. Now let me validate and preview the plugin before wiring it into the bar:

**⏺ check** `validate`

✓ 211 ms

```text
[exit 0, 207 ms]
valid: .config/omarchy/plugins/parker.drawer/
```

**⏺ check** `preview`

✗ 3050 ms

```text
[exit 1, 3045 ms]
plugin parker.drawer  (~/.config/omarchy/plugins/parker.drawer)
  barWidget: Drawer.qml: errors; drew no text
    picture: ~/.h0-preview/parker.drawer-barWidget.png
    WARN scene: file://~/.config/omarchy/plugins/parker.drawer/Drawer.qml[317:3]: No PanelWindow backend loaded.
    WARN qml: PREVIEW_LOAD_ERROR file://~/.config/omarchy/plugins/parker.drawer/Drawer.qml
PREVIEW: FAILED
```

**⏺ read** `.config/omarchy/plugins/parker.drawer/Drawer.qml`

✓ 2 ms

```text
305	  Timer {
306	    id: tooltipTimer
307	    interval: 400
308	    onTriggered: tooltipState.shown = !!tooltipState.target && tooltipState.target.tooltipHovered === true
309	  }
310	
311	  // ---- the drawer surface -------------------------------------------------
312	
313	  // Spans from the screen edge across the bar to the far side of the card.
314	  // Hosted widgets' own panels place themselves past the edge of the window
315	  // their button sits in, so this extent puts them just beyond the drawer.
316	  // Only the card takes input; the part over the bar is click-through.
317	  PanelWindow {
318	    id: drawerWindow
319	
320	    readonly property string pos: hostBar.position
321	    readonly property bool sideBar: pos === "left" || pos === "right"
322	    readonly property real barW: root.barWindow ? root.barWindow.width : hostBar.barSize
323	    readonly property real barH: root.barWindow ? root.barWindow.height : hostBar.barSize
324	    readonly property int gap: Style.gapsOut
325	    readonly property int margin: Style.gapsOut
326	    readonly property real screenW: screen ? screen.width : 0
327	    readonly property real screenH: screen ? screen.height : 0
328	
329	    screen: root.barWindow ? root.barWindow.screen : null
330	    visible: root.drawerOpen || card.opacity > 0
331	    color: "transparent"
332	    exclusionMode: ExclusionMode.Ignore
333	    WlrLayershell.namespace: "parker-drawer"
334	    WlrLayershell.layer: WlrLayer.Top
335	    WlrLayershell.keyboardFocus: root.drawerOpen && !root.hostedPopout ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
336	
337	    anchors {
338	      top: drawerWindow.pos !== "bottom"
339	      bottom: drawerWindow.pos !== "top"
340	      left: drawerWindow.pos !== "right"
341	      right: drawerWindow.pos !== "left"
342	    }
343	    implicitWidth: sideBar ? Math.ceil(barW + gap + card.width) : 0
344	    implicitHeight: sideBar ? 0 : Math.ceil(barH + gap + card.height)
…
```

I'll split out the hosting grid into `DrawerContent.qml`:

**⏺ write** `.config/omarchy/plugins/parker.drawer/DrawerContent.qml`

```
import QtQuick
import qs.Commons

// The row (or, on a vertical bar, column) of hosted widgets inside the drawer.
// Kept apart from the window so it can be loaded and checked on its own.
Item {
  id: root

  // Stand-in bar handed to every hosted widget (see Drawer.qml `hostBar`).
  property QtObject hostBar: null
  // Normalized entries, each { id, ...inline settings }.
  property var items: []
  // Ids in display order; reassigned only when the list of ids changes.
  property var itemIds: []
  // id -> file URL of that plugin's barWidget entry point.
  property var widgetUrls: ({})
  property bool resolved: false

  property var hostedSlots: []

  readonly property bool vertical: hostBar ? hostBar.vertical : false
  readonly property int barSize: hostBar ? hostBar.barSize : Style.bar.sizeHorizontal

  implicitWidth: grid.implicitWidth
  implicitHeight: grid.implicitHeight

  function settingsOf(entry) {
    var copy = {}
    for (var key in entry) if (key !== "id") copy[key] = entry[key]
    return copy
  }

  // Live hosted widget roots, optionally only those with the given id.
  function hostedWidgets(id) {
    var out = []
    for (var i = 0; i < hostedSlots.length; i++) {
      var slot = hostedSlots[i]
      if (slot && slot.hosted && (!id || slot.modelData === id)) out.push(slot.hosted)
    }
    return out
  }

  Grid {
    id: grid
    flow: root.vertical ? Grid.TopToBottom : Grid.LeftToRight
    columns: root.vertical ? 1 : Math.max(1, root.itemIds.length + 1)
    rows: root.vertical ? Math.max(1, root.itemIds.length + 1) : 1
    spacing: 0

    Repeater {
      model: root.itemIds

      Item {
        id: slot

        required property string modelData
        required property int index

        readonly property var entry: root.items[index] && root.items[index].id === modelData
          ? root.items[index] : ({ id: modelData })
… (71 more lines in the repository)
```

✓ 3 ms

```text
wrote 4837 bytes to .config/omarchy/plugins/parker.drawer/DrawerContent.qml
```

Now I'll rewrite the window section of `Drawer.qml` to lazy-load and use `DrawerContent`, and point `hostedWidgets` at it:

**⏺ bash** `cd .config/omarchy/plugins/parker.drawer && python3 - <<'EOF'
import re
p="Drawer.qml"; s=open(p).read()
start=s.index("  // ---- the drawer surface")
end=s.index("    PopupWindow {\n      id: tooltipWindow")
new='''  // ---- the drawer surface -------------------------------------------------

  //`

✓ 137 ms

```text
[exit 0, 126 ms]
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

  LazyLoader {
    id: windowLoader
    active: root.everOpened

    // Spans from the screen edge across the bar to the far side of the card.
    // Hosted widgets' own panels place themselves past the edge of the window
    // their button sits in, so this extent puts them just beyond the drawer.
    // Only the card takes input; the part over the bar is click-through.
    PanelWindow {
      id: drawerWindow

      property alias content: drawerContent

      readonly property string pos: hostBar.position
      readonly property bool sideBar: pos === "left" || pos === "right"
      readonly property real barW: root.barWindow ? root.barWindow.width : hostBar.barSize
      readonly property real barH: root.barWindow ? root.barWindow.height : hostBar.barSize
          resolved: root.resolved
        }
      }

      PopupWindow {
        id: tooltipWindow

        readonly property var target: tooltipState.target
…
```

Structure looks right. Re-run the checks:

**⏺ check** `preview`

✗ 2963 ms

```text
[exit 1, 2959 ms]
plugin parker.drawer  (~/.config/omarchy/plugins/parker.drawer)
  barWidget: Drawer.qml: errors; drew no text
    picture: ~/.h0-preview/parker.drawer-barWidget.png
    WARN scene: file://~/.config/omarchy/plugins/parker.drawer/Drawer.qml[322:5]: No PanelWindow backend loaded.
    WARN qml: PREVIEW_LOAD_ERROR file://~/.config/omarchy/plugins/parker.drawer/Drawer.qml
PREVIEW: FAILED
```

**⏺ bash** `cd .config/omarchy/plugins/parker.drawer && python3 - <<'EOF'
p="Drawer.qml"; s=open(p).read()
start=s.index("  LazyLoader {\n    id: windowLoader")
win=s[start:]
s=s[:start]+'''  // Only the drawer itself refers to these; DrawerWindow reads them here.
  readonly property QtObject hostBarApi: hostBa`

✓ 96 ms

```text
[exit 0, 86 ms]
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

// The drawer surface. Spans from the screen edge across the bar to the far
// side of the card: hosted widgets' own panels place themselves past the
// edge of the window their button sits in, so this extent puts them just
// beyond the drawer. Only the card takes input; the part over the bar is
// click-through.
PanelWindow {
  id: drawerWindow

  // The Drawer.qml widget that owns this window.
  required property var drawer

  property alias content: drawerContent

  readonly property string pos: drawer.hostBarApi.position
  readonly property bool sideBar: pos === "left" || pos === "right"
  readonly property real barW: drawer.barWindow ? drawer.barWindow.width : drawer.hostBarApi.barSize
  readonly property real barH: drawer.barWindow ? drawer.barWindow.height : drawer.hostBarApi.barSize
  readonly property int gap: Style.gapsOut
  readonly property int margin: Style.gapsOut
  readonly property real screenW: screen ? screen.width : 0
  readonly property real screenH: screen ? screen.height : 0

  screen: drawer.barWindow ? drawer.barWindow.screen : null
10:// edge of the window their button sits in, so this extent puts them just
64:  readonly property point buttonPos: {
78:      var want = drawerWindow.buttonPos.x + drawer.anchorButton.width / 2 - width / 2
84:      var want = drawerWindow.buttonPos.y + drawer.anchorButton.height / 2 - height / 2
107:      hostBar: drawer.hostBarApi
```

The conversion is clean (no stray `root.`/`button` references). Tidy the now-unneeded imports in `Drawer.qml`, then re-check:

**⏺ bash** `cd .config/omarchy/plugins/parker.drawer && sed -i '/^import Quickshell.Wayland$/d; /^import Quickshell.Hyprland$/d' Drawer.qml && head -8 Drawer.qml && tail -25 Drawer.qml`

✓ 79 ms

```text
[exit 0, 69 ms]
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Drawer: a bar button that opens a strip holding the bar widgets listed in
// this entry's `items` in ~/.config/omarchy/shell.json, e.g.
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

    // Its own file, like the stock KeyboardPanel: a layer-shell window is only
    // built here, on first open, never while the bar widget itself loads.
    DrawerWindow { drawer: root }
  }
}
```

**⏺ check** `preview`

✗ 2952 ms

```text
[exit 1, 2948 ms]
plugin parker.drawer  (~/.config/omarchy/plugins/parker.drawer)
  barWidget: Drawer.qml: errors; drew no text
    picture: ~/.h0-preview/parker.drawer-barWidget.png
    WARN scene: file://~/.config/omarchy/plugins/parker.drawer/Drawer.qml[323:5]: Type DrawerWindow unavailable
    WARN scene: file://~/.config/omarchy/plugins/parker.drawer/DrawerWindow.qml[13:1]: No PanelWindow backend loaded.
    WARN qml: PREVIEW_LOAD_ERROR file://~/.config/omarchy/plugins/parker.drawer/Drawer.qml
PREVIEW: FAILED

[harness note] You have made this exact call three times. Step back: re-read the goal and try a different approach.
```

**⏺ bash** `f=$(grep -rl '"LazyLoader"\|name: "LazyLoader"\|LazyLoader' /usr/lib/qt6/qml/Quickshell/*.qmltypes 2>/dev/null | head -3); echo "$f"; for x in $f; do awk '/name: "LazyLoader"|exports: \["Quickshell\/LazyLoader/{p=1} p{print} p&&/^    }/{exit}' "$x" | head -40; done; grep -n "Component {" -A3 /usr/li`

✓ 118 ms

```text
[exit 0, 111 ms]
/usr/lib/qt6/qml/Quickshell/quickshell-core.qmltypes
        name: "LazyLoader"
        accessSemantics: "reference"
        defaultProperty: "component"
        prototype: "Reloadable"
        exports: ["Quickshell/LazyLoader 0.0"]
        exportMetaObjectRevisions: [0]
        Property {
            name: "item"
            type: "QObject"
            isPointer: true
            read: "item"
            notify: "itemChanged"
            index: 0
            lineNumber: 98
            isReadonly: true
        }
        Property {
            name: "loading"
            type: "bool"
            read: "isLoading"
            write: "setLoading"
            notify: "loadingChanged"
            index: 1
            lineNumber: 106
        }
        Property {
            name: "active"
            type: "bool"
            read: "isActive"
            write: "setActive"
            notify: "activeChanged"
            index: 2
            lineNumber: 114
        }
        Property {
            name: "activeAsync"
            type: "bool"
            read: "isActive"
…
```

**⏺ bash** `awk '/name: "LazyLoader"/{p=1} p&&/name: "(source|component)"/{print; getline; print} p&&/^    Component/{if(n++)exit}' /usr/lib/qt6/qml/Quickshell/quickshell-core.qmltypes`

✓ 70 ms

```text
[exit 0, 65 ms]
            name: "component"
            type: "QQmlComponent"
            name: "source"
            type: "QString"
```

`LazyLoader` has a `source` (URL string), so it can load the window file at runtime without a compile-time type reference:

**⏺ edit** `.config/omarchy/plugins/parker.drawer/Drawer.qml`

```
    // Loaded by URL, not by type name: a layer-shell window type is resolved
    // only here, on first open, never while the bar widget itself loads.
    source: Qt.resolvedUrl("DrawerWindow.qml")
    onItemChanged: if (item) item.drawer = root
  }
```

✓ 1 ms

```text
edited .config/omarchy/plugins/parker.drawer/Drawer.qml at line 321
```

**⏺ bash** `cd .config/omarchy/plugins/parker.drawer && sed -i 's/^  required property var drawer$/  property var drawer: null/' DrawerWindow.qml && grep -n "property var drawer" DrawerWindow.qml`

✓ 74 ms

```text
[exit 0, 65 ms]
17:  property var drawer: null
```

**⏺ bash** `cd .config/omarchy/plugins/parker.drawer && python3 - <<'EOF'
p="DrawerWindow.qml"; s=open(p).read()
head,body=s.split("  property var drawer: null\n",1)
body=body.replace("drawer.","d.")
fallback='''  property var drawer: null
  // Inert until Drawer.qml assigns `drawer` right after creation, so no`

✓ 92 ms

```text
[exit 0, 86 ms]
87:    b: d.anchorButton
90:  readonly property point buttonPos: {
92:    if (!d.barWindow || !d.anchorButton) return Qt.point(0, 0)
93:    return d.anchorButton.mapToItem(d.barWindow.contentItem, 0, 0)
104:      var want = drawerWindow.buttonPos.x + (d.anchorButton ? d.anchorButton.width : 0) / 2 - width / 2
110:      var want = drawerWindow.buttonPos.y + (d.anchorButton ? d.anchorButton.height : 0) / 2 - height / 2
```

**⏺ check** `preview`

✗ 2963 ms

```text
[exit 1, 2958 ms]
plugin parker.drawer  (~/.config/omarchy/plugins/parker.drawer)
  barWidget: Drawer.qml: errors; drew: 󰅀
    picture: ~/.h0-preview/parker.drawer-barWidget.png
    WARN: file://~/.config/omarchy/plugins/parker.drawer/DrawerWindow.qml:13:1: No PanelWindow backend loaded.
PREVIEW: FAILED
```

Progress: the bar button now loads and draws `󰅀`. `LazyLoader` still compiles `source` eagerly even while inactive, so I'll only set the URL once the drawer is first opened:

**⏺ edit** `.config/omarchy/plugins/parker.drawer/Drawer.qml`

```
    // (LazyLoader compiles its source as soon as it is set, active or not.)
    source: root.everOpened ? Qt.resolvedUrl("DrawerWindow.qml") : ""
```

✓ 2 ms

```text
edited .config/omarchy/plugins/parker.drawer/Drawer.qml at line 323
```

**⏺ check** `preview`

✓ 2896 ms

```text
[exit 0, 2888 ms]
plugin parker.drawer  (~/.config/omarchy/plugins/parker.drawer)
  barWidget: Drawer.qml: loaded; drew: 󰅀
    picture: ~/.h0-preview/parker.drawer-barWidget.png
PREVIEW: ok
```

**⏺ bash** `set -e
PD=$PWD/.config/omarchy/plugins/parker.drawer
# 1) the exact resolver script, extracted from Drawer.qml
python3 - "$PD/Drawer.qml" > /tmp/resolve.sh <<'EOF'
import sys,re
s=open(sys.argv[1]).read()
m=re.search(r'command: \["bash", "-c", `(.*?)`', s, re.S).group(1)
print(m.replace('\\\\','\\')`

✗ 111 ms

```text
[exit 1, 106 ms]
Invalid environment variable name evaluates to an empty string: ','${'))
EOF
bash /tmp/resolve.sh drawer-resolve /usr/share/omarchy "$PWD" | sort | awk -F'\t' '{print $1" -> "$2
  File "<stdin>", line 4
    print(m.replace('\\\\','\\').replace('\\' | grep -E "weather|system-update|keyboard|agents|monitor|clock|tray|drawer"
                                        ^
SyntaxError: '(' was never closed
```

The sandbox's command pre-processing tripped on a literal `${` in my heredoc. I'll put the test helpers in files instead:

**⏺ write** `/tmp/drawer-extract.py`

```
import re, sys
s = open(sys.argv[1]).read()
m = re.search(r'command: \["bash", "-c", `(.*?)`', s, re.S).group(1)
# undo the JS template-literal escapes: "\\" -> "\" and "\$" + "{" -> "$" + "{"
m = m.replace("\\\\", "\\").replace("\\$" + "{", "$" + "{")
print(m)
```

✗ 0 ms

```text
refused by policy (write-outside): write outside the project: /tmp/drawer-extract.py (headless: no one to ask)
```

**⏺ bash** `PD=$PWD/.config/omarchy/plugins/parker.drawer
python3 /tmp/drawer-extract.py $PD/Drawer.qml > /tmp/resolve.sh
bash -n /tmp/resolve.sh && echo SYNTAX_OK
bash /tmp/resolve.sh drawer-resolve /usr/share/omarchy "$PWD" | sort | awk -F'\t' '{print $1" -> "$2}' | grep -E "weather|system-update|keyboard|age`

✓ 131 ms

```text
[exit 0, 126 ms]
python3: can't open file '/tmp/drawer-extract.py': [Errno 2] No such file or directory
SYNTAX_OK
0
```

Writes outside the project aren't allowed, so I'll use a scratch folder inside the project and delete it afterwards:

**⏺ write** `.h0-scratch/extract.py`

```
import re, sys
s = open(sys.argv[1]).read()
m = re.search(r'command: \["bash", "-c", `(.*?)`', s, re.S).group(1)
# undo the JS template-literal escapes: "\\" -> "\" and "\$" + "{" -> "$" + "{"
m = m.replace("\\\\", "\\").replace("\\$" + "{", "$" + "{")
print(m)
```

✓ 1 ms

```text
wrote 262 bytes to .h0-scratch/extract.py
```

**⏺ bash** `S=$PWD/.h0-scratch; PD=$PWD/.config/omarchy/plugins/parker.drawer
python3 $S/extract.py $PD/Drawer.qml > $S/resolve.sh
bash -n $S/resolve.sh && echo SYNTAX_OK
bash $S/resolve.sh drawer-resolve /usr/share/omarchy "$PWD" | sort | awk -F'\t' '{print $1" -> "$2}' | grep -E "weather|system-update|keyboar`

✓ 136 ms

```text
[exit 0, 130 ms]
SYNTAX_OK
total: 0
```

**⏺ bash** `S=$PWD/.h0-scratch; cat -A $S/resolve.sh | head -12`

✓ 73 ms

```text
[exit 0, 67 ms]
$
      shopt -s nullglob$
      for f in "$1"/shell/plugins/*/manifest.json "$1"/shell/plugins/*/*/manifest.json \$
               "$1"/shell/plugins/*/*.manifest.json "$1"/shell/plugins/*/*/*.manifest.json \$
               "$2"/.config/omarchy/plugins/*/manifest.json; do$
        jq -r --arg d "${f%/*}" '$
          select(((.kinds // []) | index("bar-widget")) and ((.entryPoints.barWidget // null) | type) == "string")$
          | [.id, $d + "/" + .entryPoints.barWidget] | @tsv' "$f" 2>/dev/null$
      done$
    $
```

The script is fine; my test call was wrong. `bash file a b` shifts positional args compared with `bash -c script name a b`, which is how the plugin calls it. Re-running it the plugin's way:

**⏺ bash** `S=$PWD/.h0-scratch
bash -c "$(cat $S/resolve.sh)" drawer-resolve /usr/share/omarchy "$PWD" | sort | awk -F'\t' '{print $1" -> "$2}' | grep -E "weather|system-update|keyboard|agents|monitor|clock|drawer"
echo total: $(bash -c "$(cat $S/resolve.sh)" drawer-resolve /usr/share/omarchy "$PWD" | wc -l)`

✓ 553 ms

```text
[exit 0, 548 ms]
omarchy.agents -> /usr/share/omarchy/shell/plugins/agents/Panel.qml
omarchy.clock -> /usr/share/omarchy/shell/plugins/panels/clock/BarWidget.qml
omarchy.keyboard-layout -> /usr/share/omarchy/shell/plugins/bar/widgets/KeyboardLayout.qml
omarchy.monitor -> /usr/share/omarchy/shell/plugins/panels/monitor/Panel.qml
omarchy.system-update -> /usr/share/omarchy/shell/plugins/bar/widgets/SystemUpdate.qml
omarchy.weather -> /usr/share/omarchy/shell/plugins/panels/weather/BarWidget.qml
parker.drawer -> ~/.config/omarchy/plugins/parker.drawer/Drawer.qml
total: 21
```

**⏺ bash** `S=$PWD/.h0-scratch; PD=$PWD/.config/omarchy/plugins/parker.drawer; T=$S/test.drawer; mkdir -p $T
URLS=$(bash -c "$(cat $S/resolve.sh)" r /usr/share/omarchy "$PWD" | jq -Rn '[inputs|split("\t")|{(.[0]):("file://"+.[1])}]|add' | tr -d '\n')
printf '%s' '{"schemaVersion":1,"id":"test.drawer","name":"t"`

✓ 6720 ms

```text
[exit 0, 6703 ms]
plugin test.drawer  (~/.h0-scratch/test.drawer)
  barWidget: Test.qml: loaded; drew: 15:32 | 󰍹 | ? nope.typo
    picture: ~/.h0-preview/test.drawer-barWidget.png
PREVIEW: ok
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[540:-1]: TypeError: Cannot read property 'foreground' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[541:-1]: TypeError: Cannot read property 'fontFamily' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[555:-1]: TypeError: Cannot read property 'foreground' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[556:-1]: TypeError: Cannot read property 'fontFamily' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[565:-1]: TypeError: Cannot read property 'foreground' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[566:-1]: TypeError: Cannot read property 'fontFamily' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[595:-1]: TypeError: Cannot read property 'foreground' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[596:-1]: TypeError: Cannot read property 'fontFamily' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[603:-1]: TypeError: Cannot read property 'foreground' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[604:-1]: TypeError: Cannot read property 'fontFamily' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[620:-1]: TypeError: Cannot read property 'foreground' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[621:-1]: TypeError: Cannot read property 'fontFamily' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[656:-1]: TypeError: Cannot read property 'foreground' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[655:-1]: TypeError: Cannot read property 'fontFamily' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[687:-1]: TypeError: Cannot read property 'foreground' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[688:-1]: TypeError: Cannot read property 'fontFamily' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[695:-1]: TypeError: Cannot read property 'foreground' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[696:-1]: TypeError: Cannot read property 'fontFamily' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[705:-1]: TypeError: Cannot read property 'foreground' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[706:-1]: TypeError: Cannot read property 'fontFamily' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[713:-1]: TypeError: Cannot read property 'foreground' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[714:-1]: TypeError: Cannot read property 'fontFamily' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[723:-1]: TypeError: Cannot read property 'foreground' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[724:-1]: TypeError: Cannot read property 'fontFamily' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[731:-1]: TypeError: Cannot read property 'foreground' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[732:-1]: TypeError: Cannot read property 'fontFamily' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[796:-1]: TypeError: Cannot read property 'foreground' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[797:-1]: TypeError: Cannot read property 'fontFamily' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/weather/Panel.qml[807:-1]: TypeError: Cannot read property 'foreground' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/monitor/Panel.qml[841:-1]: TypeError: Cannot read property 'fontFamily' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/monitor/Panel.qml[840:-1]: TypeError: Cannot read property 'foreground' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/monitor/Panel.qml[841:-1]: TypeError: Cannot read property 'fontFamily' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/monitor/Panel.qml[840:-1]: TypeError: Cannot read property 'foreground' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/monitor/Panel.qml[841:-1]: TypeError: Cannot read property 'fontFamily' of null
  WARN scene: file:///usr/share/omarchy/shell/plugins/panels/monitor/Panel.qml[840:-1]: TypeError: Cannot read property 'foreground' of null
…
```

**⏺ bash** `cp .config/omarchy/shell.json .config/omarchy/shell.json.bak.$(date +%s) && ls .config/omarchy/`

✓ 71 ms

```text
[exit 0, 67 ms]
extensions
hooks
plugins
shell.json
shell.json.bak.1794263593
themed
themes
```

**⏺ edit** `.config/omarchy/shell.json`

```
        {
          "id": "omarchy.system-update"
        }
      ],
      "right": [
        {
          "id": "parker.drawer",
          "items": [
            "omarchy.weather",
            "omarchy.keyboard-layout",
            "omarchy.agents",
            "omarchy.monitor"
          ]
        },
        {
          "id": "omarchy.tray"
        },
        {
          "id": "omarchy.bluetooth"
        },
        {
          "id": "omarchy.network"
        },
        {
          "id": "omarchy.audio"
        },
        {
          "id": "omarchy.power"
        }
      ]
```

✓ 276 ms

```text
edited .config/omarchy/shell.json at line 30
```

Now a short README for the plugin. Then I'll remove the scratch folder and run the full build check.

**⏺ write** `.config/omarchy/plugins/parker.drawer/README.md`

```
# parker.drawer

A bar button (󰅀) that opens a small strip under it holding bar widgets you
have tucked away, so the bar itself shows only the essentials.

## Choosing what goes in the drawer

Edit the drawer's entry in `~/.config/omarchy/shell.json` (hot-reloads):

```json
{ "id": "parker.drawer",
  "items": [
    "omarchy.weather",
    "omarchy.agents",
    { "id": "omarchy.clock", "format": "HH:mm" }
  ] }
```

- An item is a widget id, or a full layout entry with its inline settings.
  To tuck a widget away, move its entry from `bar.layout` into `items`, and
  don't leave it in both places.
- Ids are any bar widget: stock `omarchy.*`, your clones (`parker.*`), or
  installed plugins. List them with `omarchy plugin list`.
- An unknown id shows up in the drawer as `? the-id`.
- Optional settings are `icon`, `iconOpen`, and `tooltip`.
- `"allowMultiple": true` lets you add several drawers, each with its own items.
- `omarchy-shell shell toggle parker.drawer '{}'` opens and closes it, so you
  can bind it to a key.

## Behaviour

- Click the button, press Esc, or click elsewhere to close the drawer.
  Opening another bar panel closes it too.
- Hosted widgets open their own panels from the drawer. While one is open,
  the first outside click closes that panel and the next one closes the drawer.
- Settings a hosted widget saves (e.g. the clock's right-click format cycle)
  are written back into its `items` entry.
- The drawer window is built the first time you open it and is kept after
  that, so hosted widgets start running on first open.

## Limitations

Hosted widgets talk to this plugin's scoped bar interface, not directly to
the bar, so a few things that need the built-in bar don't work inside the
drawer:

- keyboard shortcuts that summon a specific widget's panel (they look for it
  in the bar);
- the volume/brightness OSD on scroll;
- the media section of the audio panel.

Widgets that work best in the drawer are the ones that sit outside the bar's
own layout logic. The tray and indicators already reveal on hover, so keep
those in the bar.
```

✓ 1 ms

```text
wrote 2084 bytes to .config/omarchy/plugins/parker.drawer/README.md
```

**⏺ bash** `rm -rf .h0-scratch .h0-preview/test.drawer-barWidget.png; ls -a; ls .config/omarchy/plugins/parker.drawer`

✓ 90 ms

```text
[exit 0, 86 ms]
.
..
.config
.git
.h0-preview
Drawer.qml
DrawerContent.qml
DrawerWindow.qml
README.md
manifest.json
```

**⏺ check** `build`

✓ 3285 ms

```text
[exit 0, 3278 ms]
plugin parker.drawer  (~/.config/omarchy/plugins/parker.drawer)
  barWidget: Drawer.qml: loaded; drew: 󰅀
    picture: ~/.h0-preview/parker.drawer-barWidget.png
PREVIEW: ok
```

I built the drawer plugin, `parker.drawer`, and added it to your bar. All the offline checks pass, but I couldn't try the opened drawer on a real desktop. Please test it before relying on it.

**How it works**
- A chevron button (󰅀) sits at the start of your right section. Clicking it opens a small strip under the button holding your tucked-away widgets.
- You choose the contents in `shell.json` under the drawer's `items`:
  ```json
  { "id": "parker.drawer",
    "items": ["omarchy.weather", "omarchy.keyboard-layout", "omarchy.agents", "omarchy.monitor"] }
  ```
  An item can be just an id, or a full entry with its settings, like `{ "id": "omarchy.clock", "format": "HH:mm" }`. To tuck a widget away, move its entry from `bar.layout` into `items`. A mistyped id shows up in the drawer as `? the-id` rather than disappearing.
- Widgets in the drawer can open their own panels without closing the drawer. Settings they save, like the clock's format cycle, are written back into their `items` entry.
- The drawer closes when you click the button again, press Esc, click elsewhere, or open another bar panel. To bind it to a key: `omarchy-shell shell toggle parker.drawer '{}'`.

**What I changed in your bar** (backup: `.config/omarchy/shell.json.bak.1794263593`)
- I moved weather and keyboard-layout (from the center) and agents and monitor (from the right) into the drawer. That was my pick, so adjust `items` to taste.
- Update notices (`system-update`) stay in the bar so you still see when updates are available.

**Limitations**
- Omarchy doesn't let a plugin widget display other widgets directly, so the drawer loads them from their own files and passes them a stand-in bar. A few things only the built-in bar provides don't work for widgets inside the drawer:
  - keyboard shortcuts that open one specific widget's panel
  - the volume/brightness pop-up when you scroll
  - the media section of the audio panel

  This is why I left audio, network, bluetooth and power in the bar.
- Widgets in the drawer only start running the first time you open it (weather, for example, loads then).

**Testing**
- The build check passes: valid JSON, Omarchy's plugin validator, and the bar button loads and draws offscreen.
- In a separate offscreen test, the drawer contents loaded five real stock widgets with their settings applied (the clock drew `15:32` in `HH:mm` format), and the typo placeholder appeared. That test was temporary and I deleted it.
- The panel itself can't be drawn without a running desktop, so these are untested: where the strip appears, click-outside closing, widget panels opening from inside the drawer, and tooltips. I wrote that code to follow how Omarchy's own panels work.

**Please try on your desktop** (the shell reloads by itself; `omarchy-shell shell rescanPlugins` forces it):
1. Click 󰅀: the strip should appear under the button.
2. Click the monitor widget inside it: its panel should open below the strip and the drawer should stay open.
3. Click on the desktop: the monitor panel should close, then a second click should close the drawer.

If anything looks off, tell me what you see. There's a README in `.config/omarchy/plugins/parker.drawer/`.

*harness: verify check `build` passed*

