import CleanReversi

public func coodinateToPlaceDisk(onto board: Board) -> (x: Int, y: Int) {
    board.coordinatesToPlaceDisk(.dark).randomElement()!
}
