#if !canImport(ObjectiveC)
import XCTest

extension BoardTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__BoardTests = [
        ("testCanPlaceDiskAt", testCanPlaceDiskAt),
        ("testCountOf", testCountOf),
        ("testDescription", testDescription),
        ("testFlip", testFlip),
        ("testFlipped", testFlipped),
        ("testInit", testInit),
        ("testInitWithSymbolBoard", testInitWithSymbolBoard),
        ("testPlaceDiskAt", testPlaceDiskAt),
        ("testReset", testReset),
        ("testSideWithMoreDisks", testSideWithMoreDisks),
        ("testValidMoves", testValidMoves),
        ("testXRange", testXRange),
        ("testYRange", testYRange),
    ]
}

extension DiskTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__DiskTests = [
        ("testFlip", testFlip),
        ("testFlipped", testFlipped),
    ]
}

extension GameTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__GameTests = [
        ("testInit", testInit),
        ("testPlaceDiskAt", testPlaceDiskAt),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BoardTests.__allTests__BoardTests),
        testCase(DiskTests.__allTests__DiskTests),
        testCase(GameTests.__allTests__GameTests),
    ]
}
#endif
