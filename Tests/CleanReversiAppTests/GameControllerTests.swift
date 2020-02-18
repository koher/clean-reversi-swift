import XCTest
import CleanReversi
import CleanReversiAsync
import CleanReversiApp

class GameControllerTests: XCTestCase {
    func testInit() {
        do { // Without a saved game
            let delegate = TestDelegate()
            _ = GameController(delegate: delegate)
            
            XCTAssertEqual(delegate.message, .turn(.dark))
            XCTAssertEqual(delegate.diskCounts, [.dark: 2, .light: 2])
            XCTAssertEqual(delegate.players, [.dark: .manual, .light: .manual])
            XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
            XCTAssertEqual(delegate.board, Board(width: 8, height: 8))
            XCTAssertNil(delegate.passAlertSide)
            
            XCTAssertFalse(delegate.isWatingForBoardAnimation())
            XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
            XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

            XCTAssertEqual(delegate.savedState, GameController.SavedState(
                turn: .dark,
                darkPlayer: .manual,
                lightPlayer: .manual,
                board: Board(width: 8, height: 8)
            ))
            
            XCTAssertNil(delegate.boardForMove)
            XCTAssertNil(delegate.sideForMove)
            
            XCTAssertFalse(delegate.isWaitingForMoveOfAI())
        }
        
        do { // With a saved game
            let delegate = TestDelegate()
            let board = Board("""
            ---xxoo-
            x-xx-oxx
            xxx-xxox
            ooooxxo-
            --xoxxx-
            ----x--o
            --------
            --------
            """)
            let savedState: GameController.SavedState = .init(
                turn: .light,
                darkPlayer: .computer,
                lightPlayer: .computer,
                board: board
            )
            delegate.savedState = savedState
            _ = GameController(delegate: delegate)
            
            XCTAssertEqual(delegate.message, .turn(.light))
            XCTAssertEqual(delegate.diskCounts, [.dark: 20, .light: 11])
            XCTAssertEqual(delegate.players, [.dark: .computer, .light: .computer])
            XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
            XCTAssertEqual(delegate.board, board)
            XCTAssertNil(delegate.passAlertSide)

            XCTAssertFalse(delegate.isWatingForBoardAnimation())
            XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
            XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

            XCTAssertEqual(delegate.savedState, savedState)
            
            XCTAssertNil(delegate.boardForMove)
            XCTAssertNil(delegate.sideForMove)
            
            XCTAssertFalse(delegate.isWaitingForMoveOfAI())
        }
        
        do { // With a saved game finished
            let delegate = TestDelegate()
            let board = Board("""
            oxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            """)
            let savedState: GameController.SavedState = .init(
                turn: nil,
                darkPlayer: .manual,
                lightPlayer: .computer,
                board: board
            )
            delegate.savedState = savedState
            _ = GameController(delegate: delegate)
            
            XCTAssertEqual(delegate.message, .result(winner: .dark))
            XCTAssertEqual(delegate.diskCounts, [.dark: 63, .light: 1])
            XCTAssertEqual(delegate.players, [.dark: .manual, .light: .computer])
            XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
            XCTAssertEqual(delegate.board, board)
            XCTAssertNil(delegate.passAlertSide)

            XCTAssertFalse(delegate.isWatingForBoardAnimation())
            XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
            XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

            XCTAssertEqual(delegate.savedState, savedState)
            
            XCTAssertNil(delegate.boardForMove)
            XCTAssertNil(delegate.sideForMove)
            
            XCTAssertFalse(delegate.isWaitingForMoveOfAI())
        }
    }
    
    func testStart() {
        do {
            let delegate = TestDelegate()
            let controller = GameController(delegate: delegate)
            do {
                try controller.start()
            } catch _ {
                XCTFail()
                return
            }
            
            XCTAssertEqual(delegate.message, .turn(.dark))
            XCTAssertEqual(delegate.diskCounts, [.dark: 2, .light: 2])
            XCTAssertEqual(delegate.players, [.dark: .manual, .light: .manual])
            XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
            XCTAssertEqual(delegate.board, Board(width: 8, height: 8))
            XCTAssertNil(delegate.passAlertSide)

            XCTAssertFalse(delegate.isWatingForBoardAnimation())
            XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
            XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

            XCTAssertEqual(delegate.savedState, GameController.SavedState(
                turn: .dark,
                darkPlayer: .manual,
                lightPlayer: .manual,
                board: Board(width: 8, height: 8)
            ))
            
            XCTAssertNil(delegate.boardForMove)
            XCTAssertNil(delegate.sideForMove)
            
            XCTAssertFalse(delegate.isWaitingForMoveOfAI())

            // Duplicate `start` calls cause errors
            do {
                try controller.start()
                XCTFail()
                return
            } catch let error as GameController.StartError {
                switch error {
                case .alreadyStarted:
                    break
                }
            } catch _ {
                XCTFail()
                return
            }
        }
        
        // With a saved game with a turn of a computer player.
        // - The activity indicator of the light player must be visible
        // - Properties related to `moveHandler` must be set
        do {
            let delegate = TestDelegate()
            let board = Board("""
            --------
            --------
            --------
            ---ox---
            ---xxx--
            --------
            --------
            --------
            """)
            let savedState: GameController.SavedState = .init(
                turn: .light,
                darkPlayer: .computer,
                lightPlayer: .computer,
                board: board
            )
            delegate.savedState = savedState
            let controller = GameController(delegate: delegate)
            do {
                try controller.start()
            } catch _ {
                XCTFail()
                return
            }
            
            XCTAssertEqual(delegate.message, .turn(.light))
            XCTAssertEqual(delegate.diskCounts, [.dark: 4, .light: 1])
            XCTAssertEqual(delegate.players, [.dark: .computer, .light: .computer])
            XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: true])
            XCTAssertEqual(delegate.board, board)
            XCTAssertNil(delegate.passAlertSide)

            XCTAssertFalse(delegate.isWatingForBoardAnimation())
            XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
            XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

            XCTAssertEqual(delegate.savedState, savedState)
            
            XCTAssertEqual(delegate.boardForMove, board)
            XCTAssertEqual(delegate.sideForMove, .light)
            
