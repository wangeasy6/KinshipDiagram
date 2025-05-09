import QtQuick 6.2
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: thisPage
    width: 700
    height: 750
    anchors.centerIn: parent
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    visible: true

    Rectangle {
        anchors.fill: parent
        radius: 10

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10

            Label {
                text: qsTr("软件信息")
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 16
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.fillWidth: true
            }

            TextArea {
                text: "* Author: **Easy Wang**\r\n* Version: **0.17.0**\r\n* Based: **QtQuick 6.2**"
                wrapMode: Text.Wrap
                Layout.fillHeight: false
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                textFormat: Text.MarkdownText
                readOnly: true
            }

            Label {
                text: qsTr("用户指南")
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 16
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.fillWidth: true
            }

            ScrollView {
                Layout.preferredHeight: 400
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter

                ScrollBar.vertical: ScrollBar {
                    x: parent.width - width
                    y: 10
                    height: parent.height - 10
                }

                TextArea {
                    id: userManual
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    readOnly: true
                    implicitWidth: parent.width
                }
            }

            Button {
                text: "Ok"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                onClicked: {
                    thisPage.destroy()
                }
            }
        }
    }

    Component.onCompleted: {
        fileUtils.loadFile("docs/user_manual_" + conf.language + ".html",
                           userManual)
    }
}
