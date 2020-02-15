import CleanReversi

public protocol GameControllerBoardAnimationDelegate: AnyObject {
    var board: Board { get }
    func updateBoard(_ board: Board, animated: Bool, completion: @escaping () -> Void) -> Canceller
    func updateDisk(_ disk: Disk?, atX x: Int, y: Int, animated: Bool, completion: @escaping () -> Void) -> Canceller
}

extension GameControllerBoardAnimationDelegate {
    public func updateBoard(_ board: Board, animated isAnimated: Bool, completion: @escaping () -> Void) -> Canceller {
        let diff: [(Disk?, Int, Int)] = boardDiff(from: self.board, to: board)
        let canceller = Canceller {}
        applyBoardDiff(diff[...], animated: isAnimated, canceller: canceller, completion: completion)
        return canceller
    }
    
    private func applyBoardDiff(_ diff: ArraySlice<(Disk?, Int, Int)>, animated isAnimated: Bool, canceller: Canceller?, completion: @escaping () -> Void) {
        guard let (disk, x, y) = diff.first else {
            completion()
            return
        }
        
        let subcanceller = updateDisk(disk, atX: x, y: y, animated: isAnimated) { [weak self, weak canceller] in
            self?.applyBoardDiff(diff[(diff.startIndex + 1)...], animated: isAnimated, canceller: canceller, completion: completion)
        }
        canceller?.addSubcanceller(subcanceller)
    }
}
