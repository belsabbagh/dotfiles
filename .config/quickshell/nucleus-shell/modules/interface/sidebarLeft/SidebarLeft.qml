import qs.config
import qs.modules.components
import qs.modules.functions
import qs.services
import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

PanelWindow {
    id: sidebarLeft
    WlrLayershell.namespace: "nucleus:sidebarLeft"
    WlrLayershell.layer: WlrLayer.Top
    visible: Config.initialized && Globals.visiblility.sidebarLeft && !Globals.visiblility.sidebarRight
    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.keyboardFocus: Compositor.require("hyprland") && Globals.visiblility.sidebarLeft

    property real sidebarLeftWidth: 500

    implicitWidth: Compositor.screenW

    HyprlandFocusGrab {
        id: grab
        active: Compositor.require("hyprland")
        windows: [sidebarLeft]
    }

    anchors {
        top: true
        left: (Config.runtime.bar.position === "top" || Config.runtime.bar.position === "bottom" || Config.runtime.bar.position === "left")
        bottom: true
        right: (Config.runtime.bar.position === "right")
    }

    margins {
        top: Config.runtime.bar.margins
        bottom: Config.runtime.bar.margins
        left: Metrics.margin("small")
        right: Metrics.margin("small")
    }

    MouseArea {
        anchors.fill: parent
        z: 0
        onPressed: Globals.visiblility.sidebarLeft = false
    }

    StyledRect {
        id: container
        z: 1
        color: Appearance.m3colors.m3background
        radius: Metrics.radius("large")
        width: sidebarLeft.sidebarLeftWidth

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }

        FocusScope {
            focus: true
            anchors.fill: parent

            Keys.onPressed: {
                if (event.key === Qt.Key_Escape) {
                    Globals.visiblility.sidebarLeft = false;
                }
            }

            SidebarLeftContent {}
        }
    }

    function togglesidebarLeft() {
        Globals.visiblility.sidebarLeft = !Globals.visiblility.sidebarLeft;
    }

    IpcHandler {
        target: "sidebarLeft"
        function toggle() {
            togglesidebarLeft();
        }
    }
}
