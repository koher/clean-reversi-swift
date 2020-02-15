import XCTest

import CleanReversiAppTests
import CleanReversiTests

var tests = [XCTestCaseEntry]()
tests += CleanReversiAppTests.__allTests()
tests += CleanReversiTests.__allTests()

XCTMain(tests)
