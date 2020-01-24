import XCTest
import CleanReversi

private let l: Disk? = nil
private let X: Disk = .dark
private let O: Disk = .light

final class BoardTests: XCTestCase {
    func testInit() {
        do {
            let board: Board = Board(width: 2, height: 2)
            
            XCTAssertEqual(board, Board("""
            ox
            xo
            """))
        }
        
        do {
            let board: Board = Board(width: 6, height: 4)
            
            XCTAssertEqual(board, Board("""
            ------
            --ox--
            --xo--
            ------
            """))
        }
        
        do {
            let board: Board = Board(width: 8, height: 8)
            
            XCTAssertEqual(board, Board("""
            --------
            --------
            --------
            ---ox---
            ---xo---
            --------
            --------
            --------
            """))
        }
    }
    
    
    // MARK: Ranges
    func testXRange() {
        do {
            let board: Board = Board(width: 8, height: 4)
            XCTAssertEqual(board.xRange, 0 ..< 8)
        }
        
        do {
            let board: Board = Board(width: 42, height: 100)
            XCTAssertEqual(board.xRange, 0 ..< 42)
        }
    }
    
    func testYRange() {
        do {
            let board: Board = Board(width: 4, height: 8)
            XCTAssertEqual(board.yRange, 0 ..< 8)
        }
        
        do {
            let board: Board = Board(width: 100, height: 42)
            XCTAssertEqual(board.yRange, 0 ..< 42)
        }
    }
    
    // MARK: Reset
    
    func testReset() {
        do {
            var board: Board = Board(width: 6, height: 4)
            for y in board.yRange {
                for x in board.xRange {
                    board[x, y] = Disk.random()
                }
            }
            board.reset()
            
            XCTAssertEqual(board, Board("""
            ------
            --ox--
            --xo--
            ------
            """))
        }
        
        do {
            var board: Board = Board(width: 4, height: 6)
            for y in board.yRange {
                for x in board.xRange {
                    board[x, y] = Disk.random()
                }
            }
            board.reset()
            
            XCTAssertEqual(board, Board("""
            ----
            ----
            -ox-
            -xo-
            ----
            ----
            """))
        }
        
        do {
            var board: Board = Board(width: 8, height: 8)
            for y in board.yRange {
                for x in board.xRange {
                    board[x, y] = Disk.random()
                }
            }
            board.reset()
            
            XCTAssertEqual(board, Board("""
            --------
            --------
            --------
            ---ox---
            ---xo---
            --------
            --------
            --------
            """))
        }
    }
    
    // MARK: Counting
    
    func testCountOf() {
        do {
            let board: Board = Board(width: 8, height: 8)
            
            XCTAssertEqual(board.count(of: .dark), 2)
            XCTAssertEqual(board.count(of: .light), 2)
        }
        
        do {
            let board: Board = Board("""
            xxox
            ooo-
            -xx-
            --ox
            """)
            
            XCTAssertEqual(board.count(of: .dark), 6)
            XCTAssertEqual(board.count(of: .light), 5)
        }

        do {
            let board: Board = Board("""
            --------
            --------
            --------
            --------
            --------
            --------
            --------
            --------
            """)
            
            XCTAssertEqual(board.count(of: .dark), 0)
            XCTAssertEqual(board.count(of: .light), 0)
        }

        do {
            let board: Board = Board("""
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            """)
            
            XCTAssertEqual(board.count(of: .dark), 64)
            XCTAssertEqual(board.count(of: .light), 0)
        }
        
        do {
            let board: Board = Board("""
            oooooooo
            oooooooo
            oooooooo
            oooooooo
            oooooooo
            oooooooo
            oooooooo
            oooooooo
            """)
            
            XCTAssertEqual(board.count(of: .dark), 0)
            XCTAssertEqual(board.count(of: .light), 64)
        }
    }
    
    func testSideWithMoreDisks() {
        do {
            let board: Board = Board("""
            xxxo
            oo-x
            xxox
            xxxx
            """)
            
            XCTAssertEqual(board.sideWithMoreDisks(), .dark)
        }
        
        do {
            let board: Board = Board("""
            ooooxo
            o-ooox
            ooooxx
            --xxoo
            """)
            
            XCTAssertEqual(board.sideWithMoreDisks(), .light)
        }
        
        do {
            let board: Board = Board("""
            ooooxxxx
            ooooxxxx
            ooooxxxx
            ooooxxxx
            ooooxxxx
            ooooxxxx
            ooooxxxx
            ooooxxxx
            """)
            
            XCTAssertEqual(board.sideWithMoreDisks(), nil)
        }
    }
    
    // MARK: Flipped boards
    
    func testFlipped() {
        do {
            let board: Board = Board("""
            --xoxo
            xxxoox
            -xooxx
            oxxxo-
            """)
            
            XCTAssertEqual(board.flipped(), Board("""
            --oxox
            oooxxo
            -oxxoo
            xooox-
            """))
        }
    }
    
