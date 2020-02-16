import CleanReversi
import CleanReversiAsync
import Dispatch

public func coordinateToPlaceDisk(onto board: Board, handler: @escaping (Int, Int) -> Void) -> Canceller {
    let canceller = Canceller {}
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        if canceller.isCancelled { return }
        let (x, y) = board.validMoves(for: .dark).randomElement()!
        handler(x, y)
    }
    return canceller
}
