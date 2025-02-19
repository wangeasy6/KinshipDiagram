import QtQuick 6.2
import QtQuick.Controls 6.2
import "LoadByBlood.js" as LoadBackend

Rectangle {
    id: drawCanvas
    width: 3000
    height: 1800
    color: "#f5f5f5"
    property var mainPersonID
    property var mainPF
    property int centerX: 0
    property int centerY: 0
    property var minScale

    property var lastX: null
    property var lastY: null
    property var lastScale

    transform: Scale {
        id: scaleTransform
    }

    MouseArea {
        anchors.fill: parent
        drag.target: parent
        drag.axis: Drag.XAndYAxis

        // onWheel: (wheel)=> {
        //      console.log("onWheel:", wheel.angleDelta.y)
        //      console.log(wheel.x, wheel.y, drawCanvas.x, drawCanvas.y)
        //      scaleTransform.origin.x = Math.round(wheel.x)
        //      scaleTransform.origin.y = Math.round(wheel.y)
        //     var scaleValue = 1.1
        //     if (wheel.angleDelta.y > 0) {
        //         // 放大
        //         if((scaleTransform.xScale*scaleValue) > 1)
        //          {
        //              scaleTransform.xScale = 1
        //              scaleTransform.yScale = 1
        //          }
        //          else
        //          {
        //                      scaleTransform.xScale *= scaleValue
        //                      scaleTransform.yScale *= scaleValue
        //          }
        //     } else {
        //         // 缩小
        //          if((scaleTransform.xScale/scaleValue) < minScale)
        //          {
        //              scaleTransform.xScale = minScale
        //              scaleTransform.yScale = minScale
        //          }
        //          else
        //          {
        //             scaleTransform.xScale /= scaleValue
        //             scaleTransform.yScale /= scaleValue
        //         }
        //     }
        // }
        onWheel: wheel => {
                     // console.log("onWheel:", wheel.angleDelta.y)
                     // console.log(wheel.x, wheel.y, scaleTransform.xScale, drawCanvas.x, drawCanvas.y)
                     var scaleValue = 1.1
                     if (wheel.angleDelta.y > 0) {
                         // 放大
                         if ((scaleTransform.xScale * scaleValue) > 1)
                         return

                         drawCanvas.x -= wheel.x * scaleTransform.xScale * 0.1
                         drawCanvas.y -= wheel.y * scaleTransform.yScale * 0.1
                         scaleTransform.xScale *= scaleValue
                         scaleTransform.yScale = scaleTransform.xScale
                     } else {
                         // 缩小
                         if ((scaleTransform.xScale / scaleValue) < minScale)
                         return

                         scaleTransform.xScale /= scaleValue
                         scaleTransform.yScale = scaleTransform.xScale
                         drawCanvas.x += wheel.x * scaleTransform.xScale * 0.1
                         drawCanvas.y += wheel.y * scaleTransform.yScale * 0.1
                     }

                     drawCanvas.x = Math.round(drawCanvas.x)
                     drawCanvas.y = Math.round(drawCanvas.y)
                     // console.log(wheel.x, wheel.y, scaleTransform.xScale, drawCanvas.x, drawCanvas.y)
                 }
    }

    function retainLastPos() {
        lastX = drawCanvas.x
        lastY = drawCanvas.y
        lastScale = scaleTransform.xScale
    }

    function restoreLastPos() {
        if (lastX) {
            drawCanvas.x = lastX
            drawCanvas.y = lastY
            scaleTransform.xScale = lastScale
            scaleTransform.yScale = lastScale
        }
    }

    function addPage(pi) {
        console.log("addPage: ", pi.id)
        retainLastPos()
        var newPage = Qt.createComponent("CanvasByBlood.qml")
        parent.push(newPage, {
                        "mainPersonID": pi.id
                    }, StackView.PushTransition)
    }

    function loadPerson(load) {
        console.log("loadPerson UI:", load.target)
        var newP
        if (load.posX && load.posY) {
            var newNode = Qt.createComponent("PersonForm.qml")

            if (newNode.status === Component.Ready) {
                newP = newNode.createObject(drawCanvas, {
                                                  "x": load.posX,
                                                  "y": load.posY,
                                                  "z": load.posZ,
                                                  "pi"// pi: pdb.getPerson(load.target)
                                                  : load.pi
                                              })
                newP.onClicked.connect(setSidePerson)
                newP.onDoubleClicked.connect(addPage)

                if (newP.pi === null) {
                    console.log("xxxx")
                    newP.destroy()
                    newP = null
                    newNode.destroy()
                    newNode = null
                }
            } else {
                console.log("createComponent failed:", newNode.errorString())
            }
        }

        return newP
    }

    function addConnection(node1, node2, type) {
        if (LoadBackend.isLoadedConnect(node1.pi.id, node2.pi.id)) {
            console.log("add Connection conflict:", node1.pi.id, node2.pi.id)
            return
        }
        let newConnection = Qt.createComponent("Connections.qml")
        if (newConnection.status === Component.Ready) {
            let newCon = newConnection.createObject(drawCanvas, {
                                                          "node1": node1,
                                                          "node2": node2,
                                                          "type": type
                                                      })
            node1.Component.onDestruction.connect(newCon.autoDestroy)
            node2.Component.onDestruction.connect(newCon.autoDestroy)
            // console.log("newConnection. ", newCon.node1.x,newCon.node1.y,newCon.node2.x,newCon.node2.y,);
            LoadBackend.setLoadedConnect(node1.pi.id, node2.pi.id)
        }
    }

    function checkOverlap(p, type) {
        var shiftX = 300
        if (type === 1 || type === 2)
            shiftX = -300

        // Check for overlap
        var i = 0
        for (; i < drawCanvas.children.length; i++) {
            if (drawCanvas.children[i].objectName === "PF"
                    && p !== drawCanvas.children[i]) {
                console.log("Child ", i)
                console.log(Math.abs(p.x - drawCanvas.children[i].x))
                if (Math.abs(p.x - drawCanvas.children[i].x) < 300
                        && p.y === drawCanvas.children[i].y)
                    break
            }
        }

        // Adjust PersonForm position
        if (i !== drawCanvas.children.length) {
            console.log("Conflict ", drawCanvas.children[i].name)
            for (i = 0; i < drawCanvas.children.length; i++) {
                if (drawCanvas.children[i].objectName === "PF"
                        && p !== drawCanvas.children[i]) {
                    if (shiftX > 0) {
                        // left
                        if (p.x < drawCanvas.children[i].x
                                && p.y <= drawCanvas.children[i].y) {
                            drawCanvas.children[i].x += shiftX
                            console.log(drawCanvas.children[i].name,
                                        " move ", shiftX)
                        }
                    } else {
                        // right
                        if (p.x > drawCanvas.children[i].x
                                && p.y <= drawCanvas.children[i].y) {
                            drawCanvas.children[i].x += shiftX
                            console.log(drawCanvas.children[i].name,
                                        " move ", shiftX)
                        }
                    }
                }
            }
            p.x += shiftX
            console.log(p.name, " move ", shiftX)
        }
    }

    function onSearchedPerson(child) {
        // Move person to center
        var shiftX = (drawRect.width / 2 - 120) - (child.x * scaleTransform.xScale + drawCanvas.x)
        drawCanvas.x += Math.round(shiftX)
        var shiftY = (drawRect.height / 2 - 100) - (child.y * scaleTransform.yScale + drawCanvas.y)
        drawCanvas.y += Math.round(shiftY)
        console.log(shiftX, shiftY)

        setSidePerson(child)
    }

    function searchInPage(name) {
        var i = 0
        var child
        for (i = drawCanvas.children.length - 1; i >= 0; i--) {
            child = drawCanvas.children[i]
            if (child.objectName === "PF" && child.name === name) {
                onSearchedPerson(child)
                return true
            }
        }
        return false
    }

    function loadUI() {
        console.log("getPerson all:", pdb.personListCount())
        if (pdb.personListCount() < 1)
            return
        LoadBackend.setFrameSize(drawCanvas.width, drawCanvas.height)
        LoadBackend.addCentralRole(pdb.getPerson(mainPersonID), pdb)
        var load = LoadBackend.getNextPerson()
        if (LoadBackend.frameWidth !== drawCanvas.width) {
            console.log("Resize:", drawCanvas.width, " -> ",
                        LoadBackend.frameWidth)
            drawCanvas.width = LoadBackend.frameWidth
        }
        minScale = 1510 / LoadBackend.frameWidth * 0.66
        mainPF = loadPerson(load)
        if (mainPF) {
            setSidePerson(mainPF)

            // Move to center, centerX/y is for StackView
            centerX = -mainPF.x + 655 // (1510 - 200) / 2
            centerY = -mainPF.y + 340 // ( 920 - 240) / 2
            drawCanvas.x = centerX
            drawCanvas.y = centerY
        }

        while ((load = LoadBackend.getNextPerson()) !== null) {
            loadPerson(load)
        }

        var count = drawCanvas.children.length
        for (var i = 0; i < count; i++) {
            if (drawCanvas.children[i].objectName === "PF") {
                var pi = drawCanvas.children[i].pi
                if (pi)
                    for (var j = pi.children.length - 1; j >= 0; j--) {
                        for (var k = 0; k < count; k++) {
                            if (drawCanvas.children[k].objectName === "PF"
                                    && drawCanvas.children[k].pi
                                    && drawCanvas.children[k].pi.id === pi.children[j])
                                addConnection(drawCanvas.children[i],
                                              drawCanvas.children[k], 2)
                        }
                    }
            }
        }

        console.log("Load End.")
    }

    function clearUI() {
        var i = 0
        var child
        // for (i = drawCanvas.children.length - 1; i >= 0; i--) {
        //     child = drawCanvas.children[i];
        //     if(child.objectName === "CT")
        //     {
        //         child.parent = null
        //         child.destroy()
        //     }
        // }
        for (i = drawCanvas.children.length - 1; i >= 0; i--) {
            child = drawCanvas.children[i]
            if (child.objectName === "PF") {
                console.log("Clear UI:", child.name)
                child.parent = null
                child.destroy()
            }
        }
        LoadBackend.clear()
        drawCanvas.update()
    }

    function redraw() {
        retainLastPos()
        clearUI()
        loadUI()
        restoreLastPos()
    }

    Component.onCompleted: {
        loadUI()
    }
}
