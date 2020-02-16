import CleanReversi
import CleanReversiAsync
import Foundation

public final class GameController {
    private var game: Game = .init()
    private var hasBeenStarted: Bool = false

    // Do not use `_players` directly.
    // `_players` always have values for both keys
    // of `.dark` and `.light` after initializations.
    // `[Disk: Player]` does not guarantee it.
    // Use `player(of:)`, `setPlayer(_:of:)`
    // or `setPlayerWithNotification(_:of:)` instead.
    private var _players: [Disk: Player]
    public func player(of side: Disk) -> Player {
        _players[side]!
    }

    private var animationCanceller: Canceller?
    private var playerCancellers: [Disk: Canceller] = [:]
    private var isWaitingForPlayer: Bool {
        guard case .beingPlayed(let turn) = game.state else { return false }
        return playerCancellers[turn] != nil && animationCanceller == nil
    }
    
    private weak var delegate: GameControllerDelegate?
    private weak var saveDelegate: GameControllerSaveDelegate?
    private weak var strategyDelegate: GameControllerStrategyDelegate?
    
    public init(
        delegate: GameControllerDelegate,
        saveDelegate: GameControllerSaveDelegate,
        strategyDelegate: GameControllerStrategyDelegate
    ) {
        precondition(Thread.isMainThread)
        self.delegate = delegate
        self.saveDelegate = saveDelegate
        self.strategyDelegate = strategyDelegate
        
        _players = [:]
        
        do {
            try loadGame()
        } catch _ {
            newGame()
        }
        
        assert(_players[.dark] != nil)
        assert(_players[.light] != nil)
        
        delegate.updatePlayerActivityInidicatorVisibility(false, of: .dark, animated: false)
        delegate.updatePlayerActivityInidicatorVisibility(false, of: .light, animated: false)
    }
    
    public convenience init(delegate: GameControllerDelegate & GameControllerSaveDelegate & GameControllerStrategyDelegate) {
        self.init(delegate: delegate, saveDelegate: delegate, strategyDelegate: delegate)
    }
    
    public func start() throws {
        precondition(Thread.isMainThread)
        if hasBeenStarted {
            throw StartError.alreadyStarted
        }
        hasBeenStarted = true
        waitForPlayer()
    }
    
    private func newGame() {
        game = .init()
        
        for side in Disk.sides {
            setPlayerWithNotification(.manual, of: side)
        }

        updateMessage()
        updateDiskCounts()
        _ = delegate?.updateBoard(game.board, animated: false, completion: {})

        try? saveGame()
    }
    
    private func waitForPlayer() {
        guard case .beingPlayed(let turn) = game.state else { return }
        switch player(of: turn) {
        case .manual:
            let cleanUp: () -> Void = { [weak self] in
                self?.playerCancellers[turn] = nil
            }
            playerCancellers[turn] = Canceller(cleanUp)
        case .computer:
            guard let delegate = self.delegate else { return }
            guard let strategyDelegate = self.strategyDelegate else { return }
            
            let cleanUp: () -> Void = { [weak self] in
                guard let self = self, let delegate = self.delegate else { return }
                delegate.updatePlayerActivityInidicatorVisibility(false, of: turn, animated: true)
                self.playerCancellers[turn] = nil
            }
            let canceller = Canceller(cleanUp)
            delegate.updatePlayerActivityInidicatorVisibility(true, of: turn, animated: true)
            canceller.addSubcanceller(strategyDelegate.move(for: game.board, of: turn) { [weak self] x, y in
                guard let self = self else { return }
                if canceller.isCancelled { return }
                cleanUp()
                try! self.handleMove(of: turn, atX: x, y: y)
            })
            playerCancellers[turn] = canceller
        }
    }

    private func handleMove(of side: Disk, atX x: Int, y: Int) throws {
        try game.placeDiskAt(x: x, y: y)
        try? saveGame()

        guard let delegate = self.delegate else { return }
        let cleanUp: () -> Void = { [weak self] in
            self?.animationCanceller = nil
        }
        let canceller = Canceller(cleanUp)
        canceller.addSubcanceller(delegate.updateBoard(game.board, animated: true) { [weak self] in
            guard let self = self else { return }
            guard let _ = self.animationCanceller else { return }
            cleanUp()
            self.updateDiskCounts()
            
            if
                case .beingPlayed(let nextTurn) = self.game.state,
                side == nextTurn
            { // Pass
                let sideToPass = side.flipped
                self.updateMessage(.turn(sideToPass))
                self.delegate?.alertPass(of: sideToPass) { [weak self] in
                    guard let self = self else { return }
                    self.updateMessage()
                    self.waitForPlayer()
                }
            } else {
                self.updateMessage()
                self.waitForPlayer()
            }
        })
        animationCanceller = canceller
    }
}

// MARK: Inputs

extension GameController {
    public func reset() {
        precondition(Thread.isMainThread)
        delegate?.confirmToResetGame { [weak self] isOK in
            guard let self = self else { return }
            guard isOK else { return }
            
            self.animationCanceller?.cancel()
            self.animationCanceller = nil

            for side in Disk.sides {
                self.playerCancellers[side]?.cancel()
                self.playerCancellers.removeValue(forKey: side)
            }
            
            self.newGame()
            self.waitForPlayer()
        }
    }
    
