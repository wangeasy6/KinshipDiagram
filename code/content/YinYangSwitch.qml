import QtQuick
import QtQuick.Controls

Switch {
    id: control
    width: 42
    height: 42

    property color yangColor: "#F6F6F6"
    property color yinColor: "#555555"

    indicator: Rectangle {
        id: bg
        implicitWidth: control.width
        implicitHeight: control.height
        radius: height/2
        color: control.checked ? yangColor : yinColor
        border.color: Qt.darker(color, 1.2)

        Rectangle {
            width: parent.width - 4
            height: parent.height - 4
            radius: height/2
            color: control.checked ? yinColor : yangColor
            border.width: 1
            border.color: control.checked?Qt.lighter(color, 3):Qt.darker(color, 2)
            y: 2
            x: 2

            Behavior on x {
                NumberAnimation { duration: 200 }
            }

            Text {
                anchors.centerIn: parent
                // text: control.checked ? "阴" : "阳"
                text: control.checked ? "农" : "公"
                font {
                    family: "SimSun"
                    pixelSize: Math.min(parent.height*0.6, parent.width*0.6)
                    bold: true
                }
                color: control.checked ? yangColor : yinColor
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: control.checked = !control.checked
    }
}
