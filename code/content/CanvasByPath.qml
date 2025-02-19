import QtQuick 6.2
import QtQuick.Controls 6.2

Rectangle {
    id: drawCanvas
    width: 1510
    height: 920
    color: "#f5f5f5"
    // property string fromId
    property var fromPerson
    property string toId
    property int centerX: 0
    property int centerY: 0
    property var minScale

    property var connectType

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

        onWheel: wheel => {
                     // console.log("onWheel:", wheel.angleDelta.y)
                     console.log(wheel.x, wheel.y, scaleTransform.xScale,
                                 drawCanvas.x, drawCanvas.y)
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
                         drawCanvas.y += wheel.y * scaleTransform.xScale * 0.1
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
                        "mainPersonID": pi.id,
                        "pdb": pdb
                    }, StackView.PushTransition)
    }

    function loadPerson(load) {
        console.log("loadPerson UI:", load.pi.name)
        var newP
        if (load.posX && load.posY) {
            var newNode = Qt.createComponent("PersonForm.qml")

            if (newNode.status === Component.Ready) {
                newP = newNode.createObject(drawCanvas, {
                                                  "x": load.posX,
                                                  "y": load.posY,
                                                  "z": 2,
                                                  "pi": load.pi
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
        console.log("Add connection:", node1.pi.name, node2.pi.name, type)
        let newConnection = Qt.createComponent("Connections.qml")
        if (newConnection.status === Component.Ready) {
            let newCon = newConnection.createObject(drawCanvas, {
                                                          "node1": node1,
                                                          "node2": node2,
                                                          "type": type
                                                      })
            node1.Component.onDestruction.connect(newCon.autoDestroy)
            node2.Component.onDestruction.connect(newCon.autoDestroy)
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

    function bfsSearch(root, target) {
        if (!root)
            return

        console.log("bfsSearch : ", root.id, root.name, target)

        var findQueue = []
        var findedQueue = new Set([-1])
        var parentMap = []
        // 用于记录父节点
        var path = []
        path.push({
                      "pid": target,
                      "type": -1
                  })

        parentMap[root.id] = {
            "pid": -1,
            "type": connectType.FATHER
        }
        findQueue.push(root)

        var current
        var node
        var i
        var t
        while (findQueue.length > 0) {
            current = findQueue[0]
            findedQueue.add(current.id)
            console.log("find : ", current.id, current.name)

            if (!findedQueue.has(current.father)) {
                parentMap[current.father] = {
                    "pid": current.id,
                    "type": connectType.FATHER
                }
                if (current.father == target) {
                    node = parentMap[current.father]
                    while (node.pid != -1) {
                        console.log("Add path:", node.pid)
                        path.push(node)
                        node = parentMap[node.pid]
                    }
                    console.log("Add path end.")
                    return path
                } else {
                    findQueue.push(pdb.getPerson(current.father))
                    findedQueue.add(current.father)
                }
            }

            if (!findedQueue.has(current.mother)) {
                parentMap[current.mother] = {
                    "pid": current.id,
                    "type": connectType.MOTHER
                }
                if (current.mother == target) {
                    node = parentMap[current.mother]
                    while (node.pid != -1) {
                        path.push(node)
                        node = parentMap[node.pid]
                    }
                    return path
                } else {
                    findQueue.push(pdb.getPerson(current.mother))
                    findedQueue.add(current.mother)
                }
            }

            for (i = 0; i < current.marriages.length; i++) {
                t = current.marriages[i]
                if (!findedQueue.has(t)) {
                    if (i === 0)
                        parentMap[t] = {
                            "pid": current.id,
                            "type": connectType.MATE
                        }
                    else
                        parentMap[t] = {
                            "pid": current.id,
                            "type": connectType.EX
                        }
                    if (t == target) {
                        node = parentMap[t]
                        while (node.pid != -1) {
                            path.push(node)
                            node = parentMap[node.pid]
                        }
                        return path
                    } else {
                        findQueue.push(pdb.getPerson(t))
                        findedQueue.add(t)
                    }
                }
            }

            for (i = 0; i < current.children.length; i++) {
                t = current.children[i]
                if (!findedQueue.has(t)) {
                    parentMap[t] = {
                        "pid": current.id,
                        "type": connectType.CHILDREN
                    }
                    if (t == target) {
                        node = parentMap[t]
                        while (node.pid != -1) {
                            path.push(node)
                            node = parentMap[node.pid]
                        }
                        return path
                    } else {
                        findQueue.push(pdb.getPerson(t))
                        findedQueue.add(t)
                    }
                }
            }

            findQueue.shift()
        }

        return
        // 如果未找到目标节点，返回空路径
    }

    function calculatePosition(node, type, drawNode) {
        if (type === connectType.FATHER) {
            node["posX"] -= 150
            node["posY"] -= 320
        }
        if (type === connectType.MOTHER) {
            node["posX"] += 150
            node["posY"] -= 320
        }
        if (type === connectType.CHILDREN) {
            node["posY"] += 320
        }
        if (type > connectType.CHILDREN) {
            node["posX"] -= 300
            // node["posY"] += 40
        }

        // Check overlay
        for (var i = 0; i < drawNode.length; i++) {
            if (drawNode[i]["posY"] === node["posY"]) {
                if (node["posX"] < drawNode[i]["posX"]) {
                    if (node["posX"] > (drawNode[i]["posX"] - 300))
                        node["posX"] = (drawNode[i]["posX"] - 300)
                } else {
                    if (node["posX"] < (drawNode[i]["posX"] + 300))
                        node["posX"] = (drawNode[i]["posX"] + 300)
                }
            }
        }
    }

    function drawPath(path) {
        console.log("drawPath start")
        // var generation = 50
        // var maxGeneration = generation
        // var minGeneration = generation
        var drawNode = []

        // Calculate path
        var centerPos = {
            "x": drawCanvas.width / 2 - 100,
            "y": drawCanvas.height / 2 - 120
        }
        var node = {
            "posX": centerPos.x,
            "posY": centerPos.y,
            "pi": fromPerson
        }
        var minX = centerPos.x
        var minY = centerPos.y
        var maxX = centerPos.x
        var maxY = centerPos.y
        drawNode.push(node)
        var i
        for (i = (path.length - 2); i >= 0; i--) {
            node = {
                "posX": node["posX"],
                "posY": node["posY"]
            }
            console.log("[", path[i].pid, path[i + 1].type, "]")
            calculatePosition(node, path[i + 1].type, drawNode)
            minX = minX < node["posX"] ? minX : node["posX"]
            maxX = maxX > node["posX"] ? maxX : node["posX"]
            minY = minY < node["posY"] ? minY : node["posY"]
            maxY = maxY > node["posY"] ? maxY : node["posY"]
            node["pi"] = pdb.getPerson(path[i].pid)
            drawNode.push(node)
            // if(path[i+1].type < 2) {
            //     generation += 1
            //     maxGeneration = generation>maxGeneration?generation:maxGeneration
            // }
            // if(path[i+1].type === 2) {
            //     generation -= 1
            //     minGeneration = generation<minGeneration?generation:minGeneration
            // }
        }

        // Adjust display position
        drawCanvas.width = maxX - minX + 300
        drawCanvas.height = maxY - minY + 340
        var shiftX = 50 - minX
        var shiftY = 50 - minY
        for (i = 0; i < drawNode.length; i++) {
            drawNode[i]["posX"] += shiftX
            drawNode[i]["posY"] += shiftY
        }
        // Scale
        console.log("drawCanvas: ", drawCanvas.width, drawCanvas.height)
        if (drawCanvas.width > (drawCanvas.height * 151 / 92)) {
            if (drawCanvas.width > 1510) {
                minScale = 1510 / drawCanvas.width * 0.6
                scaleTransform.xScale = 1510 / drawCanvas.width * 0.9
                scaleTransform.yScale = scaleTransform.xScale
            } else {
                minScale = 0.6
            }
        } else {
            if (drawCanvas.height > 920) {
                minScale = 920 / drawCanvas.height * 0.6
                scaleTransform.xScale = 920 / drawCanvas.height * 0.9
                scaleTransform.yScale = scaleTransform.xScale
            } else {
                minScale = 0.6
            }
        }
        // Move to center
        centerX = Math.round(
                    (1510 - drawCanvas.width * scaleTransform.xScale) / 2)
        centerY = Math.round(
                    (920 - drawCanvas.height * scaleTransform.yScale) / 2)

        // console.log("Path depth:", maxGeneration - minGeneration)

        // Draw path
        var lastP = loadPerson(drawNode[0])
        var currentP
        for (i = 1; i < drawNode.length; i++) {
            currentP = loadPerson(drawNode[i])
            console.log("type index: ", path.length - i)
            addConnection(lastP, currentP, path[path.length - i].type)
            lastP = currentP
        }

        console.log("drawPath end")
    }

    Component.onCompleted: {
        connectType = {
            "FATHER": 0,
            "MOTHER": 1,
            "CHILDREN": 2,
            "MATE": 3,
            "EX": 4
        }
        var path = bfsSearch(fromPerson, toId)
        if (path) {
            console.log("Find path:", path.length)
            for (var i = (path.length - 1); i >= 0; i--) {
                console.log("[", path[i].pid, path[i].type, "]")
            }
            drawPath(path)
        } else
            console.log("Find path empty.")
    }
}
