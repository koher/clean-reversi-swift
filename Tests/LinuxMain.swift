import XCTest

import CleanReversiAppTests
import CleanReversiAsyncTests
import CleanReversiTests

var tests = [XCTestCaseEntry]()
tests += CleanReversiAppTests.__allTests()
tests += CleanReversiAsyncTests.__allTests()
tests += CleanReversiTests.__allTests()

XCTMain(tests)
