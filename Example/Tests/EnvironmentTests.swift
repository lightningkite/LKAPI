//
//  EnvironmentTests.swift
//  LKAPI
//
//  Created by Erik Sargent on 5/2/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
import LKAPI

class Tests: XCTestCase {
	func testLoadingPlist() {
		XCTAssertTrue(Environment.environmentDict.keys.count > 0)
	}
	
	func testDescription() {
		XCTAssertEqual(Environment.envDescription, "Testing")
	}
}

