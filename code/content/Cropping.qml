import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts
import Qt.labs.platform
import Qt5Compat.GraphicalEffects

Rectangle {
    id: thisPage
    width: 500
    height: 700

    // property var fileUtils
    property string avatarPath
    property string pathPrefix
    property string rename
    property bool saveFlag: false
    signal saved(string path)

    ColumnLayout {
        RowLayout {
            Layout.fillWidth: true
            height: 50
            spacing: 20

            Label {
                text: "照片裁剪："
                font.pointSize: 14
            }

            TextField {
                id: textAvatarPath
                width: 290
                height: 36
                text: avatar.source
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 10

                Keys.onReturnPressed: {
                    avatar.source = text
                }
            }

            FileDialog {
                id: selectAvatarFileDialog
                title: "Select a Photo"
                currentFile: avatar.source
                nameFilters: ["Image Files (*.png *.jpeg *.jpg *.bmp *.webp)"]

                onAccepted: {
                    console.log("You selected:", selectAvatarFileDialog.file)
                    avatar.source = selectAvatarFileDialog.file

                    if (rename) {
                        picName.text = rename
                    } else {
                        var lastSlashIndex = avatarPath.lastIndexOf("/")
                        if (lastSlashIndex !== -1) {
                            picName.text = avatarPath.substring(
                                        lastSlashIndex + 1)
                        }
                    }
                }
            }

            ToolButton {
                id: selectAvatar
                width: 40
                height: 40
                display: AbstractButton.IconOnly
                icon.source: "icons/elipsis.svg"
                rightPadding: 0
                leftPadding: 0
                bottomPadding: 0
                topPadding: 0
                onClicked: selectAvatarFileDialog.open()
            }
        }

        Rectangle {
            width: 500
            height: 500
            clip: true

            Image {
                id: avatar
                source: avatarPath
                fillMode: Image.PreserveAspectFit
                visible: true
                smooth: true
                z: 2

                transform: Scale {
                    id: scaleTransform
                    // xScale: 1
                    // yScale: 1
                }

                onStatusChanged: {
                    if (status === Image.Ready) {
                        // console.log("[Cropping] Avatar:", source)
                        avtarDisplayAdjust()
                    }
                }
            }

            Image {
                id: avatarCrop
                source: avatar.source
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: false

                onStatusChanged: {
                    if (status === Image.Ready) {
                        // console.log("[Cropping] Avatar crop:", source)
                        onSave()
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.OpenHandCursor
                drag.target: avatar
                drag.axis: Drag.XAndYAxis

                // propagateComposedEvents: true
                onPressed: {
                    mask.opacity = 0.5
                    cursorShape = Qt.ClosedHandCursor
                }

                onReleased: {
                    mask.opacity = 0.8
                    cursorShape = Qt.OpenHandCursor
                }

                onWheel: wheel => {

                             // console.log("onWheel")
                             // console.log(wheel.x, wheel.y, avatar.x, avatar.y)
                             var scaleValue = 1.1
                             if (wheel.angleDelta.y > 0) {
                                 // 放大
                                 scaleTransform.xScale *= scaleValue
                                 scaleTransform.yScale *= scaleValue

                                 if (wheel.x > avatar.x) {
                                     avatar.x -= (wheel.x - avatar.x) * 0.11
                                 } else {
                                     avatar.x += (avatar.x - wheel.x) * 0.11
                                 }
                                 if (wheel.y > avatar.y) {
                                     avatar.y -= (wheel.y - avatar.y) * 0.11
                                 } else {
                                     avatar.y += (avatar.y - wheel.y) * 0.11
                                 }
                             } else {
                                 // 缩小
                                 scaleTransform.xScale /= scaleValue
                                 scaleTransform.yScale /= scaleValue

                                 if (wheel.x > avatar.x) {
                                     avatar.x += (wheel.x - avatar.x) * 0.1
                                 } else {
                                     avatar.x -= (avatar.x - wheel.x) * 0.1
                                 }
                                 if (wheel.y > avatar.y) {
                                     avatar.y += (wheel.y - avatar.y) * 0.1
                                 } else {
                                     avatar.y -= (avatar.y - wheel.y) * 0.1
                                 }
                             }

                             avatar.x = Math.round(avatar.x)
                             avatar.y = Math.round(avatar.y)
                             // console.log(wheel.x, wheel.y, avatar.x, avatar.y)
                         }
            }

            Image {
                source: "icons/inch-frame.png"
                fillMode: Image.PreserveAspectCrop
                visible: true
                anchors.centerIn: parent
                z: 3
            }

            Image {
                id: mask
                source: "icons/inch-mask.png"
                anchors.centerIn: parent
                smooth: true
                visible: true
                opacity: 0.8
                z: 2
            }
        }

        Row {
            spacing: 10
            Layout.preferredHeight: 50
            Layout.fillWidth: true
            Label {
                text: qsTr("重命名：")
                anchors.verticalCenter: parent.verticalCenter
                leftPadding: 5
                font.pointSize: 14
            }

            TextField {
                id: picName
                height: 36
                Layout.preferredHeight: 42
                Layout.fillWidth: true
                text: ""
                anchors.verticalCenter: parent.verticalCenter
                onTextChanged: {
                    var targetFile = pathPrefix + text
                    if (fileUtils.isFileExist(targetFile)) {
                        notes.text = "将覆盖同名文件！"
                    }
                }
            }

            Label {
                id: notes
                text: ""
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 5
                color: "red"
                font.pointSize: 11
            }
        }

        Row {
            Layout.fillWidth: true
            Layout.fillHeight: true
            leftPadding: 85
            layoutDirection: Qt.LeftToRight
            spacing: 86
            Button {
                id: btCancel
                text: qsTr("取消")
                Layout.bottomMargin: 10
                Layout.topMargin: 10
                bottomPadding: 12
                topPadding: 12
                rightPadding: 40
                leftPadding: 40
                // Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pointSize: 16

                onClicked: {
                    thisPage.visible = false
                }
            }

            Button {
                id: btSaveInfo
                text: qsTr("确定")
                Layout.bottomMargin: 10
                Layout.topMargin: 10
                bottomPadding: 12
                topPadding: 12
                rightPadding: 40
                leftPadding: 40
                // Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pointSize: 16

                onClicked: {
                    // console.log(avatar.x, avatar.y, scaleTransform.xScale)
                    var x = (125 - avatar.x) / scaleTransform.xScale
                    var y = (75 - avatar.y) / scaleTransform.yScale
                    var w = 250 / scaleTransform.xScale
                    var h = 350 / scaleTransform.yScale

                    // When setting the sourceClipRect, the image will reload;
                    // therefore, set the saveFlag to wait for Image.Ready.
                    avatarCrop.sourceClipRect = Qt.rect(x, y, w, h)
                    saveFlag = true
                }
            }
        }
    }

    function onSave() {
        if (!saveFlag)
            return

        avatarCrop.grabToImage(function (result) {
            if (picName.text) {
                result.saveToFile(conf.dbPrefix + picName.text)
                saved(conf.dbPrefix + picName.text)
            }
        })
        saveFlag = false
        thisPage.visible = false
    }

    onRenameChanged: {
        picName.text = rename
    }

    function avtarDisplayAdjust() {
        // avtar zoom and center display
        var maxPix
        var minPix
        var p

        // console.log("avtarDisplayAdjust0:",
        //     avatar.sourceSize.width, avatar.sourceSize.height)
        scaleTransform.xScale = 1
        scaleTransform.yScale = 1
        if (avatar.sourceSize.width > avatar.sourceSize.height) {
            maxPix = avatar.sourceSize.width
            minPix = avatar.sourceSize.height
            if (maxPix <= 500) {
                avatar.x = (500 - avatar.sourceSize.width) / 2
                avatar.y = (500 - avatar.sourceSize.height) / 2
                return
            }

            p = maxPix / 500
            avatar.x = 0
            avatar.y = (500 - (minPix / p)) / 2
        } else {
            maxPix = avatar.sourceSize.height
            minPix = avatar.sourceSize.width
            if (maxPix <= 500) {
                avatar.x = (500 - avatar.sourceSize.width) / 2
                avatar.y = (500 - avatar.sourceSize.height) / 2
                return
            }

            p = maxPix / 500
            avatar.y = 0
            avatar.x = (500 - (minPix / p)) / 2
        }

        scaleTransform.xScale /= p
        scaleTransform.yScale /= p

        // console.log("avtarDisplayAdjust2:",
        //     avatar.width, avatar.height, avatar.x, avatar.y, scaleTransform.xScale)
    }

    Component.onCompleted: {
        if (rename) {
            picName.text = rename
        } else {
            var lastSlashIndex = avatarPath.lastIndexOf("/")
            if (lastSlashIndex !== -1) {
                picName.text = avatarPath.substring(lastSlashIndex + 1)
            }
        }

        avtarDisplayAdjust()
    }
}
