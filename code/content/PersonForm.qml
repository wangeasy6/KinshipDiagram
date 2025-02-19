import QtQuick 6.2
import QtQuick.Controls 6.2
import Qt5Compat.GraphicalEffects
import easy.qt.Person 0.1

Rectangle {
    width: 200
    height: 240
    property PersonInfo pi
    property bool gender: pi ? pi.gender : true
    property int type: 0
    property string name: pi ? pi.name : ""
    property string avatarPath: ""
    // property string avatarPath: pi?pi.avatarPath:""
    property bool isMain: pi ? pi.protagonist : false
    property bool selected: false
    // property int generation: 0
    // property int anchor: 0  // 0 = Left; 1 = Right
    // property PersonForm neighborL
    // property PersonForm neighborR
    // property PersonForm father
    // property PersonForm mother
    // property var childrens:[]
    // property var marriages:[]
    // property int x1: 0
    // property int x2: 0
    color: gender ? "#63B8FF" : "#FFC0CB" // male : female
    radius: 10
    border.width: 3
    border.color: selected ? gender ? "#FFC0CB" : "#63B8FF" : color
    smooth: true
    z: 1
    signal clicked(PersonForm p)
    signal doubleClicked(PersonInfo pi)
    objectName: "PF"
    property alias imgAvatar: avatar

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
