var gLoadingPersonNode = []
var gLoadingPersonQueue = []
var gLoadedConnectList = new Set([])
var gLoadingConnectQueue = []

var gGeneration = 2
var gXBoundary = [[-1, 3000], // index 0: R; 1: L
                  [-1, 3000], [-1, 3000], [-1, 3000]]
var frameWidth = 0
var gCenterPos = {
    "x": 0,
    "y": 0
}

const connectType = {
    "FATHER": 0,
    "MOTHER": 1,
    "CHILDREN": 2,
    "MATE": 3,
    "EX": 4
    // SON: 4,
    // GIRL: 5
}

function clear() {
    gLoadingPersonNode = []
    gLoadingPersonQueue = []
    gLoadedConnectList.clear()
    gLoadingConnectQueue = []
    gGeneration = 2
    gXBoundary = [[-1, 3000], [-1, 3000], [-1, 3000], [-1, 3000]]
    frameWidth = 0
    gCenterPos = {
        "x": 0,
        "y": 0
    }
}

function getBoundary(level, anchor) {
    var x = gXBoundary[level][anchor]
    for (var i = level - 1; i >= 0; i--) {
        var x1 = gXBoundary[i][anchor]
        if (x1 === -1)
            break
        x = x < x1 ? anchor ? x : x1 : anchor ? x1 : x
    }
    return x
}

function getPosX(level, anchor, posX) {
    var x = getBoundary(level, anchor)
    if (x === -1) {
        return posX
    }

    return posX < x ? anchor ? posX : x : anchor ? x : posX
}

function setBoundary(level, x) {
    var left = x - 300
    var right = x + 300
    if (level <= 3 && level >= 0) {
        if (gXBoundary[level][1] === -1 || left < gXBoundary[level][1]) {
            gXBoundary[level][1] = left
        }
        if (gXBoundary[level][0] === -1 || right > gXBoundary[level][0]) {
            gXBoundary[level][0] = right
        }
    }
}

function setFrameSize(w, h) {
    frameWidth = w
    setFrameCenterPoint(w / 2 - 100, h / 2 - 120)
}

function setFrameCenterPoint(x, y) {
    gCenterPos.x = x
    gCenterPos.y = y
    setBoundary(2, x)
}

function adjustCenter() {
    var rightX = getBoundary(3, 0)
    var leftX = getBoundary(3, 1)
    var resizeW = rightX - leftX
    if (resizeW > frameWidth) {
        frameWidth = resizeW
        gCenterPos.x = frameWidth / 2 - 100
    }

    var boundaryCenterX = (leftX + rightX) / 2
    // console.log("adjustCenter" , boundaryCenterX, gCenterPos.x)
    var adjustX = gCenterPos.x - boundaryCenterX
    for (let x in gLoadingPersonNode) {
        var node = gLoadingPersonNode[x]
        node.posX += adjustX
    }
}

function pushPersonQueue(p) {
    if (!gLoadingPersonQueue.includes(p)) {
        gLoadingPersonQueue.push(p)
    }
}

function isLoadedPerson(p) {
    return gLoadingPersonQueue.includes(p)
}

function setLoadedConnect(p1, p2) {
    let c = p1 < p2 ? p1 * 10000 + p2 : p2 * 10000 + p1
    if (!gLoadedConnectList.has(c)) {
        // console.log("setLoadedConnect:", c, p1, p2)
        gLoadedConnectList.add(c)
    }
}

function isLoadedConnect(p1, p2) {
    let c = p1 < p2 ? p1 * 10000 + p2 : p2 * 10000 + p1
    return gLoadedConnectList.has(c)
}

function calculatePositionUp1(load) {
    let p1 = load.start
    let type = load.type
    if (type === connectType.FATHER) {
        load["posX"] = p1.x - 300
        load["posY"] = p1.y - 320
    }
    if (type === connectType.MOTHER) {
        load["posX"] = p1.x + 300
        load["posY"] = p1.y - 320
    }
}

function calculatePositionUp2(load) {
    let p1 = load.start
    let type = load.type
    let index = load.index

    if (type === connectType.FATHER) {
        load["posX"] = p1.x - 150
        load["posY"] = p1.y - 320
    }
    if (type === connectType.MOTHER) {
        load["posX"] = p1.x + 150
        load["posY"] = p1.y - 320
    }
}

