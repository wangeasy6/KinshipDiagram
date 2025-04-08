//#encoding: UTF-8


/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 6.2
import QtQuick.Controls 6.2
import KinshipDiagramEditor
import QtQuick.Layouts
import Qt.labs.platform

import easy.qt.PersonDB 0.1
import easy.qt.Person 0.1
import easy.qt.Config 0.1
import easy.qt.FileUtils 0.1

Rectangle {
    id: mainRect
    width: parent.width
    height: parent.height
    anchors.centerIn: parent
    color: "#ffffff"

    property var selectedPerson: null
    property var allPerson: []
    property bool unsavedFlag: false
    property bool closeFlag: false
    signal closing

    PersonDB {
        id: pdb
    }

    Config {
        id: conf
        // If not found def_con.json
    }

    Item {
        id: settings
        property var settingsManager: pdb.getSettings()
        property bool isAncient: settingsManager.marriageMode === "ancient"
    }

    FileUtils {
        id: fileUtils
    }

    MessageDialog {
        id: errorMD
        title: "提示："
        visible: false
        onAccepted: {
            errorMD.visible = false
        }
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
            else
                cropForm.rename = textName.text + pdb.getSettings().photoFormat
            cropForm.visible = true
        }

        onRejected: {
            isCropMD.visible = false
            var filePath = selectAvatarFileDialog.file.toString()
            var lastSlashIndex = filePath.lastIndexOf("/")
            var selectPrefix
            var selectSuffix // = filePath.split(".").pop()
            if (lastSlashIndex !== -1) {
                selectPrefix = filePath.substring(0, lastSlashIndex + 1)
                console.log("selectPrefix:", selectPrefix)
                if (selectPrefix.includes(conf.dbPrefix)) {
                    textAvatarPath.text = selectAvatarFileDialog.file
                    avatar.source = selectAvatarFileDialog.file
                } else {
                    // Copy file to store
                    lastSlashIndex = filePath.lastIndexOf(".")
                    selectSuffix = filePath.substring(lastSlashIndex)
                    var saveTo = conf.dbPrefix + textName.text + selectSuffix
                    console.log("Save to: ", saveTo)
                    if (fileUtils.copyFileOverlay(filePath, saveTo)) {
                        textAvatarPath.text = saveTo
                        avatar.source = saveTo
                    }
                }
            }
        }
    }

    MessageDialog {
        id: deleteConfirmDialog
        title: "提示："
        buttons: MessageDialog.No | MessageDialog.Yes

        onAccepted: {
            var toBeDeletedP = selectedPerson
            var toBeDeletedId = selectedPerson.pi.id
            var toBeDeletedAvatar = selectedPerson.avatarPath
            selectedPerson = null

            toBeDeletedP.parent = null
            toBeDeletedP.destroy()
            for (var i = 0; i < allPerson.length; i++) {
                if (allPerson[i].pid === toBeDeletedId) {
                    allPerson.splice(i, 1)
                    break
                }
            }

            // Delete avatar
            if (!toBeDeletedAvatar.startsWith("icons/"))
                fileUtils.deleteFile(toBeDeletedAvatar)
            pdb.delPerson(toBeDeletedId)
            stack.currentItem.redraw()

            if (pdb.personListCount() === 0) {
                // Create protagonist
                var newPageAdd = Qt.createComponent("AddProtagonist.qml")
                if (newPageAdd.status === Component.Ready) {
                    let newP = newPageAdd.createObject(mainRect)
                    newP.finished.connect(newProtagnistFinished)
                }
            }
        }
    }

    MessageDialog {
        id: isSetProtagonist
        title: "提示："
        buttons: MessageDialog.No | MessageDialog.Yes

        onAccepted: {
            if (pdb.setProtagonist(selectedPerson.pi.id)) {
                selectedPerson = null
                stack.clear(StackView.Immediate)
                reload()
            }
        }
    }

    MessageDialog {
        id: isUnsaveDialog
        title: "提示："
        text: "放弃修改？"
        buttons: MessageDialog.No | MessageDialog.Yes
        property var replacement

        onAccepted: {
            if (closeFlag)
                Qt.quit()
            else
                setSidePersonInfo(replacement)
        }

        onRejected: {
            if (closeFlag)
                closeFlag = false
        }
    }

    Cropping {
        id: cropForm
        visible: false
        anchors.centerIn: parent
        z: 2

        onSaved: path => {
                     console.log("onSaved path:", path)
                     textAvatarPath.text = path
                     avatar.source = path
                     avatar.update()
                     selectedPerson.imgAvatar.update()
                 }
    }

    function setSidePerson(p) {
        if (unsavedFlag) {
            isUnsaveDialog.replacement = p
            isUnsaveDialog.open()
        } else
            setSidePersonInfo(p)
    }

    function setSidePersonInfo(p) {
        // console.log("setSidePerson")
        if (selectedPerson)
            selectedPerson.selected = false

        selectedPerson = p
        selectedPerson.selected = true
        textAvatarPath.text = selectedPerson.avatarPath
        avatar.source = selectedPerson.avatarPath
        addFather.enabled = p.pi.father === -1 ? true : false
        addMother.enabled = p.pi.mother === -1 ? true : false
        addMate.text = p.gender ? "妻" : "夫"
        if (p.pi.marriages.length > 0 && p.pi.marriages[0] !== -1)
            addMate.enabled = false
        else
            addMate.enabled = true
        if (selectedPerson.pi.fRanking === selectedPerson.pi.mRanking) {
            rankingText.text = selectedPerson.pi.fRanking + 1
            rankingBG.gradient.orientation = Gradient.Vertical
        } else {
            rankingBG.gradient.orientation = Gradient.Vertical
            if (selectedPerson.pi.father === -1)
                rankingText.text = selectedPerson.pi.mRanking + 1
            else if (selectedPerson.pi.mother === -1)
                rankingText.text = selectedPerson.pi.fRanking + 1
            else {
                rankingText.text = (selectedPerson.pi.fRanking + 1) + " | "
                        + (selectedPerson.pi.mRanking + 1)
                rankingBG.gradient.orientation = Gradient.Horizontal
            }
        }
    }

    ColumnLayout {
        id: mainLayout
        anchors.fill: mainRect
        anchors.centerIn: mainRect
        // anchors.margins: 20
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.topMargin: 0
        anchors.bottomMargin: 20
        spacing: 10

        RowLayout {
            id: headerLayout
            Layout.fillWidth: true
            Layout.preferredHeight: 80

            Row {
                id: sysToolBar
                width: 140
                height: 60
                Layout.rowSpan: 2
                Layout.columnSpan: 1
                leftPadding: 20
                spacing: 20

                ToolButton {
                    id: btSetting
                    width: 60
                    height: 60
                    icon.height: 50
                    icon.width: 50
                    icon.source: "icons/settings.svg"
                    display: AbstractButton.IconOnly

                    onClicked: {
                        let newNode = Qt.createComponent("Settings.qml")
                        if (newNode.status === Component.Ready) {
                            let newP = newNode.createObject(mainRect)
                        }
                    }
                }

                ToolButton {
                    id: btHelp
                    width: 60
                    height: 60
                    icon.height: 50
                    icon.width: 50
                    icon.source: "icons/info-circle.svg"
                    display: AbstractButton.IconOnly

                    onClicked: {
                        let newNode = Qt.createComponent("HelpInfo.qml")
                        if (newNode.status === Component.Ready) {
                            let newP = newNode.createObject(mainRect)
                        }
                    }
                }
            }

            Switch {
                id: searchViewSwitch
                leftPadding: 20
                implicitWidth: 207
                checked: true
                text: checked ? qsTr("人员搜索:") : qsTr("路径搜索:")
                font.pointSize: 14

                onCheckedChanged: {
                    if (checked) {
                        // startListModel.clear()
                        // endListModel.clear()
                        startInput.text = ""
                        endInput.text = ""
                        searchSwipeView.setCurrentIndex(0)
                    } else {
                        // resultModel.clear()
                        searchInput.text = ""
                        searchSwipeView.setCurrentIndex(1)
                    }
                }
            }

            SwipeView {
                id: searchSwipeView
                currentIndex: 0
                // width: headerLayout.width - sysToolBar.width - searchViewSwitch.width
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                interactive: false

                Item {
                    Row {
                        id: searchRow
                        anchors.centerIn: parent
                        spacing: 20
                        rightPadding: 20

                        TextField {
                            id: searchInput
                            width: searchSwipeView.width - btSearch.width - 40
                            height: 55
                            font.pointSize: 13

                            onCursorVisibleChanged: {
                                console.log("searchInput get CursorVisible: ",
                                            cursorVisible)
                                resultListView.visible = cursorVisible
                                if (cursorVisible && text === "") {
                                    resultModel.clear()
                                    for (var i = 0; i < allPerson.length; i++) {
                                        resultModel.append(allPerson[i])
                                    }
                                }
                            }

                            onTextChanged: {
                                resultModel.clear()
                                if (text) {
                                    for (var i = 0; i < allPerson.length; i++) {
                                        if (allPerson[i].name.includes(text))
                                            resultModel.append(allPerson[i])
                                    }
                                }
                            }
                        }

                        ListModel {
                            id: resultModel
                        }

                        ListView {
                            id: resultListView
                            parent: mainRect
                            x: searchSwipeView.x + 20
                            y: searchInput.y + searchInput.height + 5
                            width: 140
                            // height: contentHeight
                            height: 300
                            clip: true

                            model: resultModel
                            delegate: Button {
                                width: 120
                                height: 50

                                Text {
                                    text: model.name
                                    anchors.centerIn: parent
                                    color: "white"
                                    font.pointSize: 12
                                }

                                background: Rectangle {
                                    implicitWidth: 100
                                    implicitHeight: 50
                                    color: "orange"
                                    radius: 0
                                }

                                onHoveredChanged: {
                                    if (hovered) {
                                        background.color = "orangered"
                                    } else {
                                        background.color = "orange"
                                    }
                                }

                                onClicked: {
                                    searchInput.text = model.name
                                    onSearchByName(searchInput.text)
                                    resultModel.clear()
                                }
                            }
                            ScrollBar.vertical: ScrollBar {
                                width: 14
                                anchors.right: parent.right
                                anchors.margins: 3
                            }
                        }

                        ToolButton {
                            id: btSearch
                            width: 60
                            height: 60
                            icon.height: 60
                            icon.width: 60
                            icon.source: "icons/search.svg"
                            display: AbstractButton.IconOnly

                            onClicked: {
                                resultModel.clear()
                                onSearchByName(searchInput.text)
                            }
                        }
                    }
                }

                Item {
                    Row {
                        id: pathRow
                        anchors.centerIn: parent
                        spacing: 20
                        rightPadding: 20

                        Label {
                            id: startLabel
                            text: "从"
                            font.pointSize: 14
                            height: 60
                            verticalAlignment: Text.AlignVCenter
                        }

                        TextField {
                            id: startInput
                            width: (searchSwipeView.width - startLabel.width * 2
                                    - btPath.width - 100) / 2
                            height: 55
                            font.pointSize: 13

                            onTextChanged: {
                                startListModel.clear()
                                if (text) {
                                    startListModel.append({
                                                              "name": "主人公"
                                                          })
                                    for (var i = 0; i < allPerson.length; i++) {
                                        if (allPerson[i].name.includes(text))
                                            startListModel.append(allPerson[i])
                                    }
                                }
                            }
                        }

                        ListModel {
                            id: startListModel
                        }

                        ListView {
                            id: startListView
                            parent: mainRect
                            x: searchSwipeView.x + startInput.x + 20
                            y: startInput.y + startInput.height + 5
                            width: 140
                            height: 300
                            clip: true

                            model: startListModel
                            delegate: Button {
                                width: 120
                                height: 50

                                Text {
                                    text: model.name
                                    anchors.centerIn: parent
                                    color: "white"
                                    font.pointSize: 12
                                }

                                background: Rectangle {
                                    implicitWidth: 100
                                    implicitHeight: 50
                                    color: "orange"
                                    radius: 0
                                }

                                onHoveredChanged: {
                                    if (hovered) {
                                        background.color = "orangered"
                                    } else {
                                        background.color = "orange"
                                    }
                                }

                                onClicked: {
                                    startInput.text = model.name
                                    startListModel.clear()
                                }
                            }
                            ScrollBar.vertical: ScrollBar {
                                width: 14
                                anchors.right: parent.right
                                anchors.margins: 3
                            }
                        }

                        Label {
                            text: "到"
                            font.pointSize: 14
                            height: 60
                            verticalAlignment: Text.AlignVCenter
                        }

                        TextField {
                            id: endInput
                            width: startInput.width
                            height: 55
                            font.pointSize: 13

                            onTextChanged: {
                                endListModel.clear()
                                if (text) {
                                    endListModel.append({
                                                            "name": "主人公"
                                                        })
                                    for (var i = 0; i < allPerson.length; i++) {
                                        if (allPerson[i].name.includes(text))
                                            endListModel.append(allPerson[i])
                                    }
                                }
                            }
                        }

                        ListModel {
                            id: endListModel
                        }

                        ListView {
                            id: endListView
                            parent: mainRect
                            x: searchSwipeView.x + endInput.x + 20
                            y: endInput.y + endInput.height + 5
                            width: 140
                            // height: contentHeight
                            height: 300
                            clip: true

                            model: endListModel
                            delegate: Button {
                                width: 120
                                height: 50

                                Text {
                                    text: model.name
                                    anchors.centerIn: parent
                                    color: "white"
                                    font.pointSize: 12
                                }

                                background: Rectangle {
                                    implicitWidth: 100
                                    implicitHeight: 50
                                    color: "orange"
                                    radius: 0
                                }

                                onHoveredChanged: {
                                    if (hovered) {
                                        background.color = "orangered"
                                    } else {
                                        background.color = "orange"
                                    }
                                }

                                onClicked: {
                                    endInput.text = model.name
                                    endListModel.clear()
                                }
                            }
                            ScrollBar.vertical: ScrollBar {
                                width: 14
                                anchors.right: parent.right
                                anchors.margins: 3
                            }
                        }

                        ToolButton {
                            id: btPath
                            width: 60
                            height: 60
                            icon.height: 60
                            icon.width: 60
                            icon.source: "icons/search.svg"
                            display: AbstractButton.IconOnly

                            onClicked: {
                                startListModel.clear()
                                endListModel.clear()
                                if (startInput.text && endInput.text) {
                                    searchPathByName(startInput.text,
                                                     endInput.text)
                                }
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            id: bodyLayout
            Layout.fillHeight: true
            Layout.preferredHeight: 910
            Layout.fillWidth: true
            spacing: 15

            Rectangle {
                id: drawRect
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: stack.visible ? "#a5a5a5" : "#f5f5f5"
                clip: true

                StartProject {
                    id: startRect
                    visible: true
                    anchors.centerIn: parent
                    historyList: conf.historyList

                    onOpenMap: path => {
                                   selectedPerson = null
                                   stack.clear(StackView.Immediate)
                                   conf.updatePath(path)
                                   cropForm.pathPrefix = conf.dbPrefix
                                   visible = false
                                   stack.visible = true
                                   initLoad(path)
                               }
                }

                StackView {
                    id: stack
                    visible: false
                    anchors.fill: parent

                    pushEnter: Transition {
                        id: pushEnter
                        PropertyAnimation {
                            property: "opacity"
                            from: 0.3
                            to: 1
                            duration: 120
                        }
                        PropertyAction {
                            property: "x"
                            value: pushEnter.ViewTransition.item.centerX
                        }
                        PropertyAction {
                            property: "y"
                            value: pushEnter.ViewTransition.item.centerY
                        }
                    }
                    pushExit: Transition {
                        PropertyAnimation {
                            property: "opacity"
                            from: 1
                            to: 0
                            duration: 80
                        }
                    }
                    popEnter: Transition {
                        id: popEnter
                        PropertyAnimation {
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 0
                        }
                        PropertyAction {
                            property: "x"
                            value: popEnter.ViewTransition.item.centerX
                        }
                        PropertyAction {
                            property: "y"
                            value: popEnter.ViewTransition.item.centerY
                        }
                    }
                    popExit: Transition {
                        PropertyAnimation {
                            property: "opacity"
                            from: 1
                            to: 0
                            duration: 0
                        }
                    }
                }
            }

            Rectangle {
                id: sideRect
                Layout.preferredWidth: 330
                Layout.fillHeight: true
                color: "#f5f5f5"

                ColumnLayout {
                    id: sideLayout
                    anchors.fill: parent
                    width: sideRect.width - 20
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    anchors.margins: 10

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
                        Layout.fillWidth: true
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

                            Keys.onReturnPressed: {
                                if (textName.text) {
                                    cropForm.avatarPath = text
                                    cropForm.rename = textName.text + pdb.getSettings(
                                                ).photoFormat
                                    cropForm.visible = true
                                } else {
                                    errorMD.text = "请先填写人员姓名！"
                                    errorMD.visible = true
                                }
                            }

                            onTextChanged: {
                                if (selectedPerson) {
                                    if (text !== selectedPerson.avatarPath)
                                        btSaveInfo.unsavedList[0] = 1
                                    else
                                        btSaveInfo.unsavedList[0] = 0

                                    setUnsavedFlag()
                                }
                            }
                        }

                        FileDialog {
                            id: selectAvatarFileDialog
                            title: "Select a Photo"
                            // selectFolder: false
                            // selectMultiple: false
                            // supportedSchemes: [ "file" ]
                            currentFile: avatar.source
                            nameFilters: ["Image Files (*.png *.jpeg *.jpg *.bmp *.webp)"]

                            onAccepted: {
                                console.log("You selected:",
                                            selectAvatarFileDialog.file)
                                if (textName.text)
                                    isCropMD.visible = true
                                else {
                                    errorMD.text = "请先填写人员姓名！"
                                    errorMD.visible = true
                                }
                            }
                        }

                        ToolButton {
                            id: btSelectAvatar
                            enabled: selectedPerson
                            width: 40
                            height: 40
                            display: AbstractButton.IconOnly
                            icon.source: "icons/elipsis.svg"
                            font.pointSize: 20
                            rightPadding: 0
                            leftPadding: 0
                            bottomPadding: 0
                            topPadding: 0
                            ToolTip.text: "选择照片"
                            ToolTip.delay: 500
                            ToolTip.visible: hovered

                            onClicked: selectAvatarFileDialog.open()
                        }
                    }

                    GridLayout {
                        id: peasonInfo
                        Layout.fillWidth: true
                        // rows: 6
                        columns: 2
                        Layout.margins: 10
                        Layout.preferredHeight: 42
                        rowSpacing: 5

                        Label {
                            id: lbName
                            text: qsTr("姓名：")
                            font.pointSize: 12
                        }

                        RowLayout {
                            spacing: 10

                            TextField {
                                id: textName
                                Layout.preferredHeight: 42
                                Layout.minimumWidth: 90
                                Layout.fillWidth: true
                                text: selectedPerson ? selectedPerson.name : ""

                                onTextChanged: {
                                    if (selectedPerson) {
                                        if (text !== selectedPerson.name)
                                            btSaveInfo.unsavedList[1] = 1
                                        else
                                            btSaveInfo.unsavedList[1] = 0

                                        setUnsavedFlag()
                                    }
                                }
                            }

                            Button {
                                Layout.maximumWidth: 90
                                Layout.preferredHeight: 42
                                ToolTip.text: "修改排名"
                                ToolTip.delay: 500
                                ToolTip.visible: hovered

                                contentItem: Text {
                                    id: rankingText
                                    anchors.fill: parent
                                    font.pointSize: 11
                                    // text: ""
                                    color: "white"
                                    padding: 0
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    id: rankingBG
                                    radius: 4
                                    anchors.fill: parent
                                    gradient: Gradient {
                                        orientation: Gradient.Horizontal
                                        GradientStop {
                                            position: 0.0
                                            color: "#63B8FF"
                                        }
                                        GradientStop {
                                            position: 1.0
                                            color: "#FFC0CB"
                                        }
                                    }
                                }

                                onClicked: {
                                    if (selectedPerson) {
                                        var isSync = pdb.parentIsSync(
                                                    selectedPerson.pi.id)
                                        if (isSync === -3) {
                                            errorMD.text = "子女排序需要先添加父母！"
                                            errorMD.visible = true
                                        } else
                                            openChildrenSorting(isSync)
                                    }
                                }
                            }
                        }

                        Label {
                            id: lbCall
                            text: qsTr("称呼：")
                            font.pointSize: 12
                        }

                        Row {
                            id: rowCall
                            // width: 200
                            height: parent.height
                            Layout.fillWidth: true

                            TextField {
                                id: textCall
                                height: 42
                                Layout.fillWidth: true
                                // placeholderText: qsTr("Text Field")
                                text: selectedPerson ? selectedPerson.pi.call : ""

                                onTextChanged: {
                                    if (selectedPerson) {
                                        if (text !== selectedPerson.pi.call)
                                            btSaveInfo.unsavedList[2] = 1
                                        else
                                            btSaveInfo.unsavedList[2] = 0

                                        setUnsavedFlag()
                                    }
                                }
                            }

                            Button {
                                id: btGetCall
                                visible: false
                                width: 70
                                text: qsTr("计算")
                                rightPadding: 10
                                leftPadding: 10
                                bottomPadding: 5
                                topPadding: 5
                                font.pointSize: 10
                            }
                        }

                        Label {
                            id: lbSubcall
                            visible: false
                            text: qsTr("临时关系：")
                            font.pointSize: 10
                        }

                        TextField {
                            id: textSubcall
                            visible: false
                            Layout.preferredHeight: 42
                            Layout.fillWidth: true
                            text: selectedPerson ? selectedPerson.pi.subCall : ""
                        }

                        Label {
                            id: lbBirth
                            text: qsTr("生日：")
                            font.pointSize: 12
                        }

                        Row {
                            id: rowBirth
                            // width: 200
                            height: parent.height
                            spacing: 10

                            YinYangSwitch {
                                id: birthSwitch
                                checked: selectedPerson ? selectedPerson.pi.birthTraditional : false

                                onCheckedChanged: {
                                    if (selectedPerson) {
                                        if (checked !== selectedPerson.pi.birthTraditional)
                                            btSaveInfo.unsavedList[3] = 1
                                        else
                                            btSaveInfo.unsavedList[3] = 0

                                        setUnsavedFlag()
                                    }
                                }
                            }

                            TextField {
                                id: textBirth
                                height: 42
                                Layout.fillWidth: true
                                text: selectedPerson ? selectedPerson.pi.birthday : ""

                                onTextChanged: {
                                    if (selectedPerson) {
                                        if (text !== selectedPerson.pi.birthday)
                                            btSaveInfo.unsavedList[4] = 1
                                        else
                                            btSaveInfo.unsavedList[4] = 0

                                        setUnsavedFlag()
                                    }
                                }
                            }
                        }

                        Label {
                            text: qsTr("已故：")
                            font.pointSize: 12
                        }

                        Switch {
                            id: switchDeath
                            height: 42
                            checked: selectedPerson ? selectedPerson.pi.isDead : false
                            text: switchDeath.checked ? qsTr("是") : qsTr("否")
                            font.pointSize: 10

                            onCheckedChanged: {
                                if (selectedPerson) {
                                    if (checked !== selectedPerson.pi.isDead)
                                        btSaveInfo.unsavedList[5] = 1
                                    else
                                        btSaveInfo.unsavedList[5] = 0

                                    setUnsavedFlag()
                                }
                            }
                        }

                        Label {
                            text: qsTr("忌日：")
                            font.pointSize: 12
                            visible: switchDeath.checked
                        }

                        Row {
                            id: rowDeath
                            visible: switchDeath.checked
                            height: 42
                            spacing: 10

                            YinYangSwitch {
                                id: deathSwitch
                                checked: selectedPerson ? selectedPerson.pi.deathTraditional : false

                                onCheckedChanged: {
                                    if (selectedPerson) {
                                        if (checked !== selectedPerson.pi.deathTraditional)
                                            btSaveInfo.unsavedList[6] = 1
                                        else
                                            btSaveInfo.unsavedList[6] = 0

                                        setUnsavedFlag()
                                    }
                                }
                            }

                            TextField {
                                id: textDeath
                                height: 42
                                Layout.fillWidth: true
                                text: selectedPerson ? selectedPerson.pi.death : ""

                                onTextChanged: {
                                    if (selectedPerson) {
                                        if (text !== selectedPerson.pi.death)
                                            btSaveInfo.unsavedList[7] = 1
                                        else
                                            btSaveInfo.unsavedList[7] = 0

                                        setUnsavedFlag()
                                    }
                                }
                            }
                        }

                        Label {
                            id: lbNotes
                            text: qsTr("备注：")
                            font.pointSize: 12
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

                                text: selectedPerson ? selectedPerson.pi.notes : ""

                                onTextChanged: {
                                    if (selectedPerson) {
                                        if (text !== selectedPerson.pi.notes)
                                            btSaveInfo.unsavedList[8] = 1
                                        else
                                            btSaveInfo.unsavedList[8] = 0

                                        setUnsavedFlag()
                                    }
                                }
                            }
                        }
                    }

                    Button {
                        id: btSaveInfo
                        text: qsTr("保存")
                        Layout.bottomMargin: 5
                        bottomPadding: 12
                        topPadding: 12
                        rightPadding: 40
                        leftPadding: 40
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.pointSize: 15
                        property var unsavedList: [0, 0, 0, 0, 0, 0, 0, 0, 0]

                        onClicked: {
                            if (selectedPerson && unsavedFlag) {
                                selectedPerson.avatarPath = textAvatarPath.text
                                var savePi = selectedPerson.pi
                                if (textAvatarPath.text === "qrc:/qt/qml/content/icons/person.svg")
                                    savePi.avatarPath = "icons/person.svg"
                                else
                                    savePi.avatarPath = textAvatarPath.text.replace(
                                                conf.dbPrefix, "")
                                savePi.name = textName.text
                                savePi.call = textCall.text
                                savePi.subCall = textSubcall.text
                                savePi.birthTraditional = birthSwitch.checked
                                savePi.birthday = textBirth.text
                                savePi.notes = textAreaNotes.text
                                savePi.isDead = switchDeath.checked
                                if (switchDeath.checked) {
                                    savePi.deathTraditional = deathSwitch.checked
                                    // death check??
                                    if (textDeath.text)
                                        savePi.death = textDeath.text
                                }
                                pdb.updatePerson(savePi.id)
                                unsavedList.fill(0)
                                unsavedFlag = false
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: addToolRect
        width: 430
        height: 70
        color: "#d5d5d5"
        radius: 5
        border.width: 0
        x: subToolRect.x + 25
        y: subToolRect.y - 90
        visible: false

        Row {
            id: addToolBar
            width: addToolRect.width - 20
            height: 50
            anchors.centerIn: parent
            spacing: 10

            ToolButton {
                id: addFather
                width: 50
                height: 50
                text: "父"
                font.pointSize: 14

                onClicked: {
                    addPerson(text)
                }
            }

            ToolButton {
                id: addMother
                width: 50
                height: 50
                text: "母"
                font.pointSize: 14

                onClicked: {
                    addPerson(text)
                }
            }

            ToolButton {
                id: addMate
                width: 50
                height: 50
                text: selectedPerson ? (selectedPerson.gender ? "夫" : "妻") : "夫"
                font.pointSize: 14

                onClicked: {
                    addPerson(text)
                }
            }

            ToolButton {
                id: addEx
                width: 100
                height: 50
                text: selectedPerson ? (selectedPerson.gender ? ((pdb.getSettings(
                                                                      ).marriageMode === "modern") ? "前妻" : "前妻/妾") : "前夫") : "前夫"
                font.pointSize: text.length == 2 ? 14 : 12

                onClicked: {
                    console.log("width:", contentItem.width)
                    addPerson(text)
                }
            }

            ToolButton {
                id: addSon
                width: 50
                height: 50
                text: "子"
                font.pointSize: 14

                onClicked: {
                    addPerson(text)
                }
            }

            ToolButton {
                id: addDaughter
                width: 50
                height: 50
                text: "女"
                font.pointSize: 14

                onClicked: {
                    addPerson(text)
                }
            }
        }
    }

    Rectangle {
        id: subToolRect
        width: 550 // 20 + button.number * 50  + (button.number - 1) * 10
        // = 10 + button.number * 60
        height: 70
        color: "#d5d5d5"
        radius: 5
        border.width: 0
        x: drawRect.x + drawRect.width - subToolRect.width
        y: drawRect.y + drawRect.height

        Row {
            id: subToolBar
            width: subToolRect.width - 20
            height: 50
            anchors.centerIn: parent
            spacing: 10

            ToolButton {
                id: btHome
                enabled: stack.visible
                width: 50
                height: 50
                icon.height: 34
                icon.width: 34
                icon.source: "icons/home-8-line.svg"
                display: AbstractButton.IconOnly
                ToolTip.text: "回到初始页"
                ToolTip.delay: 500
                ToolTip.visible: hovered

                onClicked: {
                    while (stack.depth > 1)
                        stack.pop()
                    if (stack.currentItem) {
                        stack.currentItem.restoreLastPos()
                        setSidePerson(stack.currentItem.mainPF)
                    }
                }
            }

            ToolButton {
                id: btRefresh
                enabled: stack.currentItem
                width: 50
                height: 50
                icon.height: 34
                icon.width: 34
                icon.source: "icons/refresh.svg"
                display: AbstractButton.IconOnly
                ToolTip.text: "刷新当前页"
                ToolTip.delay: 500
                ToolTip.visible: hovered

                onClicked: {
                    if (stack.depth > 0) {
                        selectedPerson = null
                        stack.currentItem.redraw()
                    }
                }
            }

            ToolButton {
                id: btBack
                width: 50
                height: 50
                icon.height: 50
                icon.width: 50
                icon.source: "icons/arrow-back-outline.svg"
                display: AbstractButton.IconOnly
                enabled: stack.depth > 1 ? true : false
                ToolTip.text: "上一页"
                ToolTip.delay: 500
                ToolTip.visible: hovered

                onClicked: {
                    stack.pop()
                    stack.currentItem.restoreLastPos()
                    setSidePerson(stack.currentItem.mainPF)
                }
            }

            // ToolButton {
            //     id: btForward
            //     width: 50
            //     height: 50
            //     icon.height: 50
            //     icon.width: 50
            //     icon.source: "icons/arrow-forward-outline.svg"
            //     display: AbstractButton.IconOnly
            // }
            ToolButton {
                id: btAdd
                enabled: selectedPerson
                width: 50
                height: 50
                icon.height: 50
                icon.width: 50
                icon.source: "icons/add.svg"
                display: AbstractButton.IconOnly
                ToolTip.text: "添加人员"
                ToolTip.delay: 500
                ToolTip.visible: hovered

                onClicked: {
                    addToolRect.visible = true
                    addToolRectTimer.start()
                }

                Timer {
                    id: addToolRectTimer
                    interval: 3000
                    running: false
                    repeat: false
                    onTriggered: addToolRect.visible = false
                }
            }

            ToolButton {
                id: btDel
                enabled: selectedPerson
                width: 50
                height: 50
                icon.height: 50
                icon.width: 50
                icon.source: "icons/subtract.svg"
                display: AbstractButton.IconOnly
                ToolTip.text: "删除人员"
                ToolTip.delay: 500
                ToolTip.visible: hovered

                onClicked: {
                    let ret = pdb.delPersonCheck(selectedPerson.pi)
                    if (ret) {
                        deleteConfirmDialog.text = "确定删除：" + selectedPerson.name + "？"
                        deleteConfirmDialog.open()
                    } else {
                        errorMD.text = pdb.errorMsg
                        errorMD.visible = true
                    }
                }
            }

            ToolButton {
                id: btLineEdit
                enabled: selectedPerson
                width: 50
                height: 50
                display: AbstractButton.IconOnly
                icon.source: "icons/line-edit.svg"
                icon.height: 34
                icon.width: 34
                ToolTip.text: "编辑关系"
                ToolTip.delay: 500
                ToolTip.visible: hovered

                onClicked: {
                    let newNode = Qt.createComponent("LineEdit.qml")
                    if (newNode.status === Component.Ready) {
                        let newP = newNode.createObject(mainRect, {
                                                            "startPerson": selectedPerson.pi
                                                        })
                        newP.finished.connect(updatePage)
                    } else if (newNode.status === Component.Error) {
                        console.error("Create LineEdit component error:",
                                      newNode.errorString())
                    }
                }
            }

            ToolButton {
                id: btStar
                enabled: selectedPerson
                width: 50
                height: 50
                icon.height: 34
                icon.width: 34
                icon.source: "icons/star.svg"
                display: AbstractButton.IconOnly
                ToolTip.text: "设置为关键人员"
                ToolTip.delay: 500
                ToolTip.visible: hovered

                onClicked: {
                    if (selectedPerson.pi.id != pdb.getProtagonistId()) {
                        isSetProtagonist.text = "确定设置：" + selectedPerson.name + " 为主人公？"
                        isSetProtagonist.open()
                    }
                }
            }

            ToolButton {
                id: btImport
                enabled: !startRect.visible
                width: 50
                height: 50
                icon.height: 50
                icon.width: 50
                icon.source: "icons/import-outline.svg"
                display: AbstractButton.IconOnly
                ToolTip.text: "打开/新建"
                ToolTip.delay: 500
                ToolTip.visible: hovered

                onClicked: {
                    selectedPerson = null
                    stack.visible = false
                    startRect.visible = true
                    pdb.getSettings().initialized = false
                }
            }

            ToolButton {
                id: btExport
                enabled: stack.currentItem
                width: 50
                height: 50
                icon.height: 50
                icon.width: 50
                icon.source: "icons/export-outline.svg"
                display: AbstractButton.IconOnly
                ToolTip.text: "导出图片"
                ToolTip.delay: 500
                ToolTip.visible: hovered

                FileDialog {
                    id: saveImgFileDialog
                    title: "Save as"
                    fileMode: FileDialog.SaveFile
                    nameFilters: ["Image Files (*.png *.jpeg *.jpg *.bmp)"]

                    onAccepted: {
                        console.log("selected:", saveImgFileDialog.file)
                        if (saveImgFileDialog.file) {
                            stack.currentItem.grabToImage(function (result) {
                                result.saveToFile(saveImgFileDialog.file)
                            })
                            console.log("Save to: ", saveImgFileDialog.file)
                        }
                    }
                }

                onClicked: {
                    saveImgFileDialog.open()
                }
            }
        }
    }

    function setUnsavedFlag() {
        var n = 0
        for (var i = 0; i < btSaveInfo.unsavedList.length; i++) {
            n += btSaveInfo.unsavedList[i]
        }
        if (n)
            unsavedFlag = true
        else
            unsavedFlag = false
    }

    function clearRvalueOfPersonList() {
        selectedPerson = null
        // for(var i = 0; i < stack.depth; i++)
        // {
        //     stack.children[i].clearUI()
        // }
        // console.log("clearRvalueOfPersonList", stack.depth)
    }

    function updatePage(result) {
        console.log("Child page returned with result:", result)
        if (result) {
            stack.currentItem.redraw()
            // console.log("updatePage", stack.depth)
            // for(var i = 0; i < stack.depth; i++)
            // {
            //     stack.children[i].redraw()
            // }
        }
    }

    function addPerson(type) {
        if (!selectedPerson)
            return
        let newNode = Qt.createComponent("AddPerson.qml")
        if (newNode.status === Component.Ready) {
            let newP = newNode.createObject(mainRect, {
                                                "startPersonId": selectedPerson.pi.id,
                                                "addType": type
                                            })
            newP.beforeSave.connect(clearRvalueOfPersonList)
            newP.finished.connect(updatePage)
        }
        addToolRect.visible = false
    }

    function openChildrenSorting(isSync) {
        let newNode = Qt.createComponent("ChildrenSorting.qml")
        if (newNode.status === Component.Ready) {
            let newP = newNode.createObject(mainRect, {
                                                "startPersonId": selectedPerson.pi.id,
                                                "isSync": isSync
                                            })
            newP.finished.connect(updatePage)
        }
    }

    function newProtagnistFinished(flag) {
        if (flag) {
            startRect.visible = false
            stack.visible = true
            var newPage = Qt.createComponent("CanvasByBlood.qml")
            stack.push(newPage, {
                           "mainPersonID": pdb.getProtagonistId()
                       }, StackView.PushTransition)
        } else {
            startRect.visible = true
            stack.visible = false
        }
    }

    function searchInDB(name) {
        var p = pdb.getPersonByName(name)
        if (p) {
            console.log("searchInDB", p.name, p.id)
            var newPage = Qt.createComponent("CanvasByBlood.qml")
            stack.push(newPage, {
                           "mainPersonID": p.id
                       }, StackView.PushTransition)
        } else {
            errorMD.text = "查无此人！"
            errorMD.open()
        }
    }

    function onSearchByName(name) {
        if (stack.depth > 0) {
            // Every page must implement searchInPage
            if (!stack.currentItem.searchInPage(name)) {
                searchInDB(name)
            }
        }
    }

    function searchPathByName(startName, endName) {
        if (startName === endName) {
            errorMD.text = "我就是我，不一样的烟火！"
            errorMD.open()
            return
        }

        var startPerson
        if (startName === "主人公")
            startPerson = pdb.getProtagonist()
        else
            startPerson = pdb.getPersonByName(startName)
        if (!startPerson) {
            errorMD.text = "谱中未录其人：" + startName + "！"
            errorMD.open()
            return
        }

        var endPerson
        if (endName === "主人公")
            endPerson = pdb.getProtagonist()
        else
            endPerson = pdb.getPersonByName(endName)
        if (!endPerson) {
            errorMD.text = "谱中未录其人：" + endName + "！"
            errorMD.open()
            return
        }

        var newPage = Qt.createComponent("CanvasByPath.qml")
        stack.push(newPage, {
                       "fromPerson": startPerson,
                       "toId": endPerson.id
                   }, StackView.PushTransition)
    }

    function reload() {
        if (pdb.personListCount() === 0) {
            // Create protagonist
            var newPageAdd = Qt.createComponent("AddProtagonist.qml")
            if (newPageAdd.status === Component.Ready) {
                let newP = newPageAdd.createObject(mainRect)
                newP.finished.connect(newProtagnistFinished)
            }
        } else {
            for (var i = 0; i < pdb.personListCount(); i++) {
                var p = pdb.getPerson(i)
                if (p) {
                    allPerson.push({
                                       "pid": p.id,
                                       "name": p.name
                                   })
                }
            }

            var newPage = Qt.createComponent("CanvasByBlood.qml")
            stack.push(newPage, {
                           "mainPersonID": pdb.getProtagonistId()
                       }, StackView.PushTransition)
        }
    }

    function initLoad(path) {
        pdb.loadDB(path)
        console.log("load All Person ", pdb.personListCount())
        reload()
    }

    Component.onDestruction: {
        selectedPerson = null
        stack.clear(StackView.Immediate)
        console.log("Destruction end")
    }

    onUnsavedFlagChanged: {
        if (unsavedFlag) {
            btSaveInfo.text = "保存<font color='red'>⚹</font>"
        } else {
            btSaveInfo.text = "保存"
        }
    }

    onClosing: {
        closeFlag = true
        isUnsaveDialog.replacement = selectedPerson
        isUnsaveDialog.open()
    }
}
