import XCTest
import CleanReversi
import CleanReversiAsync
import CleanReversiApp

class BoardAnimationTests: XCTestCase {
    func testUpdateDisk() {
        do {
            let before: Board = .init("""
            --------
            x-------
            -o------
            --ooo---
            ---ox---
            -----oox
            ---ooo--
            --o-x---
            """)
            let after: Board = .init("""
            --------
            x-------
            -x------
            --xoo---
            ---xx---
            ----xxxx
            ---oxo--
            --o-x---
            """)
            let delegate: Delegate = .init(board: before)
            
            var isCompleted = false
            _ = delegate.updateBoard(after, animated: true) {
                isCompleted = true
            }
            
            XCTAssertFalse(isCompleted)
            XCTAssertEqual(delegate.diskAnimationX, 4)
            XCTAssertEqual(delegate.diskAnimationY, 5)
            XCTAssertTrue(delegate.isDuringDiskAnimation)
            
            do {
                try delegate.completeDiskAnimation()
            } catch _ {
                XCTFail()
                return
            }
            
            XCTAssertFalse(isCompleted)
            XCTAssertEqual(delegate.diskAnimationX, 3)
            XCTAssertEqual(delegate.diskAnimationY, 4)
            XCTAssertTrue(delegate.isDuringDiskAnimation)
            
            do {
                try delegate.completeDiskAnimation()
            } catch _ {
                XCTFail()
                return
            }
            
            XCTAssertFalse(isCompleted)
            XCTAssertEqual(delegate.diskAnimationX, 2)
            XCTAssertEqual(delegate.diskAnimationY, 3)
            XCTAssertTrue(delegate.isDuringDiskAnimation)
            
            do {
                try delegate.completeDiskAnimation()
            } catch _ {
                XCTFail()
                return
            }
            
            XCTAssertFalse(isCompleted)
            XCTAssertEqual(delegate.diskAnimationX, 1)
            XCTAssertEqual(delegate.diskAnimationY, 2)
            XCTAssertTrue(delegate.isDuringDiskAnimation)
            
            do {
                try delegate.completeDiskAnimation()
            } catch _ {
                XCTFail()
                return
            }
            
            XCTAssertFalse(isCompleted)
            XCTAssertEqual(delegate.diskAnimationX, 5)
            XCTAssertEqual(delegate.diskAnimationY, 5)
            XCTAssertTrue(delegate.isDuringDiskAnimation)
            
            do {
                try delegate.completeDiskAnimation()
            } catch _ {
                XCTFail()
                return
            }
            
            XCTAssertFalse(isCompleted)
            XCTAssertEqual(delegate.diskAnimationX, 6)
            XCTAssertEqual(delegate.diskAnimationY, 5)
            XCTAssertTrue(delegate.isDuringDiskAnimation)
            
            do {
                try delegate.completeDiskAnimation()
            } catch _ {
                XCTFail()
                return
            }
            
            XCTAssertFalse(isCompleted)
            XCTAssertEqual(delegate.diskAnimationX, 4)
            XCTAssertEqual(delegate.diskAnimationY, 6)
            XCTAssertTrue(delegate.isDuringDiskAnimation)
            
            do {
                try delegate.completeDiskAnimation()
            } catch _ {
                XCTFail()
                return
            }
            
            XCTAssertTrue(isCompleted)
            XCTAssertNil(delegate.diskAnimationX)
            XCTAssertNil(delegate.diskAnimationY)
            XCTAssertFalse(delegate.isDuringDiskAnimation)
        }
        
        do { // cancel
            let before: Board = .init("""
            --------
            x-------
            -o------
            --ooo---
            ---ox---
            -----oox
            ---ooo--
            --o-x---
            """)
            let after: Board = .init("""
            --------
            x-------
            -x------
            --xoo---
            ---xx---
            ----xxxx
            ---oxo--
            --o-x---
            """)
            let delegate: Delegate = .init(board: before)
            
            var isCompleted = false
            let canceller = delegate.updateBoard(after, animated: true) {
                isCompleted = true
            }
            
            XCTAssertFalse(isCompleted)
            XCTAssertEqual(delegate.diskAnimationX, 4)
            XCTAssertEqual(delegate.diskAnimationY, 5)
            XCTAssertTrue(delegate.isDuringDiskAnimation)
            
            do {
                try delegate.completeDiskAnimation()
            } catch _ {
                XCTFail()
                return
            }

            XCTAssertFalse(isCompleted)
            XCTAssertEqual(delegate.diskAnimationX, 3)
            XCTAssertEqual(delegate.diskAnimationY, 4)
            XCTAssertTrue(delegate.isDuringDiskAnimation)
            
            canceller.cancel()
            
            XCTAssertFalse(isCompleted)
            XCTAssertNil(delegate.diskAnimationX)
            XCTAssertNil(delegate.diskAnimationY)
            XCTAssertFalse(delegate.isDuringDiskAnimation)
        }
    }
}

private class Delegate: GameControllerBoardAnimationDelegate {
    var board: Board
    
    private(set) var diskAnimationX: Int?
    private(set) var diskAnimationY: Int?
    private var diskAnimationCompletion: (() -> Void)?
    var isDuringDiskAnimation: Bool { diskAnimationCompletion != nil }
    
    init(board: Board) {
        self.board = board
    }
    
    func updateDisk(_ disk: Disk?, atX x: Int, y: Int, animated: Bool, completion: @escaping () -> Void) -> Canceller {
        diskAnimationX = x
        diskAnimationY = y
        diskAnimationCompletion = completion
        return Canceller { [weak self] in
            guard let self = self else { return }
            self.diskAnimationX = nil
            self.diskAnimationY = nil
            self.diskAnimationCompletion = nil
        }
    }
    
    func completeDiskAnimation() throws {
        guard let completion = diskAnimationCompletion else { throw GeneralError() }
        diskAnimationX = nil
        diskAnimationY = nil
        diskAnimationCompletion = nil
        completion()
    }
}
