import CleanReversi
import CleanReversiAsync
import Dispatch

public func move(for board: Board, of side: Disk, handler: @escaping (Int, Int) -> Void) -> Canceller {
    let canceller = Canceller {}
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        if canceller.isCancelled { return }
        let (x, y) = board.validMoves(for: side).randomElement()!
        handler(x, y)
    }
    return canceller
}