            XCTAssertTrue(delegate.isWaitingForMoveOfAI())
        }
    }
    
    func testSetPlayer() {
        let delegate = TestDelegate()
        let board: Board = .init(width: 8, height: 8)
        let savedState: GameController.SavedState = .init(
            turn: .dark,
            darkPlayer: .manual,
            lightPlayer: .manual,
            board: board
        )
        let controller = GameController(delegate: delegate)
        do {
            try controller.start()
        } catch _ {
            XCTFail()
            return

        }
        
        // Sets a player mode of the turn to `.computer` and the AI starts thinking.
        // - The activity indicator of the dark player must be made visible
        // - Properties related to `moveHandler` must be set
        // - Player modes in the saved state must be updated
        do {
            delegate.setPlayer(.computer, of: .dark)
            controller.setPlayer(.computer, of: .dark)
            
            XCTAssertEqual(delegate.message, .turn(.dark))
            XCTAssertEqual(delegate.diskCounts, [.dark: 2, .light: 2])
            XCTAssertEqual(delegate.players, [.dark: .computer, .light: .manual])
            XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: true, .light: false])
            XCTAssertEqual(delegate.board, board)
            XCTAssertNil(delegate.passAlertSide)

            XCTAssertFalse(delegate.isWatingForBoardAnimation())
            XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
            XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

            XCTAssertEqual(delegate.savedState, GameController.SavedState(
                turn: .dark,
                darkPlayer: .computer,
                lightPlayer: .manual,
                board: board
            ))
            
            XCTAssertEqual(delegate.boardForMove, board)
            XCTAssertEqual(delegate.sideForMove, .dark)

            XCTAssertTrue(delegate.isWaitingForMoveOfAI())
        }

        // Set a player mode of the turn back to `.manual` while the AI is thinking.
        // - The activity indicator of the dark player must be made invisible
        // - Properties related to `moveHandler` must be unset
        // - Player modes in the saved state must be updated
        do {
            let moveHandler = delegate.moveHandler!
            
            delegate.setPlayer(.manual, of: .dark)
            controller.setPlayer(.manual, of: .dark)
            
            XCTAssertEqual(delegate.message, .turn(.dark))
            XCTAssertEqual(delegate.diskCounts, [.dark: 2, .light: 2])
            XCTAssertEqual(delegate.players, [.dark: .manual, .light: .manual])
            XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
            XCTAssertEqual(delegate.board, board)
            XCTAssertNil(delegate.passAlertSide)

            XCTAssertFalse(delegate.isWatingForBoardAnimation())
            XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
            XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

            XCTAssertEqual(delegate.savedState, savedState)
            
            XCTAssertNil(delegate.boardForMove)
            XCTAssertNil(delegate.sideForMove)

            XCTAssertFalse(delegate.isWaitingForMoveOfAI())

            // Calling handlers after cancelled must be ignored.
            moveHandler(5, 3)
            
            XCTAssertEqual(delegate.message, .turn(.dark))
            XCTAssertEqual(delegate.diskCounts, [.dark: 2, .light: 2])
            XCTAssertEqual(delegate.players, [.dark: .manual, .light: .manual])
            XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
            XCTAssertEqual(delegate.board, board)
            XCTAssertNil(delegate.passAlertSide)

            XCTAssertFalse(delegate.isWatingForBoardAnimation())
            XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
            XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

            XCTAssertEqual(delegate.savedState, savedState)
            
            XCTAssertNil(delegate.boardForMove)
            XCTAssertNil(delegate.sideForMove)

            XCTAssertFalse(delegate.isWaitingForMoveOfAI())
        }

        // Set a `.light` player mode to `.computer` while `turn` is `.dark`.
        // - The activity indicator of the light player must keep invisible
        // - Properties related to `moveHandler` must keep unset
        // - Player modes in the saved state must be updated
        do {
            delegate.setPlayer(.computer, of: .light)
            controller.setPlayer(.computer, of: .light)
            
            XCTAssertEqual(delegate.message, .turn(.dark))
            XCTAssertEqual(delegate.diskCounts, [.dark: 2, .light: 2])
            XCTAssertEqual(delegate.players, [.dark: .manual, .light: .computer])
            XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
            XCTAssertEqual(delegate.board, board)
            XCTAssertNil(delegate.passAlertSide)

            XCTAssertFalse(delegate.isWatingForBoardAnimation())
            XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
            XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

            XCTAssertEqual(delegate.savedState, GameController.SavedState(
                turn: .dark,
                darkPlayer: .manual,
                lightPlayer: .computer,
                board: board
            ))

            XCTAssertNil(delegate.boardForMove)
            XCTAssertNil(delegate.sideForMove)

            XCTAssertFalse(delegate.isWaitingForMoveOfAI())
        }
    }
    
    func testReset() {
        do {
            let delegate = TestDelegate()
            let board = Board("""
            ---xxoo-
            x-xx-oxx
            xxx-xxox
            ooooxxo-
            --xoxxx-
            ----x--o
            --------
            --------
            """)
            let savedState: GameController.SavedState = .init(
                turn: .light,
                darkPlayer: .manual,
                lightPlayer: .manual,
                board: board
            )
            delegate.savedState = savedState
            let controller = GameController(delegate: delegate)
            do {
                try controller.start()
            } catch _ {
                XCTFail()
                return
            }
            
            do { // During confirmations
                controller.reset()

                XCTAssertEqual(delegate.message, .turn(.light))
                XCTAssertEqual(delegate.diskCounts, [.dark: 20, .light: 11])
                XCTAssertEqual(delegate.players, [.dark: .manual, .light: .manual])
                XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
                XCTAssertEqual(delegate.board, board)
                XCTAssertNil(delegate.passAlertSide)

                XCTAssertFalse(delegate.isWatingForBoardAnimation())
                XCTAssertTrue(delegate.isWatingForResetGameConfirmation())
                XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                XCTAssertEqual(delegate.savedState, savedState)
                
                XCTAssertNil(delegate.boardForMove)
                XCTAssertNil(delegate.sideForMove)
                
                XCTAssertFalse(delegate.isWaitingForMoveOfAI())
            }
            
            do { // Cancels condirmation
                do {
                    try delegate.completeResetGameConfirmation(isConfirmed: false)
                } catch _ {
                    XCTFail()
                    return
                }
                
                XCTAssertEqual(delegate.message, .turn(.light))
                XCTAssertEqual(delegate.diskCounts, [.dark: 20, .light: 11])
                XCTAssertEqual(delegate.players, [.dark: .manual, .light: .manual])
                XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
                XCTAssertEqual(delegate.board, board)
                XCTAssertNil(delegate.passAlertSide)

                XCTAssertFalse(delegate.isWatingForBoardAnimation())
                XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                XCTAssertEqual(delegate.savedState, savedState)
                
                XCTAssertNil(delegate.boardForMove)
                XCTAssertNil(delegate.sideForMove)
                
                XCTAssertFalse(delegate.isWaitingForMoveOfAI())
            }
            
            do { // Resets games
                controller.reset()
                do {
                    try delegate.completeResetGameConfirmation(isConfirmed: true)
                } catch  _ {
                    XCTFail()
                    return
                }
                
                XCTAssertEqual(delegate.message, .turn(.dark))
                XCTAssertEqual(delegate.diskCounts, [.dark: 2, .light: 2])
                XCTAssertEqual(delegate.players, [.dark: .manual, .light: .manual])
                XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
                XCTAssertEqual(delegate.board, Board(width: 8, height: 8))
                XCTAssertNil(delegate.passAlertSide)
                
                XCTAssertFalse(delegate.isWatingForBoardAnimation())
                XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                XCTAssertEqual(delegate.savedState, GameController.SavedState(
                    turn: .dark,
                    darkPlayer: .manual,
                    lightPlayer: .manual,
                    board: Board(width: 8, height: 8)
                ))
                
                XCTAssertNil(delegate.boardForMove)
                XCTAssertNil(delegate.sideForMove)
                
                XCTAssertFalse(delegate.isWaitingForMoveOfAI())
            }
        }
        
        do { // Resets during waiting for moves of `.computer`
            let delegate = TestDelegate()
            let board = Board("""
            --------
            --------
            --------
            ---ox---
            ---xxx--
            --------
            --------
            --------
            """)
            let savedState: GameController.SavedState = .init(
                turn: .light,
                darkPlayer: .computer,
                lightPlayer: .computer,
                board: board
            )
            delegate.savedState = savedState
            let controller = GameController(delegate: delegate)
            do {
                try controller.start()
            } catch _ {
                XCTFail()
                return
            }
            
            controller.reset()
            
            XCTAssertTrue(delegate.isWatingForResetGameConfirmation())
            
            do {
                try delegate.completeResetGameConfirmation(isConfirmed: true)
            } catch _ {
                XCTFail()
                return
            }
            
            XCTAssertEqual(delegate.message, .turn(.dark))
            XCTAssertEqual(delegate.diskCounts, [.dark: 2, .light: 2])
            XCTAssertEqual(delegate.players, [.dark: .manual, .light: .manual])
            XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
            XCTAssertEqual(delegate.board, Board(width: 8, height: 8))
            XCTAssertNil(delegate.passAlertSide)
            
            XCTAssertFalse(delegate.isWatingForBoardAnimation())
            XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
            XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

            XCTAssertEqual(delegate.savedState, GameController.SavedState(
                turn: .dark,
                darkPlayer: .manual,
                lightPlayer: .manual,
                board: Board(width: 8, height: 8)
            ))
            
            XCTAssertNil(delegate.boardForMove)
            XCTAssertNil(delegate.sideForMove)
            
            XCTAssertFalse(delegate.isWaitingForMoveOfAI())
        }
        
        do { // Resets during waiting for borad animations
            let delegate = TestDelegate()
            let board = Board("""
            --------
            --------
            --------
            ---ox---
            ---xxx--
            --------
            --------
            --------
            """)
            let savedState: GameController.SavedState = .init(
                turn: .light,
                darkPlayer: .manual,
                lightPlayer: .manual,
                board: board
            )
            delegate.savedState = savedState
            let controller = GameController(delegate: delegate)
            do {
                try controller.start()
            } catch _ {
                XCTFail()
                return
            }

            do {
                try controller.placeDiskAt(x: 3, y: 5)
            } catch _ {
                XCTFail()
                return
            }
            
            XCTAssertTrue(delegate.isWatingForBoardAnimation())

            controller.reset()
            
            XCTAssertTrue(delegate.isWatingForResetGameConfirmation())

            do {
                try delegate.completeResetGameConfirmation(isConfirmed: true)
            } catch _ {
                XCTFail()
                return
            }
            
            XCTAssertEqual(delegate.message, .turn(.dark))
            XCTAssertEqual(delegate.diskCounts, [.dark: 2, .light: 2])
            XCTAssertEqual(delegate.players, [.dark: .manual, .light: .manual])
            XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
            XCTAssertEqual(delegate.board, Board(width: 8, height: 8))
            XCTAssertNil(delegate.passAlertSide)
            
            XCTAssertFalse(delegate.isWatingForBoardAnimation())
            XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
            XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

            XCTAssertEqual(delegate.savedState, GameController.SavedState(
                turn: .dark,
                darkPlayer: .manual,
                lightPlayer: .manual,
                board: Board(width: 8, height: 8)
            ))
            
            XCTAssertNil(delegate.boardForMove)
            XCTAssertNil(delegate.sideForMove)
            
            XCTAssertFalse(delegate.isWaitingForMoveOfAI())
        }
    }
    
    func testPlaceDisk() {
        do {
            let delegate = TestDelegate()
            let controller = GameController(delegate: delegate)
            do {
                try controller.start()
            } catch _ {
                XCTFail()
                return
            }
            
            let board0: Board = .init(width: 8, height: 8)
            let board1: Board = .init("""
            --------
            --------
            --------
            ---ox---
            ---xx---
            ----x---
            --------
            --------
            """)
            let board2: Board = .init("""
            --------
            --------
            --------
            ---ox---
            ---xo---
            ----xo--
            --------
            --------
            """)
            
            do { // during wating for a player
                func assertDelegate() {
                    XCTAssertEqual(delegate.message, .turn(.dark))
                    XCTAssertEqual(delegate.diskCounts, [.dark: 2, .light: 2])
                    XCTAssertEqual(delegate.players, [.dark: .manual, .light: .manual])
                    XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
                    XCTAssertEqual(delegate.board, board0)
                    XCTAssertNil(delegate.passAlertSide)

                    XCTAssertFalse(delegate.isWatingForBoardAnimation())
                    XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                    XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                    XCTAssertEqual(delegate.savedState, GameController.SavedState(
                        turn: .dark,
                        darkPlayer: .manual,
                        lightPlayer: .manual,
                        board: board0
                    ))
                    
                    XCTAssertNil(delegate.boardForMove)
                    XCTAssertNil(delegate.sideForMove)
                    
                    XCTAssertFalse(delegate.isWaitingForMoveOfAI())
                }
                
                assertDelegate()
                
                // invalid placing disks during wating for a player
                for y in 0 ..< 8 {
                    for x in 0 ..< 8 {
                        if board0.canPlaceDisk(.dark, atX: x, y: y) { continue }
                        do {
                            try controller.placeDiskAt(x: x, y: y)
                            XCTFail()
                            return
                        } catch GameController.MoveError.invalidMove(
                            .illegalPosition(x: let ex, y: let ey)
                        ) {
                            XCTAssertEqual(ex, x)
                            XCTAssertEqual(ey, y)
                            assertDelegate()
                        } catch _ {
                            XCTFail()
                            return
                        }
                    }
                }
            }

            do { // move of the dark-side player
                try controller.placeDiskAt(x: 4, y: 5)
            } catch _ {
                XCTFail()
                return
            }
            
            do { // during board animations
                func assertDelegate() {
                    XCTAssertEqual(delegate.message, .turn(.dark))
                    XCTAssertEqual(delegate.diskCounts, [.dark: 2, .light: 2]) // Updated after animations
                    XCTAssertEqual(delegate.players, [.dark: .manual, .light: .manual])
                    XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
                    XCTAssertEqual(delegate.board, board1)
                    XCTAssertNil(delegate.passAlertSide)

                    XCTAssertTrue(delegate.isWatingForBoardAnimation())
                    XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                    XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                    XCTAssertEqual(delegate.savedState, GameController.SavedState(
                        turn: .light,
                        darkPlayer: .manual,
                        lightPlayer: .manual,
                        board: board1
                    ))
                    
                    XCTAssertNil(delegate.boardForMove)
                    XCTAssertNil(delegate.sideForMove)
                    
                    XCTAssertFalse(delegate.isWaitingForMoveOfAI())
                }
                
                assertDelegate()
                
                // invalid placing disks during animations
                for y in 0 ..< 8 {
                    for x in 0 ..< 8 {
                        do {
                            try controller.placeDiskAt(x: x, y: y)
                            XCTFail()
                            return
                        } catch GameController.MoveError.duringAnimations {
                            assertDelegate()
                        } catch _ {
                            XCTFail()
                            return
                        }
                    }
                }
            }

            do { // completes board animations
                try delegate.completeBoardAnimation()
            } catch _ {
                XCTFail()
                return
            }
            
            do { // during wating for a player
                func assertDelegate() {
                    XCTAssertEqual(delegate.message, .turn(.light))
                    XCTAssertEqual(delegate.diskCounts, [.dark: 4, .light: 1])
                    XCTAssertEqual(delegate.players, [.dark: .manual, .light: .manual])
                    XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
                    XCTAssertEqual(delegate.board, board1)
                    XCTAssertNil(delegate.passAlertSide)

                    XCTAssertFalse(delegate.isWatingForBoardAnimation())
                    XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                    XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                    XCTAssertEqual(delegate.savedState, GameController.SavedState(
                        turn: .light,
                        darkPlayer: .manual,
                        lightPlayer: .manual,
                        board: board1
                    ))
                    
                    XCTAssertNil(delegate.boardForMove)
                    XCTAssertNil(delegate.sideForMove)
                    
                    XCTAssertFalse(delegate.isWaitingForMoveOfAI())
                }
                
                assertDelegate()
                
                // invalid placing disks during wating for a player
                for y in 0 ..< 8 {
                    for x in 0 ..< 8 {
                        if board1.canPlaceDisk(.light, atX: x, y: y) { continue }
                        do {
                            try controller.placeDiskAt(x: x, y: y)
                            XCTFail()
                            return
                        } catch GameController.MoveError.invalidMove(
                            .illegalPosition(x: let ex, y: let ey)
                        ) {
                            XCTAssertEqual(ex, x)
                            XCTAssertEqual(ey, y)
                            assertDelegate()
                        } catch _ {
                            XCTFail()
                            return
                        }
                    }
                }
            }
            
            do { // move of the light-side player
                try controller.placeDiskAt(x: 5, y: 5)
            } catch _ {
                XCTFail()
                return
            }
            
            do { // during board animations
                func assertDelegate() {
                    XCTAssertEqual(delegate.message, .turn(.light))
                    XCTAssertEqual(delegate.diskCounts, [.dark: 4, .light: 1]) // Updated after animations
                    XCTAssertEqual(delegate.players, [.dark: .manual, .light: .manual])
                    XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
                    XCTAssertEqual(delegate.board, board2)
                    XCTAssertNil(delegate.passAlertSide)

                    XCTAssertTrue(delegate.isWatingForBoardAnimation())
                    XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                    XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                    XCTAssertEqual(delegate.savedState, GameController.SavedState(
                        turn: .dark,
                        darkPlayer: .manual,
                        lightPlayer: .manual,
                        board: board2
                    ))
                    
                    XCTAssertNil(delegate.boardForMove)
                    XCTAssertNil(delegate.sideForMove)
                    
                    XCTAssertFalse(delegate.isWaitingForMoveOfAI())
                }
                
                assertDelegate()
                
                // invalid placing disks during animations
                for y in 0 ..< 8 {
                    for x in 0 ..< 8 {
                        do {
                            try controller.placeDiskAt(x: x, y: y)
                            XCTFail()
                            return
                        } catch GameController.MoveError.duringAnimations {
                            assertDelegate()
                        } catch _ {
                            XCTFail()
                            return
                        }
                    }
                }
            }

            do { // completes board animations
                try delegate.completeBoardAnimation()
            } catch _ {
                XCTFail()
                return
            }

            do { // result
                XCTAssertEqual(delegate.message, .turn(.dark))
                XCTAssertEqual(delegate.diskCounts, [.dark: 3, .light: 3])
                XCTAssertEqual(delegate.players, [.dark: .manual, .light: .manual])
                XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
                XCTAssertEqual(delegate.board, board2)
                XCTAssertNil(delegate.passAlertSide)

                XCTAssertFalse(delegate.isWatingForBoardAnimation())
                XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                XCTAssertEqual(delegate.savedState, GameController.SavedState(
                    turn: .dark,
                    darkPlayer: .manual,
                    lightPlayer: .manual,
                    board: board2
                ))
                
                XCTAssertNil(delegate.boardForMove)
                XCTAssertNil(delegate.sideForMove)
                
                XCTAssertFalse(delegate.isWaitingForMoveOfAI())
            }
        }
        
        do { // passes
            let delegate = TestDelegate()
            let board0: Board = .init("""
            --------
            --------
            --------
            xxxxxxxx
            oooooooo
            oooooooo
            oooooooo
            oooooooo
            """)
            let board1: Board = .init("""
            --------
            --------
            -------o
            xxxxxxoo
            oooooooo
            oooooooo
            oooooooo
            oooooooo
            """)
            let savedState: GameController.SavedState = .init(
                turn: .light,
                darkPlayer: .manual,
                lightPlayer: .manual,
                board: board0
            )
            delegate.savedState = savedState
            let controller = GameController(delegate: delegate)

            do {
                try controller.start()
            } catch _ {
                XCTFail()
                return
            }
            
            do { // during wating for a player
                XCTAssertEqual(delegate.message, .turn(.light))
                XCTAssertEqual(delegate.diskCounts, [.dark: 8, .light: 32])
                XCTAssertEqual(delegate.players, [.dark: .manual, .light: .manual])
                XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
                XCTAssertEqual(delegate.board, board0)
                XCTAssertNil(delegate.passAlertSide)

                XCTAssertFalse(delegate.isWatingForBoardAnimation())
                XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                XCTAssertEqual(delegate.savedState, GameController.SavedState(
                    turn: .light,
                    darkPlayer: .manual,
                    lightPlayer: .manual,
                    board: board0
                ))
                
                XCTAssertNil(delegate.boardForMove)
                XCTAssertNil(delegate.sideForMove)
                
                XCTAssertFalse(delegate.isWaitingForMoveOfAI())
            }
            
            do { // move of the light-side player
                try controller.placeDiskAt(x: 7, y: 2)
            } catch _ {
                XCTFail()
                return
            }
            
            do { // during board animations
                XCTAssertEqual(delegate.message, .turn(.light))
                XCTAssertEqual(delegate.diskCounts, [.dark: 8, .light: 32]) // Updated after animations
                XCTAssertEqual(delegate.players, [.dark: .manual, .light: .manual])
                XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
                XCTAssertEqual(delegate.board, board1)
                XCTAssertNil(delegate.passAlertSide)

                XCTAssertTrue(delegate.isWatingForBoardAnimation())
                XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                XCTAssertEqual(delegate.savedState, GameController.SavedState(
                    turn: .light, // it can be omitted to save passes
                    darkPlayer: .manual,
                    lightPlayer: .manual,
                    board: board1
                ))
                
                XCTAssertNil(delegate.boardForMove)
                XCTAssertNil(delegate.sideForMove)
                
                XCTAssertFalse(delegate.isWaitingForMoveOfAI())
            }

            do { // completes board animations
                try delegate.completeBoardAnimation()
            } catch _ {
                XCTFail()
                return
            }
            
            do { // pass of the dark-side player
                XCTAssertEqual(delegate.message, .turn(.dark))
                XCTAssertEqual(delegate.diskCounts, [.dark: 6, .light: 35])
                XCTAssertEqual(delegate.players, [.dark: .manual, .light: .manual])
                XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
                XCTAssertEqual(delegate.board, board1)
                XCTAssertEqual(delegate.passAlertSide, .dark)

                XCTAssertFalse(delegate.isWatingForBoardAnimation())
                XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                XCTAssertTrue(delegate.isWatingForPassAlertCompletion())

                XCTAssertEqual(delegate.savedState, GameController.SavedState(
                    turn: .light, // it can be omitted to save passes
                    darkPlayer: .manual,
                    lightPlayer: .manual,
                    board: board1
                ))
                
                XCTAssertNil(delegate.boardForMove)
                XCTAssertNil(delegate.sideForMove)
                
                XCTAssertFalse(delegate.isWaitingForMoveOfAI())
            }
            
            do { // dismisses a pass plert
                try delegate.completePassAlert()
            } catch _ {
                XCTFail()
                return
            }
            
            do { // result
                XCTAssertEqual(delegate.message, .turn(.light))
                XCTAssertEqual(delegate.diskCounts, [.dark: 6, .light: 35])
                XCTAssertEqual(delegate.players, [.dark: .manual, .light: .manual])
                XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
                XCTAssertEqual(delegate.board, board1)
                XCTAssertNil(delegate.passAlertSide)

                XCTAssertFalse(delegate.isWatingForBoardAnimation())
                XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                XCTAssertEqual(delegate.savedState, GameController.SavedState(
                    turn: .light,
                    darkPlayer: .manual,
                    lightPlayer: .manual,
                    board: board1
                ))
                
                XCTAssertNil(delegate.boardForMove)
                XCTAssertNil(delegate.sideForMove)
                
                XCTAssertFalse(delegate.isWaitingForMoveOfAI())
            }
        }
        
        do { // over
            let delegate = TestDelegate()
            let board0: Board = .init("""
            --oxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            """)
            let board1: Board = .init("""
            -xxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            """)
            let savedState: GameController.SavedState = .init(
                turn: .dark,
                darkPlayer: .manual,
                lightPlayer: .manual,
                board: board0
            )
            delegate.savedState = savedState
            let controller = GameController(delegate: delegate)
            
            do {
                try controller.start()
            } catch _ {
                XCTFail()
                return
            }
            
            do { // during wating for a player
                XCTAssertEqual(delegate.message, .turn(.dark))
                XCTAssertEqual(delegate.diskCounts, [.dark: 61, .light: 1])
                XCTAssertEqual(delegate.players, [.dark: .manual, .light: .manual])
                XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
                XCTAssertEqual(delegate.board, board0)
                XCTAssertNil(delegate.passAlertSide)

                XCTAssertFalse(delegate.isWatingForBoardAnimation())
                XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                XCTAssertEqual(delegate.savedState, GameController.SavedState(
                    turn: .dark,
                    darkPlayer: .manual,
                    lightPlayer: .manual,
                    board: board0
                ))
                
                XCTAssertNil(delegate.boardForMove)
                XCTAssertNil(delegate.sideForMove)
                
                XCTAssertFalse(delegate.isWaitingForMoveOfAI())
            }
            
            do { // move of the light-side player
                try controller.placeDiskAt(x: 1, y: 0)
            } catch _ {
                XCTFail()
                return
            }
            
            do { // during board animations
                XCTAssertEqual(delegate.message, .turn(.dark))
                XCTAssertEqual(delegate.diskCounts, [.dark: 61, .light: 1]) // Updated after animations
                XCTAssertEqual(delegate.players, [.dark: .manual, .light: .manual])
                XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
                XCTAssertEqual(delegate.board, board1)
                XCTAssertNil(delegate.passAlertSide)

                XCTAssertTrue(delegate.isWatingForBoardAnimation())
                XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                XCTAssertEqual(delegate.savedState, GameController.SavedState(
                    turn: nil,
                    darkPlayer: .manual,
                    lightPlayer: .manual,
                    board: board1
                ))
                
                XCTAssertNil(delegate.boardForMove)
                XCTAssertNil(delegate.sideForMove)
                
                XCTAssertFalse(delegate.isWaitingForMoveOfAI())
            }

            do { // completes board animations
                try delegate.completeBoardAnimation()
            } catch _ {
                XCTFail()
                return
            }
            
            do { // result
                XCTAssertEqual(delegate.message, .result(winner: .dark))
                XCTAssertEqual(delegate.diskCounts, [.dark: 63, .light: 0])
                XCTAssertEqual(delegate.players, [.dark: .manual, .light: .manual])
                XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
                XCTAssertEqual(delegate.board, board1)
                XCTAssertNil(delegate.passAlertSide)

                XCTAssertFalse(delegate.isWatingForBoardAnimation())
                XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                XCTAssertEqual(delegate.savedState, GameController.SavedState(
                    turn: nil,
                    darkPlayer: .manual,
                    lightPlayer: .manual,
                    board: board1
                ))
                
                XCTAssertNil(delegate.boardForMove)
                XCTAssertNil(delegate.sideForMove)
                
                XCTAssertFalse(delegate.isWaitingForMoveOfAI())
            }
        }
    }
    
    func testComputers() {
        do {
            let delegate = TestDelegate()
            let controller = GameController(delegate: delegate)
            delegate.setPlayer(.computer, of: .dark)
            controller.setPlayer(.computer, of: .dark)
            delegate.setPlayer(.computer, of: .light)
            controller.setPlayer(.computer, of: .light)
            do {
                try controller.start()
            } catch _ {
                XCTFail()
                return
            }
            
            let board0: Board = .init(width: 8, height: 8)
            let board1: Board = .init("""
            --------
            --------
            --------
            ---ox---
            ---xx---
            ----x---
            --------
            --------
            """)
            let board2: Board = .init("""
            --------
            --------
            --------
            ---ox---
            ---xo---
            ----xo--
            --------
            --------
            """)
            
            do { // during wating for a player
                func assertDelegate() {
                    XCTAssertEqual(delegate.message, .turn(.dark))
                    XCTAssertEqual(delegate.diskCounts, [.dark: 2, .light: 2])
                    XCTAssertEqual(delegate.players, [.dark: .computer, .light: .computer])
                    XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: true, .light: false])
                    XCTAssertEqual(delegate.board, board0)
                    XCTAssertNil(delegate.passAlertSide)

                    XCTAssertFalse(delegate.isWatingForBoardAnimation())
                    XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                    XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                    XCTAssertEqual(delegate.savedState, GameController.SavedState(
                        turn: .dark,
                        darkPlayer: .computer,
                        lightPlayer: .computer,
                        board: board0
                    ))
                    
                    XCTAssertEqual(delegate.boardForMove, board0)
                    XCTAssertEqual(delegate.sideForMove, .dark)
                    
                    XCTAssertTrue(delegate.isWaitingForMoveOfAI())
                }
                
                assertDelegate()
                
                // invalid placing disks during wating for a player
                for y in 0 ..< 8 {
                    for x in 0 ..< 8 {
                        do {
                            try controller.placeDiskAt(x: x, y: y)
                            XCTFail()
                            return
                        } catch GameController.MoveError.playerInTurnIsNotManual {
                            assertDelegate()
                        } catch _ {
                            XCTFail()
                            return
                        }
                    }
                }
            }

            do { // move of the dark-side player
                try delegate.handleMoveOfAIAt(x: 4, y: 5)
            } catch _ {
                XCTFail()
                return
            }
            
            do { // during board animations
                func assertDelegate() {
                    XCTAssertEqual(delegate.message, .turn(.dark))
                    XCTAssertEqual(delegate.diskCounts, [.dark: 2, .light: 2]) // Updated after animations
                    XCTAssertEqual(delegate.players, [.dark: .computer, .light: .computer])
                    XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
                    XCTAssertEqual(delegate.board, board1)
                    XCTAssertNil(delegate.passAlertSide)

                    XCTAssertTrue(delegate.isWatingForBoardAnimation())
                    XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                    XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                    XCTAssertEqual(delegate.savedState, GameController.SavedState(
                        turn: .light,
                        darkPlayer: .computer,
                        lightPlayer: .computer,
                        board: board1
                    ))
                    
                    XCTAssertNil(delegate.boardForMove)
                    XCTAssertNil(delegate.sideForMove)
                    
                    XCTAssertFalse(delegate.isWaitingForMoveOfAI())
                }
                
                assertDelegate()
                
                // invalid placing disks during animations
                for y in 0 ..< 8 {
                    for x in 0 ..< 8 {
                        do {
                            try controller.placeDiskAt(x: x, y: y)
                            XCTFail()
                            return
                        } catch GameController.MoveError.duringAnimations {
                            assertDelegate()
                        } catch _ {
                            XCTFail()
                            return
                        }
                    }
                }
            }

            do { // completes board animations
                try delegate.completeBoardAnimation()
            } catch _ {
                XCTFail()
                return
            }
            
            do { // placing diks while a computer player is thinking
                func assertDelegate() {
                    XCTAssertEqual(delegate.message, .turn(.light))
                    XCTAssertEqual(delegate.diskCounts, [.dark: 4, .light: 1])
                    XCTAssertEqual(delegate.players, [.dark: .computer, .light: .computer])
                    XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: true])
                    XCTAssertEqual(delegate.board, board1)
                    XCTAssertNil(delegate.passAlertSide)

                    XCTAssertFalse(delegate.isWatingForBoardAnimation())
                    XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                    XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                    XCTAssertEqual(delegate.savedState, GameController.SavedState(
                        turn: .light,
                        darkPlayer: .computer,
                        lightPlayer: .computer,
                        board: board1
                    ))
                    
                    XCTAssertEqual(delegate.boardForMove, board1)
                    XCTAssertEqual(delegate.sideForMove, .light)
                    
                    XCTAssertTrue(delegate.isWaitingForMoveOfAI())
                }
                
                assertDelegate()
                
                for y in 0 ..< 8 {
                    for x in 0 ..< 8 {
                        do {
                            try controller.placeDiskAt(x: x, y: y)
                            XCTFail()
                            return
                        } catch GameController.MoveError.playerInTurnIsNotManual {
                            assertDelegate()
                        } catch _ {
                            XCTFail()
                            return
                        }
                    }
                }
            }
            
            do { // move of the light-side player
                try delegate.handleMoveOfAIAt(x: 5, y: 5)
            } catch _ {
                XCTFail()
                return
            }
            
            do { // during board animations
                func assertDelegate() {
                    XCTAssertEqual(delegate.message, .turn(.light))
                    XCTAssertEqual(delegate.diskCounts, [.dark: 4, .light: 1]) // Updated after animations
                    XCTAssertEqual(delegate.players, [.dark: .computer, .light: .computer])
                    XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
                    XCTAssertEqual(delegate.board, board2)
                    XCTAssertNil(delegate.passAlertSide)

                    XCTAssertTrue(delegate.isWatingForBoardAnimation())
                    XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                    XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                    XCTAssertEqual(delegate.savedState, GameController.SavedState(
                        turn: .dark,
                        darkPlayer: .computer,
                        lightPlayer: .computer,
                        board: board2
                    ))
                    
                    XCTAssertNil(delegate.boardForMove)
                    XCTAssertNil(delegate.sideForMove)
                    
                    XCTAssertFalse(delegate.isWaitingForMoveOfAI())
                }
                
                assertDelegate()
                
                // invalid placing disks during animations
                for y in 0 ..< 8 {
                    for x in 0 ..< 8 {
                        do {
                            try controller.placeDiskAt(x: x, y: y)
                            XCTFail()
                            return
                        } catch GameController.MoveError.duringAnimations {
                            assertDelegate()
                        } catch _ {
                            XCTFail()
                            return
                        }
                    }
                }
            }
            
            do { // completes board animations
                try delegate.completeBoardAnimation()
            } catch _ {
                XCTFail()
                return
            }

            do { // result
                XCTAssertEqual(delegate.message, .turn(.dark))
                XCTAssertEqual(delegate.diskCounts, [.dark: 3, .light: 3])
                XCTAssertEqual(delegate.players, [.dark: .computer, .light: .computer])
                XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: true, .light: false])
                XCTAssertEqual(delegate.board, board2)
                XCTAssertNil(delegate.passAlertSide)

                XCTAssertFalse(delegate.isWatingForBoardAnimation())
                XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                XCTAssertEqual(delegate.savedState, GameController.SavedState(
                    turn: .dark,
                    darkPlayer: .computer,
                    lightPlayer: .computer,
                    board: board2
                ))
                
                XCTAssertEqual(delegate.boardForMove, board2)
                XCTAssertEqual(delegate.sideForMove, .dark)
                
                XCTAssertTrue(delegate.isWaitingForMoveOfAI())
            }
        }
        
        do { // passes
            let delegate = TestDelegate()
            let board0: Board = .init("""
            --------
            --------
            --------
            xxxxxxxx
            oooooooo
            oooooooo
            oooooooo
            oooooooo
            """)
            let board1: Board = .init("""
            --------
            --------
            -------o
            xxxxxxoo
            oooooooo
            oooooooo
            oooooooo
            oooooooo
            """)
            let savedState: GameController.SavedState = .init(
                turn: .light,
                darkPlayer: .computer,
                lightPlayer: .computer,
                board: board0
            )
            delegate.savedState = savedState
            let controller = GameController(delegate: delegate)

            do {
                try controller.start()
            } catch _ {
                XCTFail()
                return
            }
            
            do { // during wating for a player
                XCTAssertEqual(delegate.message, .turn(.light))
                XCTAssertEqual(delegate.diskCounts, [.dark: 8, .light: 32])
                XCTAssertEqual(delegate.players, [.dark: .computer, .light: .computer])
                XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: true])
                XCTAssertEqual(delegate.board, board0)
                XCTAssertNil(delegate.passAlertSide)

                XCTAssertFalse(delegate.isWatingForBoardAnimation())
                XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                XCTAssertEqual(delegate.savedState, GameController.SavedState(
                    turn: .light,
                    darkPlayer: .computer,
                    lightPlayer: .computer,
                    board: board0
                ))
                
                XCTAssertEqual(delegate.boardForMove, board0)
                XCTAssertEqual(delegate.sideForMove, .light)
                
                XCTAssertTrue(delegate.isWaitingForMoveOfAI())
            }
            
            do { // move of the light-side player
                try delegate.handleMoveOfAIAt(x: 7, y: 2)
            } catch _ {
                XCTFail()
                return
            }
            
            do { // during board animations
                XCTAssertEqual(delegate.message, .turn(.light))
                XCTAssertEqual(delegate.diskCounts, [.dark: 8, .light: 32]) // Updated after animations
                XCTAssertEqual(delegate.players, [.dark: .computer, .light: .computer])
                XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
                XCTAssertEqual(delegate.board, board1)
                XCTAssertNil(delegate.passAlertSide)

                XCTAssertTrue(delegate.isWatingForBoardAnimation())
                XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                XCTAssertEqual(delegate.savedState, GameController.SavedState(
                    turn: .light, // it can be omitted to save passes
                    darkPlayer: .computer,
                    lightPlayer: .computer,
                    board: board1
                ))
                
                XCTAssertNil(delegate.boardForMove)
                XCTAssertNil(delegate.sideForMove)
                
                XCTAssertFalse(delegate.isWaitingForMoveOfAI())
            }

            do { // completes board animations
                try delegate.completeBoardAnimation()
            } catch _ {
                XCTFail()
                return
            }
            
            do { // pass of the dark-side player
                XCTAssertEqual(delegate.message, .turn(.dark))
                XCTAssertEqual(delegate.diskCounts, [.dark: 6, .light: 35])
                XCTAssertEqual(delegate.players, [.dark: .computer, .light: .computer])
                XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
                XCTAssertEqual(delegate.board, board1)
                XCTAssertEqual(delegate.passAlertSide, .dark)

                XCTAssertFalse(delegate.isWatingForBoardAnimation())
                XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                XCTAssertTrue(delegate.isWatingForPassAlertCompletion())

                XCTAssertEqual(delegate.savedState, GameController.SavedState(
                    turn: .light, // it can be omitted to save passes
                    darkPlayer: .computer,
                    lightPlayer: .computer,
                    board: board1
                ))
                
                XCTAssertNil(delegate.boardForMove)
                XCTAssertNil(delegate.sideForMove)
                
                XCTAssertFalse(delegate.isWaitingForMoveOfAI())
            }
            
            do { // dismisses a pass plert
                try delegate.completePassAlert()
            } catch _ {
                XCTFail()
                return
            }
            
            do { // result
                XCTAssertEqual(delegate.message, .turn(.light))
                XCTAssertEqual(delegate.diskCounts, [.dark: 6, .light: 35])
                XCTAssertEqual(delegate.players, [.dark: .computer, .light: .computer])
                XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: true])
                XCTAssertEqual(delegate.board, board1)
                XCTAssertNil(delegate.passAlertSide)

                XCTAssertFalse(delegate.isWatingForBoardAnimation())
                XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                XCTAssertEqual(delegate.savedState, GameController.SavedState(
                    turn: .light,
                    darkPlayer: .computer,
                    lightPlayer: .computer,
                    board: board1
                ))
                
                XCTAssertEqual(delegate.boardForMove, board1)
                XCTAssertEqual(delegate.sideForMove, .light)
                
                XCTAssertTrue(delegate.isWaitingForMoveOfAI())
            }
        }
        
        do { // over
            let delegate = TestDelegate()
            let board0: Board = .init("""
            --oxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            """)
            let board1: Board = .init("""
            -xxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            xxxxxxxx
            """)
            let savedState: GameController.SavedState = .init(
                turn: .dark,
                darkPlayer: .computer,
                lightPlayer: .computer,
                board: board0
            )
            delegate.savedState = savedState
            let controller = GameController(delegate: delegate)
            
            do {
                try controller.start()
            } catch _ {
                XCTFail()
                return
            }
            
            do { // during wating for a player
                XCTAssertEqual(delegate.message, .turn(.dark))
                XCTAssertEqual(delegate.diskCounts, [.dark: 61, .light: 1])
                XCTAssertEqual(delegate.players, [.dark: .computer, .light: .computer])
                XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: true, .light: false])
                XCTAssertEqual(delegate.board, board0)
                XCTAssertNil(delegate.passAlertSide)

                XCTAssertFalse(delegate.isWatingForBoardAnimation())
                XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                XCTAssertEqual(delegate.savedState, GameController.SavedState(
                    turn: .dark,
                    darkPlayer: .computer,
                    lightPlayer: .computer,
                    board: board0
                ))
                
                XCTAssertEqual(delegate.boardForMove, board0)
                XCTAssertEqual(delegate.sideForMove, .dark)
                
                XCTAssertTrue(delegate.isWaitingForMoveOfAI())
            }
            
            do { // move of the light-side player
                try delegate.handleMoveOfAIAt(x: 1, y: 0)
            } catch _ {
                XCTFail()
                return
            }
            
            do { // during board animations
                XCTAssertEqual(delegate.message, .turn(.dark))
                XCTAssertEqual(delegate.diskCounts, [.dark: 61, .light: 1]) // Updated after animations
                XCTAssertEqual(delegate.players, [.dark: .computer, .light: .computer])
                XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
                XCTAssertEqual(delegate.board, board1)
                XCTAssertNil(delegate.passAlertSide)

                XCTAssertTrue(delegate.isWatingForBoardAnimation())
                XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                XCTAssertEqual(delegate.savedState, GameController.SavedState(
                    turn: nil,
                    darkPlayer: .computer,
                    lightPlayer: .computer,
                    board: board1
                ))
                
                XCTAssertNil(delegate.boardForMove)
                XCTAssertNil(delegate.sideForMove)
                
                XCTAssertFalse(delegate.isWaitingForMoveOfAI())
            }

            do { // completes board animations
                try delegate.completeBoardAnimation()
            } catch _ {
                XCTFail()
                return
            }
            
            do { // result
                XCTAssertEqual(delegate.message, .result(winner: .dark))
                XCTAssertEqual(delegate.diskCounts, [.dark: 63, .light: 0])
                XCTAssertEqual(delegate.players, [.dark: .computer, .light: .computer])
                XCTAssertEqual(delegate.playerActivityIndicatorVisibilities, [.dark: false, .light: false])
                XCTAssertEqual(delegate.board, board1)
                XCTAssertNil(delegate.passAlertSide)

                XCTAssertFalse(delegate.isWatingForBoardAnimation())
                XCTAssertFalse(delegate.isWatingForResetGameConfirmation())
                XCTAssertFalse(delegate.isWatingForPassAlertCompletion())

                XCTAssertEqual(delegate.savedState, GameController.SavedState(
                    turn: nil,
                    darkPlayer: .computer,
                    lightPlayer: .computer,
                    board: board1
                ))
                
                XCTAssertNil(delegate.boardForMove)
                XCTAssertNil(delegate.sideForMove)
                
                XCTAssertFalse(delegate.isWaitingForMoveOfAI())
            }
        }    }
}

