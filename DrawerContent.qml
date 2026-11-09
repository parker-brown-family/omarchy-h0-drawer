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
        readonly property var entrySettings: root.settingsOf(entry)
        readonly property string url: root.widgetUrls[modelData] || ""
        readonly property bool missing: root.resolved && url === ""
        readonly property Item hosted: loader.item
        readonly property bool shows: !!hosted && hosted.visible

        implicitWidth: shows ? (root.vertical ? root.barSize : hosted.implicitWidth)
          : (missing ? missingLabel.implicitWidth + Style.spacing.md * 2 : 0)
        implicitHeight: shows ? (root.vertical ? hosted.implicitHeight : root.barSize)
          : (missing ? root.barSize : 0)
        width: implicitWidth
        height: implicitHeight

        // Same injection the bar's own module slots do.
        function inject() {
          var item = loader.item
          if (!item) return
          if ("bar" in item) item.bar = root.hostBar
          if ("moduleName" in item) item.moduleName = slot.modelData
          if ("settings" in item) item.settings = slot.entrySettings
        }

        onEntrySettingsChanged: inject()
        Component.onCompleted: root.hostedSlots = root.hostedSlots.concat([slot])
        Component.onDestruction: {
          // Let an open panel release its popout before the widget goes away.
          if (loader.item && typeof loader.item.close === "function") loader.item.close()
          root.hostedSlots = root.hostedSlots.filter(function(s) { return s !== slot })
        }

        Loader {
          id: loader
          anchors.fill: parent
          active: slot.url !== ""
          source: slot.url
          onLoaded: {
            slot.inject()
            Qt.callLater(slot.inject)
          }
          onStatusChanged: if (status === Loader.Error)
            console.warn("parker.drawer: could not load " + slot.modelData + " from " + slot.url)
        }

        // An id that matches no installed bar widget shows up here instead of
        // disappearing silently, so a typo in shell.json is visible.
        Text {
          id: missingLabel
          anchors.centerIn: parent
          visible: slot.missing
          text: "? " + slot.modelData
          color: Color.muted
          font.family: root.hostBar ? root.hostBar.fontFamily : Style.font.family
          font.pixelSize: Math.round(Style.bar.iconFont * 0.85)
        }
      }
    }

    Text {
      readonly property bool empty: root.hostedSlots.every(function(s) { return !s || s.width <= 0 })
      visible: empty
      width: visible ? implicitWidth + Style.spacing.md * 2 : 0
      height: visible ? root.barSize : 0
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      text: root.itemIds.length === 0 ? "Drawer is empty: list widget ids in \"items\"" : "Nothing to show right now"
      color: Color.muted
      font.family: root.hostBar ? root.hostBar.fontFamily : Style.font.family
      font.pixelSize: Math.round(Style.bar.iconFont * 0.85)
    }
  }
}
