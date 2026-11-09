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
  property var drawer: null
  // Inert until Drawer.qml assigns `drawer` right after creation, so no
  // binding below ever reads a property of null.
  readonly property var d: drawer || idle
  QtObject {
    id: idle
    readonly property QtObject hostBarApi: QtObject {
      readonly property string position: "top"
      readonly property int barSize: Style.bar.sizeHorizontal
      readonly property bool vertical: false
      readonly property string fontFamily: Style.font.family
    }
    readonly property var barWindow: null
    readonly property bool drawerOpen: false
    readonly property var hostedPopout: null
    readonly property QtObject tooltipModel: QtObject {
      readonly property var target: null
      readonly property string text: ""
      readonly property bool shown: false
    }
    readonly property Item anchorButton: null
    readonly property var items: []
    readonly property var itemIds: []
    readonly property var widgetUrls: ({})
    readonly property bool resolved: false
    function close() {}
  }

  property alias content: drawerContent

  readonly property string pos: d.hostBarApi.position
  readonly property bool sideBar: pos === "left" || pos === "right"
  readonly property real barW: d.barWindow ? d.barWindow.width : d.hostBarApi.barSize
  readonly property real barH: d.barWindow ? d.barWindow.height : d.hostBarApi.barSize
  readonly property int gap: Style.gapsOut
  readonly property int margin: Style.gapsOut
  readonly property real screenW: screen ? screen.width : 0
  readonly property real screenH: screen ? screen.height : 0

  screen: d.barWindow ? d.barWindow.screen : null
  visible: d.drawerOpen || card.opacity > 0
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.namespace: "parker-drawer"
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.keyboardFocus: d.drawerOpen && !d.hostedPopout ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

  anchors {
    top: drawerWindow.pos !== "bottom"
    bottom: drawerWindow.pos !== "top"
    left: drawerWindow.pos !== "right"
    right: drawerWindow.pos !== "left"
  }
  implicitWidth: sideBar ? Math.ceil(barW + gap + card.width) : 0
  implicitHeight: sideBar ? 0 : Math.ceil(barH + gap + card.height)

  mask: Region { item: card }

  // Click outside the drawer (and outside the bar) closes it. Suspended
  // while a hosted panel is open: that panel dismisses itself first.
  HyprlandFocusGrab {
    active: d.drawerOpen && !d.hostedPopout && !!d.barWindow
    windows: d.barWindow ? [drawerWindow, d.barWindow] : [drawerWindow]
    // The guard covers the grab being dropped because a hosted panel opened.
    onCleared: if (!d.hostedPopout) d.close()
  }

  TransformWatcher {
    id: anchorWatcher
    a: d.barWindow ? d.barWindow.contentItem : null
    b: d.anchorButton
  }

  readonly property point buttonPos: {
    anchorWatcher.transform
    if (!d.barWindow || !d.anchorButton) return Qt.point(0, 0)
    return d.anchorButton.mapToItem(d.barWindow.contentItem, 0, 0)
  }

  BorderSurface {
    id: card

    readonly property int pad: Style.spacing.sm

    x: {
      if (drawerWindow.pos === "left") return drawerWindow.barW + drawerWindow.gap
      if (drawerWindow.pos === "right") return 0
      var want = drawerWindow.buttonPos.x + (d.anchorButton ? d.anchorButton.width : 0) / 2 - width / 2
      return Math.round(Math.max(drawerWindow.margin, Math.min(want, drawerWindow.screenW - width - drawerWindow.margin)))
    }
    y: {
      if (drawerWindow.pos === "top") return drawerWindow.barH + drawerWindow.gap
      if (drawerWindow.pos === "bottom") return 0
      var want = drawerWindow.buttonPos.y + (d.anchorButton ? d.anchorButton.height : 0) / 2 - height / 2
      return Math.round(Math.max(drawerWindow.margin, Math.min(want, drawerWindow.screenH - height - drawerWindow.margin)))
    }
    width: Math.ceil(drawerContent.implicitWidth + pad * 2 + Border.left(borderSpec) + Border.right(borderSpec))
    height: Math.ceil(drawerContent.implicitHeight + pad * 2 + Border.top(borderSpec) + Border.bottom(borderSpec))
    color: Color.popups.background
    borderSpec: Border.surfaceSpec("popups", "border", Color.popups.border, Math.max(1, Style.space(2)))
    radius: Style.cornerRadius
    opacity: d.drawerOpen ? 1 : 0

    Behavior on opacity {
      NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
    }

    Item {
      anchors.fill: parent
      focus: d.drawerOpen
      Keys.onEscapePressed: d.close()
    }

    DrawerContent {
      id: drawerContent
      anchors.centerIn: parent
      hostBar: d.hostBarApi
      items: d.items
      itemIds: d.itemIds
      widgetUrls: d.widgetUrls
      resolved: d.resolved
    }
  }

  PopupWindow {
    id: tooltipWindow

    readonly property var target: d.tooltipModel.target

    visible: d.drawerOpen && d.tooltipModel.shown && !!target && d.tooltipModel.text !== ""
    color: "transparent"
    implicitWidth: Math.ceil(bubble.implicitWidth)
    implicitHeight: Math.ceil(bubble.implicitHeight)

    anchor {
      id: tooltipAnchor
      window: drawerWindow
      adjustment: PopupAdjustment.Slide
      edges: Edges.Top | Edges.Left
      gravity: Edges.Bottom | Edges.Right
      rect.width: 1
      rect.height: 1

      onAnchoring: {
        var t = tooltipWindow.target
        if (!t) return
        var w = tooltipWindow.implicitWidth
        var h = tooltipWindow.implicitHeight
        var lx = t.width / 2 - w / 2, ly = t.height + 6
        if (drawerWindow.pos === "bottom") ly = -h - 6
        else if (drawerWindow.pos === "left") { lx = t.width + 6; ly = t.height / 2 - h / 2 }
        else if (drawerWindow.pos === "right") { lx = -w - 6; ly = t.height / 2 - h / 2 }
        var p = drawerWindow.contentItem.mapFromItem(t, lx, ly)
        tooltipAnchor.rect.x = Math.round(p.x)
        tooltipAnchor.rect.y = Math.round(p.y)
      }
    }

    BorderSurface {
      id: bubble
      implicitWidth: tipLabel.implicitWidth + 20
      implicitHeight: tipLabel.implicitHeight + 10
      anchors.fill: parent
      color: Color.tooltip.background
      borderSpec: Border.flat(Color.tooltip.border, 1)
      radius: Style.cornerRadius

      Text {
        id: tipLabel
        anchors.centerIn: parent
        text: d.tooltipModel.text
        color: Color.tooltip.text
        font.family: d.hostBarApi.fontFamily
        font.pixelSize: Style.bar.iconFont * 0.8
      }
    }
  }
}