class TestDelegate {
    // GameControllerDelegate
    private(set) var message: GameController.Message?
    private(set) var diskCounts: [Disk: Int] = [:]
    private(set) var players: [Disk: GameController.Player] = [:]
    private(set) var playerActivityIndicatorVisibilities: [Disk: Bool] = [:]
    private(set) var board: Board?
    private(set) var passAlertSide: Disk?
    
    private(set) var boardAnimationCompletion: (() -> Void)?
    private(set) var resetGameConfirmationCompletion: ((Bool) -> Void)?
    private(set) var passAlertCompletion: (() -> Void)?
    
    // GameControllerSaveDelegate
    var savedState: GameController.SavedState?
    
    // GameControllerStrategyDelegate
    private(set) var boardForMove: Board?
    private(set) var sideForMove: Disk?
    private(set) var moveHandler: ((Int, Int) -> Void)?
}

extension TestDelegate: GameControllerDelegate {
    func updateMessage(_ message: GameController.Message, animated isAnimated: Bool) {
        self.message = message
    }
    
    func updateDiskCountsOf(dark darkDiskCount: Int, light lightDiskCount: Int, animated isAnimated: Bool) {
        diskCounts[.dark] = darkDiskCount
        diskCounts[.light] = lightDiskCount
    }
    
