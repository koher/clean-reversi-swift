import XCTest
import CleanReversi

final class DiskTests: XCTestCase {
    func testFlip() {
        do {
            var disk: Disk = .dark
            disk.flip()
            XCTAssertEqual(disk, .light)
        }
        
        do {
            var disk: Disk = .light
            disk.flip()
            XCTAssertEqual(disk, .dark)
        }
    }
    
    func testFlipped() {
        do {
            let disk: Disk = .dark
            XCTAssertEqual(disk.flipped, .light)
        }
        
        do {
            let disk: Disk = .light
            XCTAssertEqual(disk.flipped, .dark)
        }
    }
}
