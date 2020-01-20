import XCTest

internal func XCTAssertEqual<T1: Equatable, T2: Equatable>(_ a: [(T1, T2)], _ b: [(T1, T2)]) {
    guard a.count == b.count else {
        XCTFail("(\(a)) is not equal to (\(b))")
        return
    }
    
    for (t1, t2) in zip(a, b) {
        guard t1 == t2 else {
            XCTFail("(\(a)) is not equal to (\(b))")
            return
        }
    }
}
