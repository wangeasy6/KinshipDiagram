import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts
import Qt.labs.platform
import Qt5Compat.GraphicalEffects

Popup {
    id: thisPage
    width: 500
    height: 750
    anchors.centerIn: parent
    modal: true
    visible: true
    closePolicy: Popup.CloseOnEscape
    padding: 0

    property string avatarPath
    property string pathPrefix
    property string rename
    property bool saveFlag: false
    signal saved(string path)

    ColumnLayout {
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            spacing: 20

            Label {
                text: "照片裁剪："
                font.pointSize: 14
            }

            TextField {
                id: textAvatarPath
                Layout.fillWidth: true
                Layout.preferredHeight: 40
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
                modality: Qt.ApplicationModal

                onAccepted: {
                    console.log("You selected:", selectAvatarFileDialog.file)
                    avatar.source = selectAvatarFileDialog.file
                    avatar.rotation = 0

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

        Row {
            spacing: 10
            Layout.preferredHeight: 50
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10

            Label {
                text: qsTr("重命名：")
                anchors.verticalCenter: parent.verticalCenter
                leftPadding: 5
                font.pointSize: 14
            }

            TextField {
                id: picName
                height: 40
                width: 150
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

        Rectangle {
            id: avatarRect
            width: 500
            height: 500
            clip: true

            Image {
                id: avatar
                source: avatarPath
                fillMode: Image.PreserveAspectFit
                visible: true
                smooth: true
                z: 1

                transform: Scale {
                    id: avatarScale
                    // xScale: 1
                    // yScale: 1
                }

                // onRotationChanged: {
                //     var rotatedPos = avatar.mapToItem(parent, 0, 0)
                //     console.log("实际位置:", rotatedPos.x, rotatedPos.y)
                // }
                onStatusChanged: {
                    if (status === Image.Ready) {
                        // console.log("[Cropping] Avatar:", source)
                        avatar.rotation = 0
                        avtarDisplayAdjust()
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
                                 avatarScale.xScale *= scaleValue
                                 avatarScale.yScale *= scaleValue

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
                                 avatarScale.xScale /= scaleValue
                                 avatarScale.yScale /= scaleValue

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
                z: 2
            }

            Image {
                id: mask
                source: "icons/inch-mask.png"
                anchors.centerIn: parent
                smooth: true
                visible: true
                opacity: 0.8
                z: 1
            }
        }

        Row {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 50
            spacing: 10

            ToolButton {
                width: 50
                height: 50
                icon.height: 30
                icon.width: 30
                icon.source: "icons/anticlockwise.svg"
                anchors.verticalCenter: parent.verticalCenter
                display: AbstractButton.IconOnly

                ToolTip {
                    text: "逆时针旋转"
                    delay: 500
                    visible: parent.hovered
                    z: 3
                }

                onClicked: {
                    checkRotationText()
                    avatar.rotation -= parseInt(textRotation.text)
                }
            }

            TextField {
                id: textRotation
                height: 40
                anchors.verticalCenter: parent.verticalCenter
                width: 60
                text: "90"

                Text {
                    anchors {
                        top: parent.top
                        right: parent.right
                    }
                    // topPadding: 2
                    rightPadding: 2
                    text: "°"
                    font.pixelSize: 24
                }

                onEditingFinished: {
                    checkRotationText()
                }
            }

            ToolButton {
                width: 50
                height: 50
                icon.height: 30
                icon.width: 30
                icon.source: "icons/clockwise.svg"
                anchors.verticalCenter: parent.verticalCenter
                display: AbstractButton.IconOnly

                ToolTip {
                    text: "顺时针旋转"
                    delay: 500
                    visible: parent.hovered
                    z: 3
                }

                onClicked: {
                    checkRotationText()
                    avatar.rotation += parseInt(textRotation.text)
                }
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
                    // console.log("avatar: ", avatar.x, avatar.y,
                    //             avatarScale.xScale)
                    // console.log("avatar: ", avatar.width, avatar.height)

                    var x = (125 - avatar.x) / avatarScale.xScale
                    var y = (75 - avatar.y) / avatarScale.yScale
                    // Relative to the center point
                    x -= avatar.width / 2
                    y -= avatar.height / 2
                    var w = 250 / avatarScale.xScale
                    var h = 350 / avatarScale.yScale

                    var filePath = conf.dbPrefix + picName.text
                    var ret = fileUtils.saveClipImg(avatar.source, filePath,
                                                    Qt.rect(x, y, w, h),
                                                    avatar.rotation)
                    if (ret)
                        saved(filePath)
                    saveFlag = false
                    thisPage.visible = false
                }
            }
        }
    }

    function checkRotationText() {
        var num = parseInt(textRotation.text)
        if (isNaN(num)) {
            textRotation.text = "0"
        } else {
            while (num < 0)
                num += 360
            num %= 360
            textRotation.text = num
        }
    }

    function onSave() {
        if (!saveFlag)
            return

        console.log("avatarCrop.rotation", avatarCrop.rotation)
        // console.log("avatarCrop.Angle", avatarCropAngle.angle)
        avatarCropItem.grabToImage(function (result) {
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
        avatarScale.xScale = 1
        avatarScale.yScale = 1
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

        avatarScale.xScale /= p
        avatarScale.yScale /= p

        // console.log("avtarDisplayAdjust2:",
        //     avatar.width, avatar.height, avatar.x, avatar.y, avatarScale.xScale)
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