function calculatePosition(load) {
    let p1 = load.start
    // let p2 = load.end
    let type = load.type
    let index = load.index

    var mateShiftX = 130

    if (type === connectType.FATHER) {
        load["posX"] = p1.x - 150
        load["posY"] = p1.y - 320
    }
    if (type === connectType.MOTHER) {
        load["posX"] = p1.x + 150
        load["posY"] = p1.y - 320
    }
    if (type === connectType.MATE) {
        load["posX"] = p1.x + mateShiftX
        load["posY"] = p1.y + 30
    }
    if (type === connectType.EX) {
        let xPos = index * mateShiftX + mateShiftX
        load["posX"] = p1.x + xPos
        load["posY"] = p1.y + 30
    }
    if (type === connectType.CHILDREN) {
        let xPos = index * 300

        let mateShift = load["pi"].marriages.length * mateShiftX
        if (load["pi"].marriages[0] === -1)
            mateShift -= mateShiftX

        var posX = getBoundary(load.generation, load.anchor)
        if (load.anchor) {
            load["posX"] = p1.x - xPos
            posX -= mateShift
            load["posY"] = p1.y + 320
            load["posX"] = posX < load["posX"] ? posX : load["posX"]
        } else {
            load["posX"] = p1.x + xPos
            load["posY"] = p1.y + 320
            load["posX"] = getPosX(load.generation, load.anchor, load["posX"])
        }

        // console.log("[getPosX]", load.generation, load.anchor, load["posX"])
        // console.log("[getPosX] Ret: ", load["posX"])
    }
}

function addByDepth(pi, piPos, pdb, anchor) {
    var i
    var node

    // var pi = pdb.getPerson(pid)
    if (pi === null) {
        console.log("Get pi is null.")
        return
    }
    console.log("addLoading Dep: ", pi.name)

    for (i = pi.marriages.length - 1; i >= 0; i--) // for(i=0; i < pi.marriages.length; i++)
    {
        let type = i === 0 ? connectType.MATE : connectType.EX
        if (pi.marriages[i] !== -1 && !isLoadedPerson(pi.marriages[i])) {
            if (pi.marriages[0] === -1) {
                node = {
                    "start": piPos,
                    "target": pi.marriages[i],
                    "type": type,
                    "index": i - 1,
                    "anchor": anchor,
                    "generation": gGeneration,
                    "posZ": 0,
                    "pi": pdb.getPerson(pi.marriages[i])
                }
            }
            else {
                node = {
                    "start": piPos,
                    "target": pi.marriages[i],
                    "type": type,
                    "index": i,
                    "anchor": anchor,
                    "generation": gGeneration,
                    "posZ": 0,
                    "pi": pdb.getPerson(pi.marriages[i])
                }
            }
            calculatePosition(node)
            gLoadingPersonNode.push(node)
            pushPersonQueue(node.target)
            if (!anchor)
                setBoundary(node.generation, node.posX)
        }
    }

    if (gGeneration < 1)
        return

    if (anchor) // 1: To left
    {
        for (i = pi.children.length - 1; i >= 0; i--) {
            if (!isLoadedPerson(pi.children[i])) {
                gGeneration -= 1
                node = {
                    "start": piPos,
                    "target": pi.children[i],
                    "type": connectType.CHILDREN,
                    "index": pi.children.length - 1 - i,
                    "anchor": anchor,
                    "generation": gGeneration,
                    "posZ": 1,
                    "pi": pdb.getPerson(pi.children[i])
                }
                calculatePosition(node)
                gLoadingPersonNode.push(node)
                pushPersonQueue(node.target)
                setBoundary(node.generation, node.posX)
                addByDepth(node.pi, {
                               "x": node.posX,
                               "y": node.posY
                           }, pdb, anchor)
                gGeneration += 1
            }
        }
    } else {
        for (i = 0; i < pi.children.length; i++) {
            if (!isLoadedPerson(pi.children[i])) {
                gGeneration -= 1
                node = {
                    "start": piPos,
                    "target": pi.children[i],
                    "type": connectType.CHILDREN,
                    "index": i,
                    "anchor": anchor,
                    "generation": gGeneration,
                    "posZ": 1,
                    "pi": pdb.getPerson(pi.children[i])
                }
                calculatePosition(node)
                gLoadingPersonNode.push(node)
                pushPersonQueue(node.target)
                setBoundary(node.generation, node.posX)
                addByDepth(node.pi, {
                               "x": node.posX,
                               "y": node.posY
                           }, pdb, anchor)
                gGeneration += 1
            }
        }
    }
}

