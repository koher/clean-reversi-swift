import XCTest
import CleanReversi

final class GameTests: XCTestCase {
    func testInit() {
        do {
            let game: Game = Game()
            
            XCTAssertEqual(game.board, Board(width: 8, height: 8))
            XCTAssertEqual(game.state, .beingPlayed(turn: .dark))
        }
        
        do {
            let game: Game = Game(board: Board(width: 2, height: 2))
            
            XCTAssertEqual(game.board, Board(width: 2, height: 2))
            XCTAssertEqual(game.state, .over(winner: nil))
        }
        
        do {
            let game: Game = Game(board: Board("""
            xxxo
            x--x
            xooo
            xxxo
            """), turn: .light)
            
            XCTAssertEqual(game.state, .beingPlayed(turn: .dark))
        }
    }
    
    func testPlaceDiskAt() {
        do {
            var game: Game = Game(board: Board("""
            -oox
            ooox
            xxox
            xo-x
            """))
            
            do {
                try game.placeDiskAt(x: 0, y: 0)
                
                XCTAssertEqual(game.board, Board("""
                xxxx
                xxox
                xxxx
                xo-x
                """))
                XCTAssertEqual(game.state, .beingPlayed(turn: .light))
                
                try game.placeDiskAt(x: 2, y: 3)
                
                XCTAssertEqual(game.board, Board("""
                xxxx
                xxox
                xxox
                xoox
                """))
                XCTAssertEqual(game.state, .over(winner: .dark))
            } catch _ {
                XCTFail()
            }
        }
        
        do { // pass
            var game: Game = Game(board: Board("""
            xxxx
            -xo-
            -xo-
            x---
            """), turn: .light)
            
            do {
                try game.placeDiskAt(x: 0, y: 1)
                
                XCTAssertEqual(game.board, Board("""
                xxxx
                ooo-
                -xo-
                x---
                """))
                XCTAssertEqual(game.state, .beingPlayed(turn: .dark))
                
                try game.placeDiskAt(x: 0, y: 2)
                
                XCTAssertEqual(game.board, Board("""
                xxxx
                xxo-
                xxo-
                x---
                """))
                XCTAssertEqual(game.state, .beingPlayed(turn: .dark))
            } catch _ {
                XCTFail()
            }
        }
        
        do { // pass, pass -> over
            var game: Game = Game(board: Board("""
            -xxx
            -xxo
            oooo
            oooo
            """), turn: .light)
            
            do {
                try game.placeDiskAt(x: 0, y: 1)
                
                XCTAssertEqual(game.board, Board("""
                -xxx
                oooo
                oooo
                oooo
                """))
                XCTAssertEqual(game.state, .over(winner: .light))
            } catch _ {
                XCTFail()
            }
        }
        
        do { // Game.DiskPlacementError.illegalPosition
            var game: Game = Game(board: Board("""
            ----
            -ox-
            -xo-
            ----
            """))
            
            do {
                try game.placeDiskAt(x: 0, y: 0)
                XCTFail()
            } catch Game.DiskPlacementError.illegalPosition(x: let x, y: let y) {
                XCTAssertEqual(x, 0)
                XCTAssertEqual(y, 0)
            } catch _ {
                XCTFail()
            }

            do {
                try game.placeDiskAt(x: -1, y: 42)
                XCTFail()
            } catch Game.DiskPlacementError.illegalPosition(x: let x, y: let y) {
                XCTAssertEqual(x, -1)
                XCTAssertEqual(y, 42)
            } catch _ {
                XCTFail()
            }
        }
        
        do {
            var game: Game = Game(board: Board("""
            -ooo
            -xxx
            xxxx
            xxxx
            """))
            
            do { // Game.DiskPlacementError.illegalState
                try game.placeDiskAt(x: 0, y: 0)
                XCTFail()
            } catch Game.DiskPlacementError.illegalState {
                XCTAssertEqual(game.state, .over(winner: .dark))
            } catch _ {
                XCTFail()
            }
        }
    }
}
