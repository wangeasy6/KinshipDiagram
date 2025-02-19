import QtQuick 6.2
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform
import Qt5Compat.GraphicalEffects

Rectangle {
    id: thisPage
    width: 360
    height: 180
    anchors.centerIn: parent
    color: "white"
    opacity: 1

    signal newProject(string path, string name)

    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 8
        verticalOffset: 10
        color: "#C0CCCCCC"
        spread: 0
    }

    ColumnLayout {
        id: column
        width: 340
        height: 160
        anchors.centerIn: parent

        GridLayout {
            width: 340
            // height: 130
            rowSpacing: 10
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            columns: 2

            Label {
                text: qsTr("路径：")
                font.pointSize: 10
            }

            RowLayout {
                spacing: 5

                TextField {
                    id: textPath
                    Layout.preferredHeight: 40
                    Layout.minimumWidth: 90
                    Layout.fillWidth: true
                }

                FolderDialog {
                    id: selectFolder
                    visible: false
                    title: "Select a folder"

                    onAccepted: {
                        textPath.text = folder.toString().replace("file:///",
                                                                  "")
                        checkPath()
                    }
                }

                ToolButton {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    display: AbstractButton.IconOnly
                    icon.source: "icons/elipsis.svg"

                    onClicked: {
                        selectFolder.open()
                    }
                }
            }

            Label {
                text: qsTr("族谱名：")
                font.pointSize: 10
            }

            RowLayout {
                spacing: 5

                TextField {
                    id: textName
                    Layout.preferredHeight: 40
                    Layout.fillWidth: true

                    onTextEdited: {
                        checkPath()
                    }
                }

                Label {
                    id: checkError
                    color: "red"
                }
            }
        }

        Row {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            spacing: 40

            Button {
                id: btCancel
                text: qsTr("取消")
                bottomPadding: 12
                topPadding: 12
                rightPadding: 30
                leftPadding: 30
                font.pointSize: 12

                onClicked: {
                    thisPage.visible = false
                }
            }

            Button {
                id: btSaveInfo
                text: qsTr("确定")
                bottomPadding: 12
                topPadding: 12
                rightPadding: 30
                leftPadding: 30
                font.pointSize: 12

                onClicked: {

                    if (checkPath()) {
                        newProject(textPath.text, textName.text)
                        thisPage.visible = false
                    }
                }
            }
        }
    }

    function checkPath() {
        if (!textPath.text) {
            checkError.text = "*请选择文件夹！"
            return false
        }
        if (!textName.text) {
            checkError.text = "*请输入图谱名！"
            return false
        }

        if (fileUtils.isFolderExist(textPath.text + "/" + textName.text)) {
            checkError.text = "*文件夹已存在！"
            return false
        } else {
            checkError.text = ""
            return true
        }
    }
}