    func testFlip() {
        do {
            var board: Board = Board("""
            --xoxo
            xxxoox
            -xooxx
            oxxxo-
            """)
            board.flip()
            
            XCTAssertEqual(board, Board("""
            --oxox
            oooxxo
            -oxxoo
            xooox-
            """))
        }
    }
    
    // MARK: Placing disks
    
    func testCanPlaceDiskAt() {
        do {
            let board: Board = Board("""
            --xxxo
            -xoo-o
            --xoo-
            ooo---
            """)
            
            XCTAssertFalse(board.canPlaceDisk(.dark, atX: 0, y: 0))
            XCTAssertFalse(board.canPlaceDisk(.dark, atX: 1, y: 0))
            XCTAssertFalse(board.canPlaceDisk(.dark, atX: 2, y: 0))
            XCTAssertFalse(board.canPlaceDisk(.dark, atX: 3, y: 0))
            XCTAssertFalse(board.canPlaceDisk(.dark, atX: 4, y: 0))
            XCTAssertFalse(board.canPlaceDisk(.dark, atX: 5, y: 0))
            
            XCTAssertFalse(board.canPlaceDisk(.dark, atX: 0, y: 1))
            XCTAssertFalse(board.canPlaceDisk(.dark, atX: 1, y: 1))
            XCTAssertFalse(board.canPlaceDisk(.dark, atX: 2, y: 1))
            XCTAssertFalse(board.canPlaceDisk(.dark, atX: 3, y: 1))
            XCTAssertTrue(board.canPlaceDisk(.dark, atX: 4, y: 1))
            XCTAssertFalse(board.canPlaceDisk(.dark, atX: 5, y: 1))
            
            XCTAssertFalse(board.canPlaceDisk(.dark, atX: 0, y: 2))
            XCTAssertTrue(board.canPlaceDisk(.dark, atX: 1, y: 2))
            XCTAssertFalse(board.canPlaceDisk(.dark, atX: 2, y: 2))
            XCTAssertFalse(board.canPlaceDisk(.dark, atX: 3, y: 2))
            XCTAssertFalse(board.canPlaceDisk(.dark, atX: 4, y: 2))
            XCTAssertTrue(board.canPlaceDisk(.dark, atX: 5, y: 2))
            
            XCTAssertFalse(board.canPlaceDisk(.dark, atX: 0, y: 3))
            XCTAssertFalse(board.canPlaceDisk(.dark, atX: 1, y: 3))
            XCTAssertFalse(board.canPlaceDisk(.dark, atX: 2, y: 3))
            XCTAssertTrue(board.canPlaceDisk(.dark, atX: 3, y: 3))
            XCTAssertFalse(board.canPlaceDisk(.dark, atX: 4, y: 3))
            XCTAssertTrue(board.canPlaceDisk(.dark, atX: 5, y: 3))
            
            XCTAssertFalse(board.canPlaceDisk(.light, atX: 0, y: 0))
            XCTAssertTrue(board.canPlaceDisk(.light, atX: 1, y: 0))
            XCTAssertFalse(board.canPlaceDisk(.light, atX: 2, y: 0))
            XCTAssertFalse(board.canPlaceDisk(.light, atX: 3, y: 0))
            XCTAssertFalse(board.canPlaceDisk(.light, atX: 4, y: 0))
            XCTAssertFalse(board.canPlaceDisk(.light, atX: 5, y: 0))

            XCTAssertTrue(board.canPlaceDisk(.light, atX: 0, y: 1))
            XCTAssertFalse(board.canPlaceDisk(.light, atX: 1, y: 1))
            XCTAssertFalse(board.canPlaceDisk(.light, atX: 2, y: 1))
            XCTAssertFalse(board.canPlaceDisk(.light, atX: 3, y: 1))
            XCTAssertFalse(board.canPlaceDisk(.light, atX: 4, y: 1))
            XCTAssertFalse(board.canPlaceDisk(.light, atX: 5, y: 1))

            XCTAssertFalse(board.canPlaceDisk(.light, atX: 0, y: 2))
            XCTAssertTrue(board.canPlaceDisk(.light, atX: 1, y: 2))
            XCTAssertFalse(board.canPlaceDisk(.light, atX: 2, y: 2))
            XCTAssertFalse(board.canPlaceDisk(.light, atX: 3, y: 2))
            XCTAssertFalse(board.canPlaceDisk(.light, atX: 4, y: 2))
            XCTAssertFalse(board.canPlaceDisk(.light, atX: 5, y: 2))

            XCTAssertFalse(board.canPlaceDisk(.light, atX: 0, y: 3))
            XCTAssertFalse(board.canPlaceDisk(.light, atX: 1, y: 3))
            XCTAssertFalse(board.canPlaceDisk(.light, atX: 2, y: 3))
            XCTAssertFalse(board.canPlaceDisk(.light, atX: 3, y: 3))
            XCTAssertFalse(board.canPlaceDisk(.light, atX: 4, y: 3))
            XCTAssertFalse(board.canPlaceDisk(.light, atX: 5, y: 3))
        }
    }
    
