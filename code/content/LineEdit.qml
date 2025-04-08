import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts
import Qt.labs.platform

Popup {
    id: thisPage
    modal: true
    visible : true
    width: 500
    height: 600
    padding: 0
    anchors.centerIn: parent
    closePolicy: Popup.CloseOnEscape
    z: 2

    property var startPerson
    property var allPerson: []
    property bool isModernType: pdb.getSettings().marriageMode === "modern"
    property list<int> originalLine
    property bool isChanged: false
    signal finished(bool result)

    background: Rectangle {
        color: "#E5E5E5"
        radius: 10
    }

    MessageDialog {
        id: delConfirmMD
        title: "提示："
        visible: false
        buttons: MessageDialog.No | MessageDialog.Yes
        property var delData

        onAccepted: {
            pdb.delConnection(startPerson.id, delData.pid)

            var p = pdb.getPerson(delData.pid)
            allPerson.push({
                               "pid": p.id,
                               "gender": p.gender,
                               "name": p.name,
                               "avatarPath": p.avatarPath
                           })

            if (delData.lineType <= 2) {
                typeModel.setProperty(
                            delData.lineType,
                            "enabled", true)
                onModelChanged()
            }
            relationModel.remove(delData.index)
            visible = false
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        // 标题
        Text {
            text: startPerson.name + "的"
            font.pointSize: 16
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        // 关系列表
        ListView {
            id: relationList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 5

            model: ListModel {
                id: relationModel
            }

            delegate: Rectangle {
                width: relationList.width
                height: 60
                color: "transparent"

                // color: index%2?"white":"transparent"
                RowLayout {
                    anchors.fill: parent
                    spacing: 10

                    // 关系线类型
                    ComboBox {
                        id: lineTypeCombo
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 40
                        model: startPerson.gender ? (isModernType ? ["父亲", "母亲", "妻子", "前妻", "子女"] : ["父亲", "母亲", "妻子", "妾", "子女"]) : (isModernType ? ["父亲", "母亲", "老公", "前夫", "子女"] : ["父亲", "母亲", "夫君", "前夫", "子女"])
                        currentIndex: lineType
                        enabled: false
                    }

                    // 人员名称
                    Text {
                        text: personName
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // 人员头像
                    Image {
                        source: avatarPath.startsWith(
                                    "icons/") ? avatarPath : conf.dbPrefix + avatarPath
                        Layout.preferredWidth: 50
                        Layout.preferredHeight: 50
                        Layout.rightMargin: 20
                        fillMode: Image.PreserveAspectCrop
                        clip: true
                    }

                    // 删除按钮
                    Button {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        Layout.bottomMargin: 10

                        background: Rectangle {
                            id: delBG
                            width: parent.width
                            height: parent.height
                            radius: parent.width / 2
                            color: parent.hovered ? "#e74c3c" : "#BEBEBE"
                        }

                        Text {
                            text: "×"
                            anchors.centerIn: delBG
                            color: parent.hovered ? "white" : "red"
                            font.pixelSize: 34
                            font.family: "Calibri Light"
                        }

                        onClicked: {
                            delConfirmMD.delData = {"pid":personId, "index":index, "lineType":lineTypeCombo.currentIndex}
                            delConfirmMD.text = "确定删除和" + personName +"的关系？"
                            delConfirmMD.visible = true
                        }
                    }

                    Item {
                        visible: lineType <= 2
                        Layout.preferredWidth: 90
                    }

                    // 上升按钮(婚姻和子女关系)
                    Button {
                        visible: 2 < lineType
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        enabled: index > 0
                                 && (relationModel.get(
                                         index - 1).lineType === lineType)
                        Layout.bottomMargin: 10

                        background: Rectangle {
                            id: upBG
                            width: parent.width
                            height: parent.height
                            radius: 8
                            color: enabled ? (parent.hovered ? "#63B8FF" : "#BEBEBE") : "#CECECE"
                        }

                        Text {
                            anchors.centerIn: upBG
                            text: "↑"
                            color: enabled ? (parent.hovered ? "white" : "#1E90FF") : "white"
                            font.pixelSize: 24
                            font.family: "Calibri"
                        }

                        onClicked: {
                            console.log(personName, " up")
                            if (lineType === 3)
                                pdb.adjustMarriageRanking(startPerson,
                                                          personId, 1)
                            else
                                pdb.adjustChildrenRanking(startPerson,
                                                          personId, 1)
                            relationModel.move(index, index - 1, 1)
                        }
                    }

                    // 下降按钮(婚姻和子女关系)
                    Button {
                        visible: 2 < lineType
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        enabled: index < relationModel.count - 1
                                 && (relationModel.get(
                                         index + 1).lineType === lineType)
                        Layout.bottomMargin: 10

                        background: Rectangle {
                            id: downBG
                            width: parent.width
                            height: parent.height
                            radius: 8
                            color: enabled ? (parent.hovered ? "#63B8FF" : "#BEBEBE") : "#CECECE"
                        }

                        Text {
                            anchors.centerIn: downBG
                            text: "↓"
                            color: enabled ? (parent.hovered ? "white" : "#1E90FF") : "white"
                            font.pixelSize: 24
                            font.family: "Calibri"
                        }

                        onClicked: {
                            console.log(personName, " down")
                            if (lineType === 3)
                                pdb.adjustMarriageRanking(startPerson,
                                                          personId, -1)
                            else
                                pdb.adjustChildrenRanking(startPerson,
                                                          personId, -1)
                            relationModel.move(index, index + 1, 1)
                        }
                    }
                }
            }
        }

        // 添加新关系行
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#f0f0f0"
            radius: 5

            RowLayout {
                anchors.fill: parent
                anchors.margins: 5
                spacing: 10

                // 关系线类型选择
                ComboBox {
                    id: newLineTypeCombo
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    model: ListModel {
                        id: typeModel
                        ListElement {
                            text: "父亲"
                            enabled: true
                        }
                        ListElement {
                            text: "母亲"
                            enabled: true
                        }
                    }
                    textRole: "text"
                    currentIndex: 0

                    delegate: ItemDelegate {
                        width: newLineTypeCombo.width
                        contentItem: Text {
                            text: model.text
                            color: model.enabled ? "black" : "gray"
                        }
                        enabled: model.enabled
                    }

                    onCurrentIndexChanged: {
                        typeFilteredPerson()
                    }
                }

                // 人员选择
                ComboBox {
                    id: personCombo
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    // editable: true
                    clip: true
                    textRole: "name"

                    model: ListModel {
                        id: personModel
                    }

                    delegate: ItemDelegate {
                        height: 40
                        text: name
                    }
                    popup {
                        width: personCombo.width
                        height: 400
                        y: -400
                    }

                    onCurrentIndexChanged: {
                        if (currentIndex >= 0) {
                            var selectedPerson = personModel.get(currentIndex)
                            selectedAvatar.source = selectedPerson.avatarPath.startsWith(
                                        "icons/") ? selectedPerson.avatarPath : conf.dbPrefix
                                                    + selectedPerson.avatarPath
                        }
                    }
                }

                // 人员头像
                Image {
                    id: selectedAvatar
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
                    Layout.rightMargin: 20
                    fillMode: Image.PreserveAspectCrop
                    clip: true
                }

                // 确定按钮
                Button {
                    text: "添加"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 50
                    onClicked: {
                        if (personCombo.currentIndex >= 0) {
                            var selectedPerson = personModel.get(
                                        personCombo.currentIndex)

                            pdb.addConnection(startPerson, selectedPerson.pid,
                                              newLineTypeCombo.currentIndex)
                            var toIndex = 0
                            for (toIndex = relationModel.count - 1; toIndex >= 0; toIndex--)
                                if (relationModel.get(
                                            toIndex).lineType <= newLineTypeCombo.currentIndex)
                                    break

                            relationModel.insert(toIndex + 1, {
                                                     "typeText": newLineTypeCombo.currentText,
                                                     "lineType": newLineTypeCombo.currentIndex,
                                                     "personId": selectedPerson.pid,
                                                     "personName": selectedPerson.name,
                                                     "avatarPath": selectedPerson.avatarPath
                                                 })
                            var i
                            for (i = 0; i < allPerson.length; i++)
                                if (allPerson[i].pid === selectedPerson.pid)
                                    allPerson.splice(i, 1)
                            personModel.remove(personCombo.currentIndex)

                            if (newLineTypeCombo.currentIndex <= 2) {
                                typeModel.setProperty(
                                            newLineTypeCombo.currentIndex,
                                            "enabled", false)
                                onModelChanged()
                            }
                            personCombo.currentIndex = -1
                            selectedAvatar.source = ""
                        }
                    }
                }
            }
        }

        // 底部按钮
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            Button {
                text: "返回"
                onClicked: {
                    checkChange()
                    finished(isChanged)
                    thisPage.destroy()
                }
            }
        }
    }

    function typeFilteredPerson() {
        var title = typeModel.get(newLineTypeCombo.currentIndex).text

        // console.log("newLineTypeCombo currentIndex: ", newLineTypeCombo.currentIndex)
        // console.log("newLineTypeCombo currentText: ", title)
        personModel.clear()
        var i
        if (title === "子女") {
            for (i = 0; i < allPerson.length; i++) {
                personModel.append(allPerson[i])
            }
            return
        }

        var maleCharacters = ["父亲", "老公", "前夫", "夫君"]
        if (maleCharacters.includes(title)) {
            for (i = 0; i < allPerson.length; i++) {
                if (allPerson[i].gender) {
                    personModel.append(allPerson[i])
                }
            }
        } else {
            for (i = 0; i < allPerson.length; i++) {
                if (!allPerson[i].gender) {
                    personModel.append(allPerson[i])
                }
            }
        }
    }

    function onModelChanged() {
        console.log("onModelChanged")

        // 如果当前选择的是已禁用的选项，则选择第一个可用的选项
        if (!typeModel.get(newLineTypeCombo.currentIndex).enabled) {
            for (var i = 0; i < typeModel.count; i++) {
                if (typeModel.get(i).enabled) {
                    newLineTypeCombo.currentIndex = i
                    break
                }
            }
        }
    }

    function checkChange() {
        if (relationModel.count !== originalLine.length) {
            isChanged = true
            return
        }

        for (var i = 0; i < originalLine.length; i++) {
            if (originalLine[i] !== relationModel.get(i).personId) {
                isChanged = true
                break
            }
        }
    }

    Component.onCompleted: {
        // 加载现有关系数据
        if (!startPerson) {
            thisPage.destroy()
            return
        }
        var i

        if (startPerson.gender) // male
        {
            if (pdb.getSettings().marriageMode === "modern") {
                typeModel.append({
                                     "text": "妻子",
                                     "enabled": true
                                 })
                typeModel.append({
                                     "text": "前妻",
                                     "enabled": true
                                 })
            } else {
                typeModel.append({
                                     "text": "妻子",
                                     "enabled": true
                                 })
                typeModel.append({
                                     "text": "妾",
                                     "enabled": true
                                 })
            }
        } else {
            if (pdb.getSettings().marriageMode === "modern") {
                typeModel.append({
                                     "text": "老公",
                                     "enabled": true
                                 })
                typeModel.append({
                                     "text": "前夫",
                                     "enabled": true
                                 })
            } else {
                typeModel.append({
                                     "text": "夫君",
                                     "enabled": true
                                 })
                typeModel.append({
                                     "text": "前夫",
                                     "enabled": true
                                 })
            }
        }
        typeModel.append({
                             "text": "子女",
                             "enabled": true
                         })

        // 加载父亲母亲关系
        if (startPerson.father !== -1) {
            var father = pdb.getPerson(startPerson.father)
            if (father) {
                relationModel.append({
                                         "typeText": "父亲",
                                         "lineType": 0,
                                         "personId": father.id,
                                         "personName": father.name,
                                         "avatarPath": father.avatarPath
                                     })

                typeModel.setProperty(0, "enabled", false)
                onModelChanged()
            }
        }
        if (startPerson.mother !== -1) {
            var mother = pdb.getPerson(startPerson.mother)
            if (mother) {
                relationModel.append({
                                         "typeText": "母亲",
                                         "lineType": 1,
                                         "personId": mother.id,
                                         "personName": mother.name,
                                         "avatarPath": mother.avatarPath
                                     })

                typeModel.setProperty(1, "enabled", false)
                onModelChanged()
            }
        }

        // 加载婚姻关系
        for (i = 0; i < startPerson.marriages.length; i++) {
            if (startPerson.marriages[i] !== -1) {
                var spouse = pdb.getPerson(startPerson.marriages[i])
                if (spouse) {
                    if (i === 0) {
                        typeModel.setProperty(2, "enabled", false)
                        onModelChanged()
                    }

                    var index = 2 + ((i === 0) ? 0 : 1)
                    console.log("relationModel.append:", index,
                                typeModel.get(index).text)
                    relationModel.append({
                                             "typeText": typeModel.get(
                                                             index).text,
                                             "lineType": index,
                                             "personId": spouse.id,
                                             "personName": spouse.name,
                                             "avatarPath": spouse.avatarPath
                                         })
                }
            }
        }

        // 加载子女关系
        for (i = 0; i < startPerson.children.length; i++) {
            if (startPerson.children[i] !== -1) {
                var child = pdb.getPerson(startPerson.children[i])
                if (child) {
                    relationModel.append({
                                             "typeText": "子女",
                                             "lineType": 4,
                                             "personId": child.id,
                                             "personName": child.name,
                                             "avatarPath": child.avatarPath
                                         })
                }
            }
        }

        for (i = 0; i < relationModel.count; i++) {
            originalLine.push(relationModel.get(i).personId)
        }

        // 加载可选人员列表
        for (i = 0; i < pdb.personListCount(); i++) {
            var p = pdb.getPerson(i)
            if (p && p.id !== startPerson.id && !originalLine.includes(p.id)) {
                allPerson.push({
                                   "pid": p.id,
                                   "gender": p.gender,
                                   "name": p.name,
                                   "avatarPath": p.avatarPath
                               })
            }
        }

        typeFilteredPerson()
    }
}
