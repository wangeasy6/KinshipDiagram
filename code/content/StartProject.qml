import QtQuick 6.2
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Qt.labs.platform

Rectangle {
    id: thisPage
    width: 640
    height: 480

    property var historyList: null
    signal openMap(string path)

    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 8
        verticalOffset: 10
        color: "#C0CCCCCC"
        spread: 0
    }

    NewProject {
        id: newProject
        visible: false
        z: 2

        onNewProject: (path, name) => {
                          pdb.newMap(path, name)
                          var filePath = path + "/" + name + "/" + name + ".sqlite3"
                          updateHistory(filePath)
                          openMap(filePath)
                      }
    }

    MessageDialog {
        id: errorMD
        title: qsTr("提示：")
        visible: false
        onAccepted: {
            errorMD.visible = false
        }
    }

    Row {
        anchors.centerIn: parent
        width: 620
        height: 460
        z: 1

        Rectangle {
            id: rectangle
            height: parent.height
            width: 200
            color: "#c763b8ff"
            border.width: 0

            ColumnLayout {
                anchors.top: parent.top
                anchors.topMargin: 15
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 15

                Button {
                    text: qsTr("新建图谱")
                    font.pointSize: 8
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    icon.source: "icons/add.svg"
                    icon.height: 21
                    icon.width: 21

                    onClicked: {
                        newProject.visible = true
                    }
                }

                FileDialog {
                    id: openFile
                    title: qsTr("选择图谱")
                    nameFilters: ["DB Files (*.sqlite3)"]

                    onAccepted: {
                        var filePath = file.toString().replace("file:///", "")
                        console.log("You selected:", filePath)
                        if ( pdb.checkMap(filePath) ) {
                            updateHistory(filePath)
                            openMap(filePath)
                        }
                        else
                        {
                            errorMD.text = qsTr("所选图谱不可用！")
                            errorMD.visible = true
                        }
                    }
                }

                Button {
                    text: qsTr("打开图谱")
                    font.pointSize: 8
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    icon.source: "icons/search.svg"
                    icon.height: 21
                    icon.width: 21

                    onClicked: openFile.open()
                }
            }
        }

        Rectangle {
            height: parent.height
            width: 420
            color: "#c7ffc0cb"

            ColumnLayout {
                width: parent.width
                height: parent.height
                spacing: 5

                Label {
                    id: title
                    height: 30
                    text: openedList.count === 0 ? qsTr("暂无历史打开！") : qsTr("历史打开：")
                    verticalAlignment: Text.AlignVCenter
                    Layout.preferredHeight: 40
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    Layout.rightMargin: 10
                    Layout.leftMargin: 10
                    font.pointSize: 10
                }

                ListModel {
                    id: openedList
                }

                ListView {
                    model: openedList
                    spacing: 5
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.rightMargin: 10
                    Layout.leftMargin: 10
                    Layout.bottomMargin: 10
                    clip: true
                    orientation: ListView.Vertical
                    interactive: true

                    delegate: Button {
                        height: 45
                        width: openedList.width
                        text: path
                        font.pointSize: 6
                        hoverEnabled: true
                        icon.height: 20
                        icon.width: 20
                        icon.source: "icons/arrow-forward-outline.svg"
                        display: AbstractButton.TextBesideIcon
                        clip: true

                        onClicked: {
                            updateHistory(path)
                            openMap(path)
                        }
                    }
                }
            }
        }
    }

    function updateHistory(path) {
        var findIndex = 0
        for (; findIndex < openedList.count; findIndex++) {
            if (path === openedList.get(findIndex).path)
                break
        }

        console.log(findIndex, ",", openedList.count)
        if (findIndex === openedList.count)
            openedList.insert(0, {
                                  "path": path
                              })
        else
            openedList.move(findIndex, 0, 1)
    }

    Component.onCompleted: {
        if (historyList) {
            for (var i = 0; i < historyList.length; i++)
                openedList.append({
                                      "path": historyList[i]
                                  })
        }
    }
}
