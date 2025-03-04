import QtQuick 6.2
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Rectangle {
    id: thisPage
    width: 320
    height: 240
    radius: 10
    anchors.centerIn: parent

    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 15
        verticalOffset: 20
        color: "#C0CCCCCC"
        spread: 0
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        // anchors.leftMargin: 10
        // anchors.rightMargin: 10
        // anchors.topMargin: 10
        // anchors.bottomMargin: 10
        Label {
            text: "Help Info"
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 16
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
        }

        TextArea {
            text: "* Author: Easy Wang\r\n* Version: 0.14.5\r\n* Based: QtQuick 6.2"
            wrapMode: Text.Wrap
            Layout.fillHeight: false
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
            textFormat: Text.MarkdownText
            readOnly: true
        }

        Button {
            text: "Ok"
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            onClicked: {
                thisPage.destroy()
            }
        }
    }
}
