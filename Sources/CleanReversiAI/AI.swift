import CleanReversi
import Dispatch

public func coodinateToPlaceDisk(onto board: Board, handler: @escaping (Int, Int) -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        let (x, y) = board.coordinatesToPlaceDisk(.dark).randomElement()!
        handler(x, y)
    }
}
