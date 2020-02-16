import CleanReversi
import CleanReversiApp
import Foundation

public final class GameSaver: GameControllerSaveDelegate {
    private weak var delegate: GameSaverDelegate?
    
    public init(delegate: GameSaverDelegate) {
        self.delegate = delegate
    }
    
    public func saveGame(_ state: GameController.SavedState) throws {
        try delegate?.writeData(state.data())
    }
    
    public func loadGame() throws -> GameController.SavedState {
        guard let delegate = self.delegate else { throw IOError() }
        return try GameController.SavedState(data: try delegate.readData())
    }
    
    public struct IOError: Error {
        public let cause: Error?
        public init(cause: Error? = nil) {
            self.cause = cause
        }
    }
}

public protocol GameSaverDelegate: AnyObject {
    func writeData(_: Data) throws
    func readData() throws -> Data
}
