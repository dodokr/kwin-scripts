// Screen Focus OSD (On-Screen Display)
//
// Shows a short popup ("Screen N" plus the output name) centered on the screen
// that just received focus. The card pops in, holds briefly and squishes away.
//
// It listens to Workspace.windowActivated and fires when the newly active
// window is on a different output than the previous one. Switching to an
// empty screen activates no window, so no popup is shown in that case.
//
// A "Show Current Screen" shortcut (unbound by default) shows the same popup
// on demand for the current screen, e.g. to check where you are.

import QtQuick
import org.kde.kwin
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

Item {
    id: root

    property var lastOutput: null

    // Tweak these
    readonly property int boxWidth:  360
    readonly property int boxHeight: 220
    readonly property int popMs:     50
    readonly property int holdMs:    150
    readonly property int squishMs:  50

    function show(output) {
        var n = Workspace.screens.indexOf(output) + 1;
        label.text = "Screen " + n;
        sub.text = output.name;

        var g = output.geometry;
        dlg.x = g.x + Math.round((g.width - boxWidth) / 2);
        dlg.y = g.y + Math.round((g.height - boxHeight) / 2);

        anim.stop();
        card.scale = 0.5;
        card.opacity = 0;
        dlg.visible = true;
        anim.start();
    }

    // Popup for whichever screen is current right now (used by the shortcut).
    function showCurrent() {
        var output = Workspace.activeScreen
            || (Workspace.activeWindow ? Workspace.activeWindow.output : null)
            || Workspace.screens[0];
        if (!output)
            return;
        lastOutput = output;
        show(output);
    }

    Connections {
        target: Workspace
        function onWindowActivated(window) {
            if (!window || !window.output || window.output === root.lastOutput)
                return;
            root.lastOutput = window.output;
            root.show(window.output);
        }
    }

    // Unbound by default: assign a key in System Settings → Keyboard →
    // Shortcuts → KWin ("Show Current Screen"). Uses the same dialog as the
    // focus-change popup, so the two can never be on screen at the same time.
    ShortcutHandler {
        name: "Show Current Screen"
        text: "Show Current Screen"
        sequence: ""
        onActivated: root.showCurrent()
    }

    PlasmaCore.Dialog {
        id: dlg
        visible: false
        location: PlasmaCore.Types.Floating
        type: PlasmaCore.Dialog.OnScreenDisplay
        backgroundHints: PlasmaCore.Types.NoBackground
        flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.WindowDoesNotAcceptFocus

        mainItem: Item {
            width: root.boxWidth
            height: root.boxHeight

            Rectangle {
                id: card
                anchors.fill: parent
                radius: 28
                color: Kirigami.Theme.backgroundColor
                border.color: Kirigami.Theme.highlightColor
                border.width: 3
                transformOrigin: Item.Center

                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        id: label
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Kirigami.Theme.textColor
                        font.pixelSize: 56
                        font.bold: true
                    }
                    Text {
                        id: sub
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Kirigami.Theme.disabledTextColor
                        font.pixelSize: 22
                    }
                }
            }
        }
    }

    SequentialAnimation {
        id: anim
        ParallelAnimation {
            NumberAnimation { target: card; property: "scale"; to: 1.0; duration: root.popMs; easing.type: Easing.OutBack }
            NumberAnimation { target: card; property: "opacity"; to: 1.0; duration: root.popMs }
        }
        PauseAnimation { duration: root.holdMs }
        ParallelAnimation {
            NumberAnimation { target: card; property: "scale"; to: 0.0; duration: root.squishMs; easing.type: Easing.InBack }
            NumberAnimation { target: card; property: "opacity"; to: 0.0; duration: root.squishMs }
        }
        ScriptAction { script: dlg.visible = false }
    }
}
