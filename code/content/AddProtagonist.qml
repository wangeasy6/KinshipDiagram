import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts
import Qt.labs.platform

Popup {
    id: thisPage
    modal: true
    visible : true
    width: 1000
    height: 750
    padding: 0
    anchors.centerIn: parent
    closePolicy: Popup.NoAutoClose

    property var tempImages: new Set()
    signal finished(bool updateFlag)

    background: Rectangle {
        color: "#E5E5E5"
        radius: 10
    }

    MouseArea {
        anchors.fill: parent
    }

    MessageDialog {
        id: isCropMD
        title: qsTr("提示：")
        visible: false
        text: qsTr("是否裁剪照片？")
        // buttons: MessageDialog.Ok | MessageDialog.Cancel
        buttons: MessageDialog.No | MessageDialog.Yes

        onAccepted: {
            isCropMD.visible = false
            cropForm.avatarPath = selectAvatarFileDialog.file
            var filePath = selectAvatarFileDialog.file.toString()
            var lastSlashIndex = filePath.lastIndexOf("/")
            var selectPrefix = filePath.substring(0, lastSlashIndex + 1)
            if (selectPrefix.includes(conf.dbPrefix))
                cropForm.rename = filePath.substring(lastSlashIndex + 1)
            else {
                if (textName.text)
                    cropForm.rename = textName.text + pdb.getSettings().photoFormat
                else
                    cropForm.rename = filePath.substring(lastSlashIndex + 1)
            }
            cropForm.visible = true
        }

        onRejected: {
            isCropMD.visible = false
            console.log("Rename check")
            var filePath = selectAvatarFileDialog.file.toString()
            var lastSlashIndex = filePath.lastIndexOf("/")
            var selectPrefix
            var selectSuffix // = filePath.split(".").pop()
            if (lastSlashIndex !== -1) {
                selectPrefix = filePath.substring(0, lastSlashIndex + 1)
                console.log("selectPrefix:", selectPrefix)
                if (selectPrefix.includes(conf.dbPrefix)) {
                    console.log("In store.")
                    avatar.source = selectAvatarFileDialog.file
                } else {
                    // Copy file to store
                    lastSlashIndex = filePath.lastIndexOf(".")
                    selectSuffix = filePath.substring(lastSlashIndex)
                    var saveTo = conf.dbPrefix + textName.text + selectSuffix
                    console.log("Save to: ", saveTo)
                    tempImages.add(saveTo)
                    if (fileUtils.copyFileOverlay(filePath, saveTo))
                        avatar.source = saveTo
                }
            }
        }
    }

    Cropping {
        id: cropForm
        visible: false
        anchors.centerIn: parent
        pathPrefix: conf.dbPrefix
        z: 2

        onSaved: (path) => {
            console.log("Get path:", path)
            tempImages.add(path)
            avatar.source = path
            avatar.update()
        }
    }

    ColumnLayout {
        width: thisPage.width
        height: thisPage.height
        spacing: 10

        Label {
            id: title
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            color: "#ddffffff"
            // Layout.leftMargin: 20
            text: qsTr("添加人员：主人公")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: false
            bottomPadding: 10
            topPadding: 10
            font.pointSize: 18
            // color: "#21be2b"
            background: Rectangle {
                width: parent.width
                height: parent.height
                color: "#21be2b"
                radius: 10
                border.width: 0

                Rectangle {
                    y: title.height - 10
                    width: parent.width
                    height: 10
                    color: "#21be2b"
                    radius: 0
                    border.width: 0
                }
            }
        }

        RowLayout {
            spacing: 5
            Layout.margins: 15
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: 320
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                Image {
                    id: avatar
                    Layout.preferredHeight: 350
                    Layout.preferredWidth: 250
                    source: "icons/person.svg"
                    Layout.margins: 10
                    Layout.alignment: Qt.AlignHCenter
                    fillMode: Image.PreserveAspectFit
                    cache: false
                }

                Row {
                    id: pickAvatar
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    Layout.rightMargin: 10
                    Layout.leftMargin: 10
                    spacing: 20

                    TextField {
                        id: textAvatarPath
                        width: 250
                        height: 40
                        text: avatar.source
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 10
                    }

                    FileDialog {
                        id: selectAvatarFileDialog
                        title: qsTr("选择照片")
                        // selectFolder: false
                        // selectMultiple: false
                        // supportedSchemes: [ "file" ]
                        currentFile: avatar.source
                        nameFilters: ["Image Files (*.png *.jpeg *.jpg *.bmp)"]

                        onAccepted: {
                            console.log("You selected:", selectAvatarFileDialog.file)
                            isCropMD.visible = true
                        }
                    }

                    ToolButton {
                        id: selectAvatar
                        width: 40
                        height: 40
                        display: AbstractButton.IconOnly
                        icon.source: "icons/elipsis.svg"
                        font.pointSize: 20
                        rightPadding: 0
                        leftPadding: 0
                        bottomPadding: 0
                        topPadding: 0
                        onClicked: selectAvatarFileDialog.open()
                    }
                }
            }

            ColumnLayout {
                id: sideLayout
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                GridLayout {
                    id: peasonInfo
                    Layout.fillWidth: true
                    columns: 2
                    Layout.margins: 10
                    rowSpacing: 10

                    Label {
                        id: lbName
                        text: qsTr("姓名：")
                        font.pointSize: 14
                    }

                    TextField {
                        id: textName
                        Layout.preferredHeight: 45
                        Layout.fillWidth: true
                        text: ""
                    }

                    Label {
                        text: qsTr("性别：")
                        font.pointSize: 14
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Switch {
                            id: switchGender
                            Layout.preferredHeight: 45
                            text: switchGender.checked ? qsTr("女") : qsTr("男")
                            font.pointSize: 12
                        }

                        Label {
                            text: qsTr("已故：")
                            Layout.alignment: Qt.AlignVCenter
                            horizontalAlignment: Text.AlignRight
                            Layout.fillWidth: true
                            font.pointSize: 14
                        }

                        Switch {
                            id: switchDeath
                            leftPadding: 43
                            Layout.preferredHeight: 45
                            checked: false
                            text: switchDeath.checked ? qsTr("是") : qsTr("否")
                            font.pointSize: 12
                        }
                    }

                    Label {
                        id: lbCall
                        text: qsTr("称呼：")
                        font.pointSize: 14
                    }

                    Row {
                        spacing: 10
                        Layout.fillWidth: true

                        TextField {
                            id: textCall
                            width: parent.width - 80
                            height: 45
                        }

                        Button {
                            id: btGetCall
                            visible: false
                            height: 45
                            Layout.preferredWidth: 70
                            text: qsTr("计算")
                            bottomInset: 0
                            topInset: 0
                            rightPadding: 10
                            leftPadding: 10
                            bottomPadding: 0
                            topPadding: 0
                            font.pointSize: 10
                        }
                    }

                    Label {
                        id: lbSSAR
                        text: qsTr("家中排行：")
                        font.pointSize: 14
                    }

                    Row {
                        spacing: 15
                        TextField {
                            id: textSSAR
                            height: 45
                            Layout.preferredHeight: 45
                            Layout.fillWidth: true
                            font.pointSize: 12
                            text: "1"
                            onTextEdited: {
                                if (!isPositiveInteger(text)) {
                                    textSsarMsg.text = qsTr("请输入正整数！")
                                }
                            }
                        }

                        Label {
                            id: textSsarMsg
                            height: parent.height
                            font.pointSize: 10
                            verticalAlignment: Text.AlignVCenter
                            color: "red"
                        }
                    }

                    Label {
                        id: lbBirth
                        text: qsTr("生日：")
                        font.pointSize: 14
                    }

                    Row {
                        id: rowBirth
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        spacing: 10

                        YinYangSwitch {
                            id: birthSwitch
                            checked: false
                        }

                        TextField {
                            id: textBirth
                            height: 45
                            width: parent.width - birthSwitch.width - 10
                            text: ""
                        }
                    }

                    Label {
                        id: lbDeath
                        text: qsTr("忌日：")
                        font.pointSize: 14
                        visible: switchDeath.checked
                    }

                    Row {
                        id: rowDeath
                        visible: switchDeath.checked
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        spacing: 10

                        YinYangSwitch {
                            id: deathSwitch
                            checked: false
                        }

                        TextField {
                            id: textDeath
                            height: 45
                            width: parent.width - birthSwitch.width - 10
                            text: ""
                        }
                    }

                    Label {
                        id: lbNotes
                        text: qsTr("备注：")
                        font.pointSize: 14
                    }

                    ScrollView {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        clip: true

                        ScrollBar.vertical: ScrollBar {
                            x: parent.width - width
                            y: 11
                            height: parent.height - 11
                        }

                        TextArea {
                            id: textAreaNotes
                            width: parent.width
                            height: parent.height
                            wrapMode: Text.Wrap
                        }
                    }
                }

                Row {
                    leftPadding: 70
                    layoutDirection: Qt.LeftToRight
                    Layout.fillWidth: true
                    spacing: 61
                    Button {
                        id: btCancel
                        text: qsTr("取消")
                        Layout.bottomMargin: 10
                        Layout.topMargin: 10
                        bottomPadding: 12
                        topPadding: 12
                        rightPadding: 40
                        leftPadding: 40
                        font.pointSize: 16

                        onClicked: {
                            tempImages.forEach(function(path) {
                                fileUtils.deleteFile(path)
                            })
                            tempImages.clear()

                            thisPage.finished(false)
                            thisPage.destroy()
                        }
                    }

                    Button {
                        id: btSaveInfo
                        text: qsTr("保存")
                        Layout.bottomMargin: 10
                        Layout.topMargin: 10
                        bottomPadding: 12
                        topPadding: 12
                        rightPadding: 40
                        leftPadding: 40
                        font.pointSize: 16

                        onClicked: {
                            var currentPath = avatar.source.toString()
                            tempImages.forEach(function(path) {
                                if (path !== currentPath) {
                                    fileUtils.deleteFile(path)
                                }
                            })
                            tempImages.clear()
                            saveData()
                        }
                    }
                }
            }
        }
    }

    function isPositiveInteger(str) {
        var regex = /^[1-9]\d*$/
        return regex.test(str)
    }

    function saveData() {
        console.log("[AddProtagonist] Save data.")

        if (!isPositiveInteger(textSSAR.text))
            return

        var addPerson = pdb.newFirstPerson()
        if (addPerson) {
            if (textAvatarPath.text === "qrc:/qt/qml/content/icons/person.svg")
                addPerson.avatarPath = "icons/person.svg"
            else
                addPerson.avatarPath = textAvatarPath.text.replace(
                            conf.dbPrefix, "")
            addPerson.name = textName.text
            addPerson.gender = !switchGender.checked
            addPerson.call = textCall.text
            addPerson.birthTraditional = birthSwitch.checked
            // birth check??
            addPerson.birthday = textBirth.text

            // Ranking
            var ranking = parseInt(textSSAR.text) - 1
            // if(!isAutoConnect.checked)
            // {
            //     if(startPerson.gender)
            //         addPerson.fRanking = ranking
            //     else
            //         addPerson.mRanking = ranking
            // }
            // else
            // {
            //     addPerson.fRanking = ranking
            //     addPerson.mRanking = ranking
            // }
            addPerson.fRanking = ranking
            addPerson.mRanking = ranking

            addPerson.notes = textAreaNotes.text
            addPerson.isDead = switchDeath.checked
            if (switchDeath.checked) {
                addPerson.deathTraditional = deathSwitch.checked
                // death check??
                if (textDeath.text)
                    addPerson.death = textDeath.text
            }

            pdb.updatePerson(addPerson.id)
            mainRect.allPerson.push({
                                        "pid": addPerson.id,
                                        "name": addPerson.name
                                    })

            console.log("saveData End")

            thisPage.finished(true)
            thisPage.destroy()
        } else {
            // pdb.delPerson(0);
            thisPage.finished(false)
            thisPage.destroy()
        }
    }
}
