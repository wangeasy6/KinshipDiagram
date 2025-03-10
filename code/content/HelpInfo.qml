import QtQuick 6.2
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: thisPage
    width: 320
    height: 240
    anchors.centerIn: parent
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    visible : true

    Rectangle {
        anchors.fill: parent
        radius: 10

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10

            Label {
                text: "Help Info"
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 16
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.fillWidth: true
            }

            TextArea {
                text: "* Author: Easy Wang\r\n* Version: 0.14.6\r\n* Based: QtQuick 6.2"
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
}
