public enum Disk {
    case dark
    case light
}

extension Disk {
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