function addCentralRole(pi, pdb) {
    console.log("+++++++++++++++ addCentralRole +++++++++++++++")

    var node
    var father
    var mother

    // Add protagonist
    node = {
        "start": drawCanvas,
        "target": pi.id,
        "posX": gCenterPos.x,
        "posY": gCenterPos.y,
        "anchor": 0,
        "generation": 2,
        "posZ": 1,
        "pi": pdb.getPerson(pi.id)
    }
    gLoadingPersonNode.push(node)
    setBoundary(node.generation, node.posX)
    pushPersonQueue(pi.id)

    if (pi.father !== -1) {
        console.log("addLoading: ", pi.father)
        pushPersonQueue(pi.father)
        father = pdb.getPerson(pi.father)

        node = {
            "start": gCenterPos,
            "target": pi.father,
            "type": connectType.FATHER,
            "anchor": 1,
            "generation": 3,
            "posZ": 1,
            "pi": father
        }
        calculatePositionUp1(node)
        gLoadingPersonNode.push(node)
        setBoundary(node.generation, node.posX)

        var fatherPos = {
            "x": node.posX,
            "y": node.posY
        }
        if (father && father.father !== -1) {
            console.log("addLoading: ", father.father)
            node = {
                "start": fatherPos,
                "target": father.father,
                "type": connectType.FATHER,
                "anchor": 1,
                "generation": 4,
                "posZ": 1,
                "pi": pdb.getPerson(father.father)
            }
            calculatePositionUp2(node)
            gLoadingPersonNode.push(node)

            pushPersonQueue(father.father)
        }

        if (father && father.mother !== -1) {
            console.log("addLoading: ", father.mother)
            node = {
                "start": fatherPos,
                "target": father.mother,
                "type": connectType.MOTHER,
                "anchor": 1,
                "generation": 4,
                "posZ": 1,
                "pi": pdb.getPerson(father.mother)
            }
            calculatePositionUp2(node)
            gLoadingPersonNode.push(node)

            pushPersonQueue(father.mother)
        }
    }

    if (pi.mother !== -1) {
        console.log("addLoading: ", pi.mother)
        pushPersonQueue(pi.mother)
        mother = pdb.getPerson(pi.mother)

        node = {
            "start": gCenterPos,
            "target": pi.mother,
            "type": connectType.MOTHER,
            "anchor": 0,
            "generation": 3,
            "posZ": 1,
            "pi": mother
        }
        calculatePositionUp1(node)
        gLoadingPersonNode.push(node)
        setBoundary(node.generation, node.posX)

        var motherPos = {
            "x": node.posX,
            "y": node.posY
        }
        if (mother && mother.father !== -1) {
            console.log("addLoading: ", mother.father)
            node = {
                "start": motherPos,
                "target": mother.father,
                "type": connectType.FATHER,
                "anchor": 0,
                "generation": 4,
                "posZ": 1,
                "pi": pdb.getPerson(mother.father)
            }
            calculatePositionUp2(node)
            gLoadingPersonNode.push(node)

            pushPersonQueue(mother.father)
        }

        if (mother && mother.mother !== -1) {
            console.log("addLoading: ", mother.mother)
            node = {
                "start": motherPos,
                "target": mother.mother,
                "type": connectType.MOTHER,
                "anchor": 0,
                "generation": 4,
                "posZ": 1,
                "pi": pdb.getPerson(mother.mother)
            }
            calculatePositionUp2(node)
            gLoadingPersonNode.push(node)

            pushPersonQueue(mother.mother)
        }
    }

    const n = gLoadingPersonNode.length
    for (var i = 0; i < n; i++) {
        node = gLoadingPersonNode[i]
        gGeneration = node.generation
        addByDepth(node.pi, {
                       "x": node.posX,
                       "y": node.posY
                   }, pdb, node.anchor)
    }

    adjustCenter()
    console.log("addCentralRole : ", gLoadingPersonQueue)
    for (let x in gLoadingPersonNode) {
        node = gLoadingPersonNode[x]
        console.log(node.target, node.posX, node.posY, node.anchor,
                    node.generation)
    }
    console.log("--------------- addCentralRole ---------------")
}

function addLoading(p) {
    var node

    if (p.pi.father !== -1 && !isLoadedConnect(p.pi.id, p.pi.father,
                                               connectType.FATHER)) {
        console.log(p.pi.id, "addLoading: ", p.pi.father)
        node = {
            "start": p,
            "end": p.pi.father,
            "type": connectType.FATHER
        }
        calculatePosition(node)
        gLoadingConnectQueue.push(node)
    }

    if (p.pi.mother !== -1 && !isLoadedConnect(p.pi.id, p.pi.mother,
                                               connectType.mother)) {
        console.log(p.pi.id, "addLoading: ", p.pi.mother)
        node = {
            "start": p,
            "end": p.pi.mother,
            "type": connectType.mother
        }
        calculatePosition(node)
        gLoadingConnectQueue.push(node)
    }

    let i

    for (i = 0; i < p.pi.children.length; i++) {
        if (!isLoadedConnect(p.pi.id, p.pi.children[i], connectType.CHILDREN)) {
            console.log(p.pi.id, "addLoading: ", p.pi.children[i])
            node = {
                "start": p,
                "end": p.pi.children[i],
                "type": connectType.CHILDREN,
                "index": i,
                "posZ": 1
            }
            calculatePosition(node)
            gLoadingConnectQueue.push(node)
        }
    }

    for (i = 0; i < p.pi.marriages.length; i++) {
        let type = i === 0 ? connectType.MATE : connectType.EX
        if (p.pi.marriages[i] !== -1 && !isLoadedConnect(p.pi.id,
                                                         p.pi.marriages[i],
                                                         type)) {
            console.log(p.pi.id, "addLoading: ", p.pi.marriages)
            node = {
                "start": p,
                "end": p.pi.marriages[i],
                "type": type,
                "index": i,
                "posZ": 0
            }
            calculatePosition(node)
            gLoadingConnectQueue.push(node)
        }
    }
}

function getNextPerson() {
    if (gLoadingPersonNode.length == 0)
        return null
    return gLoadingPersonNode.shift()
}

function getNextConnet() {
    if (gLoadingConnectQueue.length == 0)
        return null
    return gLoadingConnectQueue.shift()
}
