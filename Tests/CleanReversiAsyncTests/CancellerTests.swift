import XCTest
import CleanReversiAsync

class CancellerTests: XCTestCase {
    func testCancel() {
        var count = 0
        let canceller = Canceller { count += 1 }
        
        XCTAssertFalse(canceller.isCancelled)
        XCTAssertEqual(count, 0)
        
        canceller.cancel()
        XCTAssertTrue(canceller.isCancelled)
        XCTAssertEqual(count, 1)

        // Checks cancel operations are executed only once
        canceller.cancel()
        XCTAssertTrue(canceller.isCancelled)
        XCTAssertEqual(count, 1)
    }
    
    func testAddSubcanceller() {
        var count = 0
        var subcount1 = 0
        var subcount2 = 0
        let canceller = Canceller { count += 1 }
        let subcanceller1 = Canceller { subcount1 += 10 }
        let subcanceller2 = Canceller { subcount2 += 100 }
        canceller.addSubcanceller(subcanceller1)
        canceller.addSubcanceller(subcanceller2)

        XCTAssertFalse(canceller.isCancelled)
        XCTAssertFalse(subcanceller1.isCancelled)
        XCTAssertFalse(subcanceller2.isCancelled)
        XCTAssertEqual(count, 0)
        XCTAssertEqual(subcount1, 0)
        XCTAssertEqual(subcount2, 0)

        canceller.cancel()
        XCTAssertTrue(canceller.isCancelled)
        XCTAssertTrue(subcanceller1.isCancelled)
        XCTAssertTrue(subcanceller2.isCancelled)
        XCTAssertEqual(count, 1)
        XCTAssertEqual(subcount1, 10)
        XCTAssertEqual(subcount2, 100)

        // Checks cancel operations are executed only once
        canceller.cancel()
        XCTAssertTrue(canceller.isCancelled)
        XCTAssertTrue(subcanceller1.isCancelled)
        XCTAssertTrue(subcanceller2.isCancelled)
        XCTAssertEqual(count, 1)
        XCTAssertEqual(subcount1, 10)
        XCTAssertEqual(subcount2, 100)
        
        // Adding after `canceller` is cancelled
        var subcount3 = 0
        let subcanceller3 = Canceller { subcount3 += 1000 }
        canceller.addSubcanceller(subcanceller3)
        canceller.cancel()
        XCTAssertFalse(subcanceller3.isCancelled)
        XCTAssertEqual(subcount3, 0)
    }
}