    func updatePlayer(_ player: GameController.Player, of side: Disk, animated isAnimated: Bool) {
        players[side] = player
    }
    
    func updatePlayerActivityInidicatorVisibility(_ isVisible: Bool, of side: Disk, animated isAnimated: Bool) {
        playerActivityIndicatorVisibilities[side] = isVisible
    }
    
    func updateBoard(_ board: Board, animated isAnimated: Bool, completion: @escaping () -> Void) -> Canceller {
        self.board = board
        boardAnimationCompletion = completion
        let canceller = Canceller { [weak self] in
            self?.boardAnimationCompletion = nil
        }
        if !isAnimated {
            try! completeBoardAnimation()
        }
        return canceller
    }
    
    func confirmToResetGame(completion: @escaping (Bool) -> Void) {
        resetGameConfirmationCompletion = completion
    }
    
    func alertPass(of side: Disk, completion: @escaping () -> Void) {
        passAlertSide = side
        passAlertCompletion = completion
    }
    
    func completeBoardAnimation() throws {
        guard let completion = boardAnimationCompletion else { throw GeneralError() }
        completion()
        boardAnimationCompletion = nil
    }
    
    func completeResetGameConfirmation(isConfirmed: Bool) throws {
        guard let completion = resetGameConfirmationCompletion else { throw GeneralError() }
        completion(isConfirmed)
        resetGameConfirmationCompletion = nil
    }
    
