public final class Canceller {
    public private(set) var isCancelled: Bool = false
    private let body: (() -> Void)?
    private var subcancellers: [Canceller] = []
    
    public init(_ body: (() -> Void)? = nil) {
        self.body = body
    }
    
    public func addSubcanceller(_ subcanceller: Canceller) {
        subcancellers.append(subcanceller)
    }
    
    public func cancel() {
        if isCancelled { return }
        isCancelled = true
        
        for subcanceller in subcancellers {
            subcanceller.cancel()
        }
        subcancellers.removeAll()
        
        body?()
    }
}
