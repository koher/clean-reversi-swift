import XCTest
import CleanReversi
import CleanReversiApp
@testable import CleanReversiGateway

class SavedDataTests: XCTestCase {
    func testInitWithData() {
        do {
            let data: Data = """
            x10
            oxx--x-x
            oooxoxxx
            ---xxxox
            o-xoxoxx
            xxooooxo
            o-xxxoxx
            ----xxx-
            ---oxxox
            """.data(using: .utf8)!
            let state = try GameController.SavedState(data: data)
            
            XCTAssertEqual(state, GameController.SavedState(
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
            ))
        } catch _ {
            XCTFail()
            return
        }
        
        do {
            let data: Data = """
            o01
            --------
            --------
            --------
            --xxx---
            ---xo---
            --------
            --------
            --------
            """.data(using: .utf8)!
            let state = try GameController.SavedState(data: data)
            
            XCTAssertEqual(state, GameController.SavedState(
                turn: .light,
                darkPlayer: .manual,
                lightPlayer: .computer,
                board: Board("""
                --------
                --------
                --------
                --xxx---
                ---xo---
                --------
                --------
                --------
                """)
            ))
        } catch _ {
            XCTFail()
            return
        }

        do {
            let data: Data = """
            -11
            --------
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            """.data(using: .utf8)!
            let state = try GameController.SavedState(data: data)
            
            XCTAssertEqual(state, GameController.SavedState(
                turn: nil,
                darkPlayer: .computer,
                lightPlayer: .computer,
                board: Board("""
                --------
                xxxxxxxx
                xxxxxxxx
                xxxxxxxx
                xxxxxxxx
                xxxxxxxx
                xxxxxxxx
                xxxxxxxx
                """)
            ))
        } catch _ {
            XCTFail()
            return
        }
    }
    
    func testData() {
        do {
            let state = GameController.SavedState(
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
            let data = state.data()
            
            XCTAssertEqual(data, """
            x10
            oxx--x-x
            oooxoxxx
            ---xxxox
            o-xoxoxx
            xxooooxo
            o-xxxoxx
            ----xxx-
            ---oxxox
            """.data(using: .utf8))
        }
        
        do {
            let state = GameController.SavedState(
                turn: .light,
                darkPlayer: .manual,
                lightPlayer: .computer,
                board: Board("""
                --------
                --------
                --------
                --xxx---
                ---xo---
                --------
                --------
                --------
                """)
            )
            let data = state.data()
            
            XCTAssertEqual(data, """
            o01
            --------
            --------
            --------
            --xxx---
            ---xo---
            --------
            --------
            --------
            """.data(using: .utf8))
        }
        
        do {
            let state = GameController.SavedState(
                turn: nil,
                darkPlayer: .computer,
                lightPlayer: .computer,
                board: Board("""
                --------
                xxxxxxxx
                xxxxxxxx
                xxxxxxxx
                xxxxxxxx
                xxxxxxxx
                xxxxxxxx
                xxxxxxxx
                """)
            )
            let data = state.data()
            
            XCTAssertEqual(data, """
            -11
            --------
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            """.data(using: .utf8))
        }
    }
}
