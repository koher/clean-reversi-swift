import CleanReversi

internal func boardDiff(from before: Board, to after: Board) -> [(Disk?, Int, Int)] {
    precondition(before.width == after.width)
    precondition(before.height == after.height)
    
    var newDiskCoordinates: [(Int, Int)] = []
    var diff: [(Disk?, Int, Int)] = []
    
    for y in after.yRange {
        for x in after.xRange {
            let beforeDisk: Disk? = before[x, y]
            let afterDisk: Disk? = after[x, y]
            if afterDisk != beforeDisk {
                if beforeDisk == nil, afterDisk != nil {
                    newDiskCoordinates.append((x, y))
                }
                diff.append((afterDisk, x, y))
            }
        }
    }
    
    if
        newDiskCoordinates.count == 1,
        diff.count > 1,
        diff.allSatisfy({ $0.0 != nil }),
        diff.allSatisfy({ $0.0 == diff[0].0 })
    {
        let (newDiskX, newDiskY) = newDiskCoordinates[0]
        
        func directionScore(x: Int, y: Int) -> Int {
            switch (x - newDiskX, y - newDiskY) {
            case (0,    0):    return 0
            case (..<0, ..<0): return 1
            case (0,    ..<0): return 2
            case (1..., ..<0): return 3
            case (1..., 0):    return 4
            case (1..., 1...): return 5
            case (0,    1...): return 6
            case (..<0, 1...): return 7
            case (..<0, 0):    return 8
            default: preconditionFailure()
            }
        }
        func distanceScore(x: Int, y: Int) -> Int {
            abs(x - newDiskX) + abs(y - newDiskY)
        }
        
        diff.sort(by: {
            let (_, x1, y1) = $0
            let (_, x2, y2) = $1
            let ds1 = directionScore(x: x1, y: y1)
            let ds2 = directionScore(x: x2, y: y2)
            if ds1 < ds2 { return true }
            if ds1 > ds2 { return false }
            return distanceScore(x: x1, y: y1) < distanceScore(x: x2, y: y2)
        })
    }
    
    return diff
}

