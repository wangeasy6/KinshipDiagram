import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts
import Qt.labs.platform
import Qt5Compat.GraphicalEffects

Rectangle {
    id: thisPage
    width: 1000
    height: 400
    color: "#E5E5E5"
    anchors.centerIn: parent
    radius: 10
    signal finished(bool updateFlag)
    property var startPersonId
    property var startPerson
    property var fatherP
    property var motherP

    property int isSync
    property Item theItem: null
    property bool isChanged: false

    // layer.enabled: true
    // layer.effect: DropShadow {
    //     transparentBorder: true
    //     horizontalOffset: 15
    //     verticalOffset: 20
    //     color: "#C0CCCCCC"
    //     spread: 0
    // }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        ColumnLayout {
            id: fatherLayout
            Layout.preferredHeight: 240
            Layout.fillWidth: true

            // Father
            Label {
                id: fatherLabel
                text: "父排行"
                Layout.fillWidth: true
                font.pointSize: 11
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true

                ListModel {
                    id: fatherList
                }

                ListView {
                    id: fatherView
                    anchors.fill: parent
                    anchors.margins: 10
                    clip: true
                    model: fatherList
                    orientation: ListView.Horizontal
                    spacing: 10
                    interactive: true

                    delegate: Rectangle {
                        id: delegataRec
                        height: 220
                        width: 180
                        color: pinfo.gender ? "#63B8FF" : "#FFC0CB"
                        radius: 10
                        // anchors.centerIn: parent
                        smooth: true

                        onXChanged: {
                            if (delegataRec != theItem)
                                return
                            var index_ = (theItem.x / 190).toFixed(0)
                            if (index_ >= fatherList.count)
                                index_ = fatherList.count - 1
                            if (index_ < 0)
                                index_ = 0
                            if (Number(index_) !== Number(index)) {
                                fatherList.move(index, index_, 1)
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            drag.target: delegataRec
                            drag.axis: Drag.XAxis
                            hoverEnabled: true
                            onPressed: {
                                theItem = delegataRec
                                console.log("press:", index, pinfo.name)
                            }
                            onReleased: {
                                delegataRec.x = index * 190
                                console.log("release:", index, pinfo.name)
                            }
                        }

                        Column {
                            anchors.fill: parent

                            Item {
                                width: delegataRec.width
                                height: delegataRec.width

                                Image {
                                    id: avatar
                                    width: 160
                                    height: 160
                                    source: pinfo.avatarPath !== "icons/person.svg" ? conf.dbPrefix + pinfo.avatarPath : pinfo.avatarPath
                                    fillMode: Image.PreserveAspectCrop
                                    visible: false
                                    anchors.centerIn: parent
                                }

                                Rectangle {
                                    id: mask
                                    width: avatar.width
                                    height: avatar.height
                                    radius: width / 2
                                    smooth: true
                                    visible: false
                                    color: "#FE958F"
                                }

                                OpacityMask {
                                    anchors.fill: avatar
                                    source: avatar
                                    maskSource: mask
                                }
                            }

                            Text {
                                text: pinfo.name
                                width: delegataRec.width
                                horizontalAlignment: Text.AlignHCenter
                                font.pointSize: 10
                                font.bold: true
                                color: "white"
                            }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            id: motherLayout
            Layout.preferredHeight: 240
            Layout.fillWidth: true

            Label {
                text: "母排行"
                Layout.fillWidth: true
                font.pointSize: 11
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true

                ListModel {
                    id: motherList
                }

                ListView {
                    id: motherView
                    anchors.fill: parent
                    anchors.margins: 10
                    clip: true
                    model: motherList
                    orientation: ListView.Horizontal
                    spacing: 10
                    interactive: true
                    delegate: Rectangle {
                        id: delegataRec2
                        height: 220
                        width: 180
                        color: pinfo.gender ? "#63B8FF" : "#FFC0CB"
                        radius: 10
                        // anchors.centerIn: parent
                        smooth: true

                        onXChanged: {
                            if (delegataRec2 != theItem)
                                return
                            var index_ = (theItem.x / 190).toFixed(0)
                            if (index_ >= motherList.count)
                                index_ = motherList.count - 1
                            if (index_ < 0)
                                index_ = 0
                            if (Number(index_) !== Number(index)) {
                                motherList.move(index, index_, 1)
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            drag.target: delegataRec2
                            drag.axis: Drag.XAxis
                            hoverEnabled: true
                            onPressed: {
                                theItem = delegataRec2
                                console.log("press:", index, pinfo.name)
                            }
                            onReleased: {
                                delegataRec2.x = index * 190
                                console.log("release:", index, pinfo.name)
                            }
                        }

                        Column {
                            anchors.fill: parent

                            Item {
                                width: delegataRec2.width
                                height: delegataRec2.width

                                Image {
                                    id: avatar2
                                    width: 160
                                    height: 160
                                    source: pinfo.avatarPath !== "icons/person.svg" ? conf.dbPrefix + pinfo.avatarPath : pinfo.avatarPath
                                    fillMode: Image.PreserveAspectCrop
                                    visible: false
                                    anchors.centerIn: parent
                                }

                                Rectangle {
                                    id: mask2
                                    width: avatar2.width
                                    height: avatar2.height
                                    radius: width / 2
                                    smooth: true
                                    visible: false
                                    color: "#FE958F"
                                }

                                OpacityMask {
                                    anchors.fill: avatar2
                                    source: avatar2
                                    maskSource: mask2
                                }
                            }

                            Text {
                                text: pinfo.name
                                width: delegataRec2.width
                                horizontalAlignment: Text.AlignHCenter
                                font.pointSize: 10
                                font.bold: true
                                color: "white"
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            // Buttons
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
                // Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pointSize: 16

                onClicked: {
                    for (var i = 0; i < fatherList.count; i++) {
                        console.log(i, fatherList.get(i).pinfo.id,
                                    fatherList.get(i).pinfo.name)
                    }

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
                // Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pointSize: 16

                onClicked: {
                    saveData()
                    thisPage.finished(isChanged)
                    thisPage.destroy()
                }
            }
        }
    }

    Component.onCompleted: {
        var i = 0
        // Only mother
        if (isSync === -1) {
            fatherLayout.visible = false
            fatherLayout.enabled = false
            motherP = pdb.getMother(startPersonId)
            for (i = 0; i < motherP.children.length; i++) {
                motherList.append({
                                      "pinfo": pdb.getPerson(
                                                   motherP.children[i])
                                  })
            }
        }
        // Only father
        if (isSync === -2) {
            motherLayout.visible = false
            motherLayout.enabled = false
            fatherP = pdb.getFather(startPersonId)
            for (i = 0; i < fatherP.children.length; i++) {
                fatherList.append({
                                      "pinfo": pdb.getPerson(
                                                   fatherP.children[i])
                                  })
            }
        }
        // Sync
        if (isSync === 0) {
            motherLayout.visible = false
            motherLayout.enabled = false
            fatherLabel.text = "排名"
            fatherP = pdb.getFather(startPersonId)
            motherP = pdb.getMother(startPersonId)
            for (i = 0; i < fatherP.children.length; i++) {
                fatherList.append({
                                      "pinfo": pdb.getPerson(
                                                   fatherP.children[i])
                                  })
            }
        }
        if (isSync === 1) {
            thisPage.height = 680
            fatherP = pdb.getFather(startPersonId)
            for (i = 0; i < fatherP.children.length; i++) {
                fatherList.append({
                                      "pinfo": pdb.getPerson(
                                                   fatherP.children[i])
                                  })
            }
            motherP = pdb.getMother(startPersonId)
            for (i = 0; i < motherP.children.length; i++) {
                motherList.append({
                                      "pinfo": pdb.getPerson(
                                                   motherP.children[i])
                                  })
            }
        }
    }

    function saveData() {
        var flag = false
        var i
        var childrenStr = ""

        if (fatherList.count > 1) {
            for (i = 0; i < fatherList.count; i++) {
                if (fatherList.get(i).pinfo.id !== fatherP.children[i]) {
                    flag = true
                    pdb.updateFRanking(fatherList.get(i).pinfo.id, i)

                    if (isSync === 0)
                        pdb.updateMRanking(fatherList.get(i).pinfo.id, i)
                }
                childrenStr += fatherList.get(i).pinfo.id + ","
            }

            if (flag) {
                isChanged = true
                pdb.updateChildren(fatherP.id, childrenStr)
                if (isSync === 0)
                    pdb.updateChildren(motherP.id, childrenStr)
            }
        }

        if (motherList.count > 1) {
            flag = false
            childrenStr = ""

            for (i = 0; i < motherList.count; i++) {
                if (motherList.get(i).pinfo.id !== motherP.children[i]) {
                    flag = true
                    pdb.updateMRanking(motherList.get(i).pinfo.id, i)
                }
                childrenStr += motherList.get(i).pinfo.id + ","
            }

            if (flag) {
                isChanged = true
                pdb.updateChildren(motherP.id, childrenStr)
            }
        }
    }
}
