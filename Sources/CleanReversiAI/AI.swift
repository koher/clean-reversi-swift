import CleanReversi
import Dispatch

public func coordinateToPlaceDisk(onto board: Board, handler: @escaping (Int, Int) -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        let (x, y) = board.validMoves(for: .dark).randomElement()!
        handler(x, y)
    }
}
