import QtQuick 6.2
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform
import Qt5Compat.GraphicalEffects

Rectangle {
    id: thisPage
    width: 380
    height: 200
    // anchors.centerIn: parent
    x: parent.width / 2 - width / 2
    y: parent.height / 2 - height / 2
    color: "white"
    opacity: 1

    signal newProject(string path, string name)

    // Prevent event penetration
    focus: true
    Keys.onPressed: {
        event.accepted = true
    }

    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 8
        verticalOffset: 10
        color: "#C0CCCCCC"
        spread: 0
    }

    Rectangle {
        width: 360
        height: 180
        anchors.centerIn: parent
        color: "#c7B9D3EE"

        ColumnLayout {
            id: column
            width: 360
            height: 180
            anchors.centerIn: parent

            GridLayout {
                width: 340
                rowSpacing: 10
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                columns: 2

                Label {
                    text: qsTr(" 路径：")
                    font.pointSize: 10
                }

                RowLayout {
                    spacing: 5

                    TextField {
                        id: textPath
                        Layout.preferredHeight: 40
                        Layout.minimumWidth: 90
                        Layout.fillWidth: true

                        onTextChanged: {
                            checkInput()
                        }
                    }

                    FolderDialog {
                        id: selectFolder
                        visible: false
                        title: qsTr("选择存放路径")

                        onAccepted: {
                            textPath.text = folder.toString().replace(
                                        "file:///", "")
                        }
                    }

                    ToolButton {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        display: AbstractButton.IconOnly
                        icon.source: "icons/elipsis.svg"
                        ToolTip.text: qsTr("路径选择")
                        ToolTip.delay: 500
                        ToolTip.visible: hovered

                        onClicked: {
                            selectFolder.open()
                        }
                    }
                }

                Label {
                    text: qsTr(" 族谱名：")
                    font.pointSize: 10
                }

                RowLayout {
                    spacing: 5

                    TextField {
                        id: textName
                        Layout.preferredHeight: 40
                        Layout.fillWidth: true

                        onTextChanged: {
                            checkInput()
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
                        if (checkInput()) {
                            newProject(textPath.text, textName.text)
                            thisPage.visible = false
                        } else {
                            shakeSequence.start()
                        }
                    }
                }
            }
        }
    }

    function checkInput() {
        if (!textPath.text) {
            checkError.text = qsTr("*请选择文件夹！")
            return false
        }
        if (!fileUtils.isFolderExist(textPath.text)) {
            checkError.text = qsTr("*路径不存在！")
            return false
        }

        textName.text = textName.text.trim()
        if (!textName.text) {
            checkError.text = qsTr("*请输入图谱名！")
            return false
        }

        if (fileUtils.isFolderExist(textPath.text + "/" + textName.text)) {
            checkError.text = qsTr("*文件夹已存在！")
            return false
        }

        checkError.text = ""
        return true
    }

    SequentialAnimation {
        id: shakeSequence
        PropertyAnimation {
            target: thisPage
            property: "x"
            to: thisPage.x - 10
            duration: 20
        }
        PropertyAnimation {
            target: thisPage
            property: "x"
            to: thisPage.x + 10
            duration: 40
        }
        PropertyAnimation {
            target: thisPage
            property: "x"
            to: thisPage.x - 10
            duration: 40
        }
        PropertyAnimation {
            target: thisPage
            property: "x"
            to: thisPage.x
            duration: 20
        }
    }
}
