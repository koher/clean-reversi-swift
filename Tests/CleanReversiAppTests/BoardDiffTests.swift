import XCTest
import CleanReversi
@testable import CleanReversiApp

class BoardDiffTests: XCTestCase {
    func testBoardDiff() {
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
            
            let diff = boardDiff(from: before, to: after)
            XCTAssertEqual(diff, [
                (.dark, 4, 5),
                (.dark, 3, 4),
                (.dark, 2, 3),
                (.dark, 1, 2),
                (.dark, 5, 5),
                (.dark, 6, 5),
                (.dark, 4, 6),
            ])
        }
        
        do {
            let before: Board = .init("""
            o-o-o---
            -xxx----
            ox-xxxo-
            -xxx----
            o-x-x---
            --x--x--
            --x---x-
            --o----o
            """)
            let after: Board = .init("""
            o-o-o---
            -ooo----
            ooooooo-
            -ooo----
            o-o-o---
            --o--o--
            --o---o-
            --o----o
            """)
            
            let diff = boardDiff(from: before, to: after)
            XCTAssertEqual(diff, [
                (.light, 2, 2),
                (.light, 1, 1),
                (.light, 2, 1),
                (.light, 3, 1),
                (.light, 3, 2),
                (.light, 4, 2),
                (.light, 5, 2),
                (.light, 3, 3),
                (.light, 4, 4),
                (.light, 5, 5),
                (.light, 6, 6),
                (.light, 2, 3),
                (.light, 2, 4),
                (.light, 2, 5),
                (.light, 2, 6),
                (.light, 1, 3),
                (.light, 1, 2),
            ])
        }
        
        do { // disks of mixed sides
            let before: Board = .init("""
            ----
            xx--
            ----
            ----
            """)
            let after: Board = .init("""
            ----
            xox-
            ----
            ----
            """)
            
            let diff = boardDiff(from: before, to: after)
            XCTAssertEqual(diff, [
                (.light, 1, 1),
                (.dark, 2, 1),
            ])
        }
        
        do { // no new disks
            let before: Board = .init("""
            ----
            xoo-
            ----
            ----
            """)
            let after: Board = .init("""
            ----
            xxx-
            ----
            ----
            """)
            
            let diff = boardDiff(from: before, to: after)
            XCTAssertEqual(diff, [
                (.dark, 1, 1),
                (.dark, 2, 1),
            ])
        }
        
        do { // multiple new disks
            let before: Board = .init("""
            ----
            xo--
            ----
            ----
            """)
            let after: Board = .init("""
            ----
            xxxx
            ----
            ----
            """)
            
            let diff = boardDiff(from: before, to: after)
            XCTAssertEqual(diff, [
                (.dark, 1, 1),
                (.dark, 2, 1),
                (.dark, 3, 1),
            ])
        }
        
        do { // disappearing of disks
            let before: Board = .init("""
            ----
            xxx-
            ----
            ----
            """)
            let after: Board = .init("""
            ----
            xo--
            ----
            ----
            """)
            
            let diff = boardDiff(from: before, to: after)
            XCTAssertEqual(diff, [
                (.light, 1, 1),
                (nil, 2, 1),
            ])
        }
    }
}

private func XCTAssertEqual(_ expression1: [(Disk?, Int, Int)], _ expression2: [(Disk?, Int, Int)]) {
    guard expression1.count == expression2.count else {
        XCTFail("\(expression1) != \(expression2)")
        return
    }
    
    for ((disk1, x1, y1), (disk2, x2, y2)) in zip(expression1, expression2) {
        guard disk1 == disk2, x1 == x2, y1 == y2 else {
            XCTFail("\(expression1) != \(expression2)")
            return
        }
    }
}
