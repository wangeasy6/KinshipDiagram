import QtQuick 6.2
import QtQuick.Controls 6.2
import Qt5Compat.GraphicalEffects
import easy.qt.Person 0.1

Rectangle {
    id: content
    objectName: "PF"
    width: 200
    height: 240
    color: gender ? "#63B8FF" : "#FFC0CB" // male : female
    radius: 10
    border.width: 3
    border.color: selected ? gender ? "#FFC0CB" : "#63B8FF" : color
    smooth: true
    z: 1

    property alias imgAvatar: avatar
    property PersonInfo pi
    property bool gender: pi ? pi.gender : true
    property int type: -1
    property string name: pi ? pi.name : ""
    property string avatarPath: ""
    property bool isMain: pi ? pi.protagonist : false
    property bool selected: false

    signal clicked(PersonForm p)
    signal doubleClicked(PersonInfo pi)

    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 3
        verticalOffset: 4
        color: "#C0CCCCCC"
    }

    Image {
        id: maritalStatus
        width: 30
        height: 30
        smooth: true
        fillMode: Image.PreserveAspectFit
        visible: type>2
        anchors.right: parent.left
        anchors.bottom: parent.bottom
        anchors.rightMargin: -195
        anchors.bottomMargin: 15
        z: 2
    }

    Image {
        id: star
        width: 20
        height: 20
        source: "icons/red_star_full.svg"
        fillMode: Image.PreserveAspectCrop
        visible: isMain
        anchors.right: parent.left
        anchors.top: parent.top
        anchors.rightMargin: -30
        anchors.topMargin: 10
        z: 2
    }

    Rectangle {
        id: deadFlag
        width: 20
        height: 20
        visible: pi ? pi.isDead : false
        radius: 10
        border.width: 0
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 10
        anchors.topMargin: 10
        color: "#DDDDDD"
        z: 2
    }

    Column {
        z: 1
        anchors.fill: parent

        // spacing: 5
        Item {
            width: 200
            height: 200

            Image {
                id: avatar
                width: 170
                height: 170
                source: avatarPath
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
            text: name
            width: 200
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 10
            font.bold: true
            color: "white"
        }
    }

    onTypeChanged: {
        if (type > 2)
        {
            console.log(name, " type - ", type)
            if (type === 3) {
                maritalStatus.source = "icons/heart-red.svg"
            }
            else{
                if(pdb.getSettings().marriageMode === "ancient")
                    maritalStatus.source = "icons/heart-pink.svg"
                else
                    maritalStatus.source = "icons/heart-break.svg"
            }
        }
    }

    onPiChanged: {
        if (pi) {
            if (pi.avatarPath === "")
                avatarPath = "icons/person.svg"
            else if (!pi.avatarPath.startsWith("icons/")
                     && !pi.avatarPath.startsWith("file:/"))
                avatarPath = conf.dbPrefix + pi.avatarPath
            else
                avatarPath = pi.avatarPath
        }
    }

    MouseArea {
        anchors.fill: parent
        // propagateComposedEvents: true
        onClicked: {
            parent.clicked(parent)
            // mouse.accepted = false
        }
        onDoubleClicked: {
            parent.doubleClicked(pi)
            // mouse.accepted = false
        }
    }
}