    func testValidMoves() {
        do {
            let board: Board = Board("""
            --xxxo
            -xoo-o
            --xoo-
            ooo---
            """)

            XCTAssertEqual(board.validMoves(for: .dark), [
                (x: 4, y: 1),
                (x: 1, y: 2),
                (x: 5, y: 2),
                (x: 3, y: 3),
                (x: 5, y: 3),
            ])
            
            XCTAssertEqual(board.validMoves(for: .light), [
                (x: 1, y: 0),
                (x: 0, y: 1),
                (x: 1, y: 2),
            ])
        }
    }
    
    func testPlaceDiskAt() {
        do {
            var board: Board = Board("""
            --------
            x-------
            -o------
            --ooo---
            ---ox---
            -----oox
            ---ooo--
            --o-x---
            """)
            
            do {
                try board.place(.dark, atX: 4, y: 5)
                
                XCTAssertEqual(board, Board("""
                --------
                x-------
                -x------
                --xoo---
                ---xx---
                ----xxxx
                ---oxo--
                --o-x---
                """))
            } catch let error {
                XCTFail("\(error)")
            }
            
            do {
                try board.place(.dark, atX: 0, y: 7)
                XCTFail()
            } catch let error as Board.DiskPlacementError {
                XCTAssertEqual(error.disk, .dark)
                XCTAssertEqual(error.x, 0)
                XCTAssertEqual(error.y, 7)
            } catch _ {
                XCTFail()
            }
            
            do {
                try board.place(.light, atX: -1, y: -1)
                XCTFail()
            } catch let error as Board.DiskPlacementError {
                XCTAssertEqual(error.disk, .light)
                XCTAssertEqual(error.x, -1)
                XCTAssertEqual(error.y, -1)
            } catch _ {
                XCTFail()
            }
        }
        
        do {
            var board: Board = Board("""
            o-o-o---
            -xxx----
            ox-xxxo-
            -xxx----
            o-x-x---
            --x--x--
            --x---x-
            --o----o
            """)
            
            do {
                try board.place(.light, atX: 2, y: 2)
                
                XCTAssertEqual(board, Board("""
                o-o-o---
                -ooo----
                ooooooo-
                -ooo----
                o-o-o---
                --o--o--
                --o---o-
                --o----o
                """))
            } catch let error {
                XCTFail("\(error)")
            }
        }
    }

    // MARK: String representations
    
    func testInitWithSymbolBoard() {
        do {
            let board: Board = Board("""
            xxxox-
            -ooox-
            --xxo-
            -x-oxo
            """)
            
            XCTAssertEqual(board.width, 6)
            XCTAssertEqual(board.height, 4)
            
            XCTAssertEqual(board[0, 0], .dark)
            XCTAssertEqual(board[1, 0], .dark)
            XCTAssertEqual(board[2, 0], .dark)
            XCTAssertEqual(board[3, 0], .light)
            XCTAssertEqual(board[4, 0], .dark)
            XCTAssertEqual(board[5, 0], nil)
            
            XCTAssertEqual(board[0, 1], nil)
            XCTAssertEqual(board[1, 1], .light)
            XCTAssertEqual(board[2, 1], .light)
            XCTAssertEqual(board[3, 1], .light)
            XCTAssertEqual(board[4, 1], .dark)
            XCTAssertEqual(board[5, 1], nil)
            
            XCTAssertEqual(board[0, 2], nil)
            XCTAssertEqual(board[1, 2], nil)
            XCTAssertEqual(board[2, 2], .dark)
            XCTAssertEqual(board[3, 2], .dark)
            XCTAssertEqual(board[4, 2], .light)
            XCTAssertEqual(board[5, 2], nil)
            
            XCTAssertEqual(board[0, 3], nil)
            XCTAssertEqual(board[1, 3], .dark)
            XCTAssertEqual(board[2, 3], nil)
            XCTAssertEqual(board[3, 3], .light)
            XCTAssertEqual(board[4, 3], .dark)
            XCTAssertEqual(board[5, 3], .light)
        }
    }
    
    func testDescription() {
        do {
            let board = Board("""
            --------
            --------
            --------
            ---ox---
            ---xo---
            --------
            --------
            --------
            """)
            
            XCTAssertEqual(board.description, """
            --------
            --------
            --------
            ---ox---
            ---xo---
            --------
            --------
            --------
            """)
        }
        
        do {
            let board: Board = Board("""
            xxox
            ooo-
            -xx-
            --ox
            """)
            
            XCTAssertEqual(board.description, """
            xxox
            ooo-
            -xx-
            --ox
            """)
        }
    }
}
