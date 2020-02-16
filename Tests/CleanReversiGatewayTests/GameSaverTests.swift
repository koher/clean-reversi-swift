import XCTest
import CleanReversi
import CleanReversiApp
@testable import CleanReversiGateway

class GameSaverTests: XCTestCase {
    func testSaveGame() {
        let delegate: Delegate = .init()
        let saver: GameSaver = .init(delegate: delegate)
        let state: GameController.SavedState = .init(
            turn: .dark,
            darkPlayer: .computer,
            lightPlayer: .manual,
            board: Board("""
            oxx--x-x
            oooxoxxx
            ---xxxox
            o-xoxoxx
            xxooooxo
            o-xxxoxx
            ----xxx-
            ---oxxox
            """)
        )
        
        do {
            try saver.saveGame(state)
        } catch _ {
            XCTFail()
            return
        }
        
        XCTAssertEqual(delegate.data, state.data())
    }
    
    func testLoadGame() {
        let delegate: Delegate = .init()
        let saver: GameSaver = .init(delegate: delegate)

        do {
            _ = try saver.loadGame()
            XCTFail()
            return
        } catch _ {
            // Do nothing
        }

        let state: GameController.SavedState = .init(
            turn: .dark,
            darkPlayer: .computer,
            lightPlayer: .manual,
            board: Board("""
            oxx--x-x
            oooxoxxx
            ---xxxox
            o-xoxoxx
            xxooooxo
            o-xxxoxx
            ----xxx-
            ---oxxox
            """)
        )
        delegate.data = state.data()
        
        let loaded: GameController.SavedState
        do {
            loaded = try saver.loadGame()
        } catch _ {
            XCTFail()
            return
        }
        
        XCTAssertEqual(loaded, state)
    }
}

private class Delegate: GameSaverDelegate {
    var data: Data?
    
    func writeData(_ data: Data) throws {
        self.data = data
    }
    
    func readData() throws -> Data {
        guard let data = self.data else { throw GeneralError() }
        return data
    }
}