    func completePassAlert() throws {
        guard let completion = passAlertCompletion else { throw GeneralError() }
        completion()
        passAlertSide = nil
        passAlertCompletion = nil
    }
    
    func setPlayer(_ player: GameController.Player, of side: Disk) {
        players[side] = player
    }
    
    func clearPlayers() {
        players = [:]
    }
    
    func isWatingForBoardAnimation() -> Bool {
        boardAnimationCompletion != nil
    }
    
    func isWatingForResetGameConfirmation() -> Bool {
        resetGameConfirmationCompletion != nil
    }
    
    func isWatingForPassAlertCompletion() -> Bool {
        passAlertCompletion != nil
    }
}

extension TestDelegate: GameControllerSaveDelegate {
    func saveGame(_ state: GameController.SavedState) throws {
        savedState = state
    }
    
    func loadGame() throws -> GameController.SavedState {
        guard let savedState = savedState else { throw GeneralError() }
        return savedState
    }
}

extension TestDelegate: GameControllerStrategyDelegate {
    func move(for board: Board, of side: Disk, handler: @escaping (Int, Int) -> Void) -> Canceller {
        boardForMove = board
        sideForMove = side
        moveHandler = handler
        return Canceller { [weak self] in
            guard let self = self else { return }
            self.boardForMove = nil
            self.sideForMove = nil
            self.moveHandler = nil
        }
    }
    
    func handleMoveOfAIAt(x: Int, y: Int) throws {
        guard let completion = moveHandler else { throw GeneralError() }
        completion(x, y)
        boardForMove = nil
        sideForMove = nil
        moveHandler = nil
    }
    
    func isWaitingForMoveOfAI() -> Bool {
        moveHandler != nil
    }
}
