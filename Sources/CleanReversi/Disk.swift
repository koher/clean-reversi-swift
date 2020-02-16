public enum Disk {
    case dark
    case light
}

extension Disk: Hashable {}

extension Disk {
    public static var sides: [Disk] {
        [.dark, .light]
    }
    
    public var flipped: Disk {
        switch self {
        case .dark: return .light
        case .light: return .dark
        }
    }
    
    public mutating func flip() {
        self = flipped
    }
}


extension Disk {
    public static func random() -> Disk {
        Bool.random() ? .dark : .light
    }
}

extension Disk: Equatable {}

extension Disk {
    public var symbol: String {
        switch self {
        case .dark:
            return "x"
        case .light:
            return "o"
        }
    }
}

extension Optional where Wrapped == Disk {
    public var symbol: String {
        switch self {
        case .some(let disk):
            return disk.symbol
        case .none:
            return "-"
        }
    }
}