    public func setPlayer(_ player: Player, of side: Disk) {
        _players[side] = player
        
        // Avoids saving during initializations
        if _players[.dark] != nil, _players[.light] != nil {
            try? saveGame()
        }
        
        if let canceller = playerCancellers[side] {
            assert(game.state == .beingPlayed(turn: side))
            canceller.cancel()
            waitForPlayer()
        }
    }
    
    private func setPlayerWithNotification(_ player: Player, of side: Disk) {
        if _players[side] == player { return }
        setPlayer(player, of: side)
        delegate?.updatePlayer(player, of: side, animated: hasBeenStarted)
    }
    
    public func placeDiskAt(x: Int, y: Int) throws {
        precondition(Thread.isMainThread)
        guard case .beingPlayed(let turn) = game.state else { throw MoveError.gameIsOver }
        guard isWaitingForPlayer else { throw MoveError.duringAnimations }
        guard case .manual = player(of: turn) else { throw MoveError.playerInTurnIsNotManual }
        do {
            try handleMove(of: turn, atX: x, y: y)
        } catch let error as Game.DiskPlacementError {
            throw MoveError.invalidMove(error)
        } catch _ {
            preconditionFailure("Never reaches here.")
        }
    }

    public enum DiskPlacementError: Error {
        case illegalGameState(Game.State)
        case illegalPosition(x: Int, y: Int)
        case nonManual
    }
}

// MARK: Support

extension GameController {
    private func updateMessage(_ message: Message? = nil) {
        delegate?.updateMessage(message ?? .init(gameState: game.state), animated: hasBeenStarted)
    }
    
    private func updateDiskCounts() {
        delegate?.updateDiskCountsOf(dark: game.board.count(of: .dark), light: game.board.count(of: .light), animated: hasBeenStarted)
    }
}

// MARK: Save and Load

extension GameController {
    private func saveGame() throws {
        let turn: Disk?
        switch game.state {
        case .beingPlayed(turn: let currentTurn):
            turn = currentTurn
        case .over(winner: _):
            turn = nil
        }
        try saveDelegate?.saveGame(SavedState(
            turn: turn,
            darkPlayer: player(of: .dark),
            lightPlayer: player(of: .light),
            board: game.board
        ))
    }
    
    private func loadGame() throws {
        guard let saveDelegate = self.saveDelegate else {
            throw LoadError()
        }
        do {
            let savedState = try saveDelegate.loadGame()
            game = Game(board: savedState.board, turn: savedState.turn ?? .dark)
            setPlayerWithNotification(savedState.darkPlayer, of: .dark)
            setPlayerWithNotification(savedState.lightPlayer, of: .light)
        } catch let error {
            throw LoadError(cause: error)
        }
        
        updateMessage()
        updateDiskCounts()
        _ = delegate?.updateBoard(game.board, animated: false, completion: {})
    }
}

// MARK: Additional types

extension GameController {
    public enum Player: Hashable {
        case manual
        case computer
    }
}

extension GameController {
    public enum Message: Equatable {
        case turn(Disk)
        case result(winner: Disk?)
        
        public init(gameState: Game.State) {
            switch gameState {
            case .beingPlayed(turn: let turn):
                self = .turn(turn)
            case .over(winner: let winner):
                self = .result(winner: winner)
            }
        }
    }
}

extension GameController {
    public struct SavedState: Equatable {
        public var turn: Disk?
        public var darkPlayer: Player
        public var lightPlayer: Player
        public var board: Board
        
        public init(turn: Disk?, darkPlayer: Player, lightPlayer: Player, board: Board) {
            self.turn = turn
            self.darkPlayer = darkPlayer
            self.lightPlayer = lightPlayer
            self.board = board
        }
    }
}

extension GameController {
    public enum StartError: Error {
        case alreadyStarted
    }
    
    public enum MoveError: Error {
        case gameIsOver
        case playerInTurnIsNotManual
        case duringAnimations
        case invalidMove(Game.DiskPlacementError)
    }
    
    public struct LoadError: Error {
        public let cause: Error?
        public init(cause: Error? = nil) {
            self.cause = cause
        }
    }
}

// MARK: Delegates

public protocol GameControllerDelegate: AnyObject {
    func updateMessage(_ message: GameController.Message, animated: Bool)
    func updateDiskCountsOf(dark darkDiskCount: Int, light lightDiskCount: Int, animated: Bool)
    func updatePlayer(_ player: GameController.Player, of side: Disk, animated: Bool)
    func updatePlayerActivityInidicatorVisibility(_ isVisible: Bool, of side: Disk, animated: Bool)
    
    func updateBoard(_ board: Board, animated: Bool, completion: @escaping () -> Void) -> Canceller
    func confirmToResetGame(completion: @escaping (Bool) -> Void)
    func alertPass(of side: Disk, completion: @escaping () -> Void)
}

public protocol GameControllerSaveDelegate: AnyObject {
    func saveGame(_ state: GameController.SavedState) throws
    func loadGame() throws -> GameController.SavedState
}

public protocol GameControllerStrategyDelegate: AnyObject {
    func move(for board: Board, of side: Disk, completion: @escaping (Int, Int) -> Void) -> Canceller
}
