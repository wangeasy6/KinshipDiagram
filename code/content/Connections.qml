import QtQuick 6.2
import QtQuick.Shapes 1.2

Shape {
    id: thisPage
    objectName: "CT"
    antialiasing: true
    property var node1: null
    property var node1x: node1 ? node1.x : 0
    property var node1y: node1 ? node1.y : 0
    property var node2: null
    property var node2x: node2 ? node2.x : 0
    property var node2y: node2 ? node2.y : 0
    property int type: 0
    z: 0

    ShapePath {
        id: sp
        property int endX
        property int endY
        property int w
        property int h
        property bool direction: startX < endX // true: right; false: left

        strokeColor: "black"
        strokeWidth: 5
        strokeStyle: ShapePath.SolidLine
        fillColor: "transparent"
        capStyle: ShapePath.RoundCap
        joinStyle: ShapePath.RoundJoin

        // fillGradient: LinearGradient {
        //     x1: sp.startX
        //     y1: sp.startY
        //     x2: sp.endX
        //     y2: sp.endY
        //     GradientStop { position: 0.0; color: "white" }
        //     GradientStop { position: 1.0; color: "black" }
        // }

        // startX: node1?node1.x:0
        // startY: node1?node1.y:0
        PathLine {
            id: line1
        }

        PathArc {
            id: arc1
            direction: PathArc.Counterclockwise
            // useLargeArc: true
        }

        PathLine {
            id: line2
        }

        PathArc {
            id: arc2
            // useLargeArc: true
        }

        PathLine {
            id: line3
            x: sp.endX
            y: sp.endY
        }
    }

    function drawLine() {
        if (!node1 || !node2)
            return
        if (type < 3) // Blood connection
        {
            if (node1.y > node2.y) {
                sp.startX = node2.x + node2.width / 2
                sp.startY = node2.y + node2.height
                sp.endX = node1.x + node1.width / 2
                sp.endY = node1.y
                sp.strokeColor = node2.color
            } else {
                sp.startX = node1.x + node1.width / 2
                sp.startY = node1.y + node1.height
                sp.endX = node2.x + node2.width / 2
                sp.endY = node2.y
                sp.strokeColor = node1.color
            }
            sp.w = Math.abs(sp.startX - sp.endX)
            sp.h = Math.abs(sp.startY - sp.endY)
            console.log("draw connection: ", sp.startX, sp.startY, sp.endX,
                        sp.endY, sp.w, sp.h)

            if (sp.w !== 0 && sp.h !== 0) {
                radius = sp.w < sp.h ? (sp.w / 4) : (sp.h / 4)
                line1.x = sp.startX
                // line1.y = sp.startY + (sp.h - radius * 2) / 2
                if (sp.h === 80)
                    line1.y = sp.startY + 40 - radius
                else
                    line1.y = sp.startY + 20 - radius
                line1.relativeY = line1.y - sp.startY
                arc1.radiusX = radius
                arc1.radiusY = radius
                arc1.y = line1.y + radius
                line2.y = arc1.y
                arc2.radiusX = radius
                arc2.radiusY = radius
                if (sp.direction) {
                    // left
                    arc1.relativeX = radius
                    line2.relativeX = sp.w - radius * 2
                    line2.x = sp.startX + sp.w - radius
                    arc2.relativeX = radius
                    arc2.y = sp.endY - (sp.h - radius * 2) / 2
                    if (node1.gender)
                        arc2.y -= 8
                    arc1.direction = PathArc.Counterclockwise
                    arc2.direction = PathArc.Clockwise
                } else {
                    arc1.relativeX = -radius
                    arc1.relativeY = radius
                    line2.relativeX = -(sp.w - radius * 2)
                    line2.x = sp.startX - sp.w + radius // sp.endX + radius
                    // arc1.y = line1.y + radius
                    arc2.relativeX = -radius
                    arc2.relativeY = radius
                    arc2.y = sp.endY - (sp.h - radius * 2) / 2
                    if (node1.gender)
                        arc2.y -= 8
                    arc1.direction = PathArc.Clockwise
                    arc2.direction = PathArc.Counterclockwise
                }
            }
            if (sp.w === 0) // Vertical line
            {
                line1.relativeX = 0
                line1.relativeY = 0
                line2.relativeX = 0
                line2.relativeY = 0
                arc1.relativeX = 0
                arc1.relativeY = 0
                arc2.relativeX = 0
                arc2.relativeY = 0
            }
            // if(sp.h === 0)   // Never happen/Inbreeding
            // {
            //     line1.relativeX = 0
            //     line1.relativeY = 0
            //     line3.relativeX = 0
            //     line3.relativeY = 0
            //     line2.x = sp.endX
            //     line2.y = sp.endY
            // }
        }
        if (type === 3) {
            // Mate
            line1.relativeX = 0
            line1.relativeY = 0
            line3.relativeX = 0
            line3.relativeY = 0
            sp.startX = node1.x
            sp.startY = node1.y + node1.height / 2
            sp.endX = node2.x + node2.width
            sp.endY = node2.y + node2.height / 2
            line2.x = sp.endX
            line2.y = sp.endY
            sp.strokeColor = node1.color
        }
        if (type === 4) {
            // Ex
            line1.relativeX = 0
            line1.relativeY = 0
            line3.relativeX = 0
            line3.relativeY = 0
            sp.startX = node1.x
            sp.startY = node1.y + node1.height / 2
            sp.endX = node2.x + node2.width
            sp.endY = node2.y + node2.height / 2
            line2.x = sp.endX
            line2.y = sp.endY
            sp.strokeColor = node1.color
            sp.strokeStyle = ShapePath.DashLine
        }
    }

    // onNode1xChanged: {
    //     drawLine()
    // }

    // onNode1yChanged: {
    //     drawLine()
    // }

    // onNode2xChanged: {
    //     drawLine()
    // }

    // onNode2yChanged: {
    //     drawLine()
    // }
    Component.onCompleted: {
        drawLine()
    }

    // onNode1Changed: {
    //     console.log("onNode1Changed ", node1)
    //     if (!node1)
    //     {
    //         console.log("node1 miss.")
    //         this.destory()
    //     }
    // }

    // onNode2Changed: {
    //     console.log("onNode2Changed ", node2)
    //     if (!node2){
    //         console.log("node2 miss.")
    //         this.destory()
    //     }
    // }
    function autoDestroy() {
        // console.log("line autoDestroy")
        if (thisPage)
            thisPage.destroy()
    }
}
