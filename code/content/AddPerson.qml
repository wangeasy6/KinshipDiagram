import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts
import Qt.labs.platform
import Qt5Compat.GraphicalEffects
import easy.qt.FileUtils 0.1

Rectangle {
    id: thisPage
    width: 1000
    height: 750
    color: "#E5E5E5"
    anchors.centerIn: parent
    radius: 10
    signal beforeSave()
    signal finished(bool updateFlag)
    property var startPersonId
    property var startPerson
    property var addType
    property var autoConnectList: []
    property var tempImages: new Set()

    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 15
        verticalOffset: 20
        color: "#C0CCCCCC"
        spread: 0
    }

    MouseArea {
        anchors.fill: parent
    }

    MessageDialog {
        id: isCropMD
        title: "提示："
        visible: false
        text: "是否对照片进行裁剪？"
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
            var selectSuffix
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
            text: startPerson ? "添加人员： " + startPerson.name + " 之 " + addType : ""
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: false
            bottomPadding: 10
            topPadding: 10
            font.pointSize: 18
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
                        title: "Select a Photo"
                        currentFile: avatar.source
                        nameFilters: [ "Image Files (*.png *.jpeg *.jpg *.bmp)" ]

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
                            enabled: false
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

                    CheckBox {
                        id: isAutoConnect
                        text: qsTr("关联：")
                        padding: 0
                        font.pointSize: 14
                        checked: true
                    }

                    Rectangle {
                        id: autoConnectRect
                        Layout.fillWidth: true
                        implicitHeight: autoConnectGB.implicitHeight
                        color: "#DDDDDD"
                        radius: 5
                        border.width: 0
                        enabled: isAutoConnect.checked

                        GroupBox {
                            id: autoConnectGB
                            anchors.fill: parent
                            padding: 0

                            ButtonGroup {
                                id: singleGroup
                                exclusive: true
                            }

                            Flow {
                                Layout.fillWidth: true
                                spacing: 10
                                anchors.fill: parent
                                Repeater {
                                    id: autoConnectRepeater
                                    model: ListModel { }

                                    delegate: CheckBox {
                                        text: model.text
                                        checked: true
                                        implicitHeight: 43
                                        padding: 0
                                        font.pointSize: 10
                                        ButtonGroup.group: singleGroup
                                    }
                                }
                                Switch {
                                    id: isEx
                                    visible: addType === "父" || addType === "母"
                                    enabled: singleGroup.checkState === Qt.Checked
                                    Layout.preferredHeight: 40
                                    checked: true
                                    text: isEx.checked ? addType === "母" ? qsTr("夫") : qsTr("妻") : addType === "母" ? qsTr("前夫") : qsTr("前妻")
                                    padding: 8
                                    font.pointSize: 10
                                }
                            }
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
                                if (isPositiveInteger(text)) {
                                    var t = parseInt(textSSAR.text)
                                    if (t <= startPerson.children.length) {
                                        textSsarMsg.text = "可能会影响其它子女排名！"
                                        textSsarMsg.color = "#FF8C00"
                                    }
                                    else {
                                        textSsarMsg.text = ""
                                    }
                                } else {
                                    textSsarMsg.text = "请输入正整数！"
                                    textSsarMsg.color = "red"
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
                            thisPage.finished(true)
                            thisPage.destroy()
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        // 自动关联选项
        startPerson = pdb.getPerson(startPersonId)

        if (addType === "夫" || addType === "父" || addType === "子")
            switchGender.checked = false
        else {
            switchGender.checked = true
            if (addType.includes("前"))
                switchGender.checked = startPerson.gender
        }

        if (addType === "父") {
            if (startPerson.mother !== -1) {
                autoConnectList.push({ id: startPerson.mother, name: pdb.getPerson(startPerson.mother).name })
            }
        }
        if (addType === "母") {
            if (startPerson.father !== -1)
                autoConnectList.push({ id: startPerson.father, name: pdb.getPerson(startPerson.father).name })
        }
        if (addType === "子" || addType === "女") {
            textSSAR.text = startPerson.children.length + 1
            for (var j = 0; j < startPerson.marriages.length; j++) {
                if (startPerson.marriages[j] !== -1)
                    autoConnectList.push({ id: startPerson.marriages[j], name: pdb.getPerson(startPerson.marriages[j]).name })
            }
        }
        if (addType === "夫" || addType === "妻" || addType.includes("前")) {
            singleGroup.exclusive = false
            for (var k = 0; k < startPerson.children.length; k++) {
                var getChild = pdb.getPerson(startPerson.children[k])
                if (switchGender.checked)
                    if (getChild.mother === -1)
                        autoConnectList.push({ id: startPerson.children[k], name: getChild.name })
                else
                    if (getChild.father === -1)
                        autoConnectList.push({ id: startPerson.children[k], name: getChild.name })
            }
        }

        if (autoConnectList.length === 0) {
            isAutoConnect.visible = false
            autoConnectRect.visible = false
        } else {
            for (let i = 0; i < autoConnectList.length; i++) {
                autoConnectRepeater.model.append({ text: autoConnectList[i].name })
            }
        }
    }

    function isPositiveInteger(str) {
        var regex = /^[1-9]\d*$/
        return regex.test(str)
    }

    function saveData() {
        console.log("[AddPerson] Save data.")

        if (!isPositiveInteger(textSSAR.text))
            return

        beforeSave()

        var i, j
        var tmp
        var ranking = parseInt(textSSAR.text) - 1
        var addPerson
        if (addType === "父") {
            addPerson = pdb.addFather(startPerson.id)
            if (!addPerson) {
                console.log("Add Person failed.")
                return
            }

            // Auto connect startPerson's mother
            if (isAutoConnect.checked) {
                for (i = 0; i < singleGroup.buttons.length; i++) {
                    if (singleGroup.buttons[i].checked) {
                        console.log(singleGroup.buttons[i].text, " checked ", i)
                        console.log(autoConnectList[i].id)
                        if (autoConnectList[i].id) {
                            var mother = pdb.getPerson(autoConnectList[i].id)
                            if (isEx.checked) {
                                mother.marriages[0] = addPerson.id
                                addPerson.marriages[0] = mother.id
                            } else {
                                mother.marriages.append(addPerson.id)
                                addPerson.marriages.append(mother.id)
                            }
                            pdb.updatePerson(autoConnectList[i].id)
                        }
                    }
                }
            }
        }
        if (addType === "母") {
            addPerson = pdb.addMother(startPerson.id)
            if (!addPerson) {
                console.log("Add Person failed.")
                return
            }

            if (isAutoConnect.checked) {
                for (i = 0; i < singleGroup.buttons.length; i++) {
                    if (singleGroup.buttons[i].checked) {
                        console.log(singleGroup.buttons[i].text, " checked ", i)
                        let father = pdb.getPerson(autoConnectList[i].id)
                        if (isEx.checked) {
                            father.marriages[0] = addPerson.id
                            addPerson.marriages[0] = father.id
                        } else {
                            father.marriages.append(addPerson.id)
                            addPerson.marriages.append(father.id)
                        }
                        pdb.updatePerson(autoConnectList[i].id)
                    }
                }
            }
        }
        if (addType === "子" || addType === "女") {
            if (addType === "子")
                addPerson = pdb.addSon(startPerson.id)
            else
                addPerson = pdb.addDaughter(startPerson.id)
            if (!addPerson) {
                console.log("Add Person failed.")
                return
            }

            if (ranking >= startPerson.children.length) {
                startPerson.children.push(addPerson.id)
            } else {
                startPerson.children.splice(ranking, 0, addPerson.id)
                for (j = ranking; j < startPerson.children.length; j++) {
                    tmp = pdb.getPerson(startPerson.children[j])
                    if (startPerson.gender)
                        if (tmp.fRanking < j) {
                            pdb.updateFRanking(tmp.id, j)
                        } else if (tmp.mRanking < j) {
                            pdb.updatemRanking(tmp.id, j)
                        }
                }
            }
            pdb.updateChildren(startPersonId)

            if (isAutoConnect.checked) {
                for (let i = 0; i < singleGroup.buttons.length; i++) {
                    if (singleGroup.buttons[i].checked) {
                        console.log(singleGroup.buttons[i].text, " checked ", i)
                        tmp = pdb.getPerson(autoConnectList[i].id)
                        if (ranking >= startPerson.children.length) {
                            tmp.children.push(addPerson.id)
                        } else {
                            tmp.children.splice(ranking, 0, addPerson.id)
                            for (j = ranking; j < startPerson.children.length; j++) {
                                tmp = pdb.getPerson(startPerson.children[j])
                                if (startPerson.gender)
                                    if (tmp.mRanking < j) {
                                        pdb.updateMRanking(tmp.id, j)
                                    } else if (addPerson.fRanking < j) {
                                        pdb.updateFRanking(tmp.id, j)
                                    }
                            }
                        }
                        pdb.updateChildren(autoConnectList[i].id)
                        if (startPerson.gender)
                            addPerson.mother = autoConnectList[i].id
                        else
                            addPerson.father = autoConnectList[i].id
                    }
                }
            }
        }
        if (addType === "夫" || addType === "妻") {
            addPerson = pdb.addMate(startPerson.id)
            if (!addPerson) {
                console.log("Add Person failed.")
                return
            }

            if (isAutoConnect.checked) {
                for (let i = 0; i < singleGroup.buttons.length; i++) {
                    if (singleGroup.buttons[i].checked) {
                        console.log(singleGroup.buttons[i].text, " checked ", i)
                        let p = pdb.getPerson(autoConnectList[i].id)
                        if (addPerson.gender)
                            p.father = addPerson.id
                        else
                            p.mother = addPerson.id
                        pdb.updatePerson(autoConnectList[i].id)
                        addPerson.children.push(autoConnectList[i].id)
                    }
                }
            }
        }
        if (addType.includes("前")) {
            addPerson = pdb.addEx(startPerson.id)
            if (!addPerson) {
                console.log("Add Person failed.")
                return
            }

            if (isAutoConnect.checked) {
                for (let i = 0; i < singleGroup.buttons.length; i++) {
                    if (singleGroup.buttons[i].checked) {
                        console.log(singleGroup.buttons[i].text, " checked ", i)
                        let p = pdb.getPerson(autoConnectList[i].id)
                        if (addPerson.gender)
                            p.father = addPerson.id
                        else
                            p.mother = addPerson.id
                        pdb.updatePerson(autoConnectList[i].id)
                        addPerson.children.push(autoConnectList[i].id)
                    }
                }
            }
        }

        if (textAvatarPath.text === "qrc:/qt/qml/content/icons/person.svg")
            addPerson.avatarPath = "icons/person.svg"
        else
            addPerson.avatarPath = textAvatarPath.text.replace(conf.dbPrefix, "")
        addPerson.name = textName.text
        addPerson.call = textCall.text
        addPerson.birthTraditional = birthSwitch.checked
        addPerson.birthday = textBirth.text

        if ((addType === "子" || addType === "女") && (!isAutoConnect.checked)) {
            if (startPerson.gender)
                addPerson.fRanking = ranking
            else
                addPerson.mRanking = ranking
        } else {
            addPerson.fRanking = ranking
            addPerson.mRanking = ranking
        }

        addPerson.notes = textAreaNotes.text
        addPerson.isDead = switchDeath.checked
        if (switchDeath.checked) {
            addPerson.deathTraditional = deathSwitch.checked
            // death check??
            if (textDeath.text)
                addPerson.death = textDeath.text
        }

        pdb.updatePerson(addPerson.id)
        mainRect.allPerson.push({ pid: addPerson.id, name: addPerson.name })

        console.log("saveData End")
    }
}
