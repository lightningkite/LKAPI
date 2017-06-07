//
//  ParsingTests.swift
//  LKAPI
//
//  Created by Erik Sargent on 8/22/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
import LKAPI

import Alamofire

class ParsingTests: XCTestCase {
	func testParseLiteralsFromDictionary() {
		let dict: ModelDict = [
			"int": 5,
			"bool": true,
			"double": 5.5,
			"string": "Hello world!"
		]
		
		XCTAssertEqual(dict.parse("int", or: 0), 5)
		XCTAssertEqual(dict.parse("bool", or: false), true)
		XCTAssertEqual(dict.parse("double", or: 0.0), 5.5)
		XCTAssertEqual(dict.parse("string", or: ""), "Hello world!")
	}
	
	func testParseEmptyLiteralsFromDictionary() {
		let dict: ModelDict = [:]
		
		XCTAssertEqual(dict.parse("int", or: 0), 0)
		XCTAssertEqual(dict.parse("bool", or: false), false)
		XCTAssertEqual(dict.parse("double", or: 0.0), 0.0)
		XCTAssertEqual(dict.parse("string", or: ""), "")
	}
	
	func testParseWithoutFallback() {
		let dict: ModelDict = [
			"int": 5,
			"bool": true,
			"double": 5.5,
			"string": "Hello world!"
		]
		
		XCTAssertEqual(dict.parse("int") ?? 0, 5)
		XCTAssertEqual(dict.parse("bool") ?? false, true)
		XCTAssertEqual(dict.parse("double") ?? 0.0, 5.5)
		XCTAssertEqual(dict.parse("string") ?? "", "Hello world!")
	}
	
	func testParseModelType() {
		struct Type: ModelType {
			let id: Int
			let name: String
			
			init(data: ModelDict) {
				id = data.parse("id", or: 0)
				name = data.parse("name", or: "")
			}
		}
		
		let dict: ModelDict = [
			"id": 3,
			"name": "Test"
		]
		
		let parsed: Type? = dict.parse()
		
		XCTAssertEqual(parsed?.id, 3)
		XCTAssertEqual(parsed?.name, "Test")
	}
	
	func testParseNestedModelType() {
		struct ObjectType: ModelType {
			let id: Int
			let name: String
			
			init(data: ModelDict) {
				id = data.parse("id", or: 0)
				name = data.parse("name", or: "")
			}
		}
		
		let dict: ModelDict = [
			"object": [
				"id": 3,
				"name": "Test"
			]
		]
		
		let parsed: ObjectType? = dict.parse(from: "object")
		
		XCTAssertEqual(parsed?.id, 3)
		XCTAssertEqual(parsed?.name, "Test")
	}
	
	func testParseParseableDate() {
		let dict: ModelDict = [
			"date": "2222-03-06"
		]
		
		let parsedDate = dict.parse(from: "date") as Date?
		
		XCTAssertNotNil(parsedDate)
		guard let date = parsedDate else {
			XCTFail()
			return
		}
		
		let calendar = NSCalendar(calendarIdentifier: .gregorian)
		let components = calendar?.components([.year, .month, .day], from: date)
		
		XCTAssertEqual(components?.year, 2222)
		XCTAssertEqual(components?.month, 3)
		XCTAssertEqual(components?.day, 6)
	}
	
	func testNestedModal() {
		let otherDict: ModelDict = [
			"id": 12
		]
		
		let dict: ModelDict = [
			"id": 3,
			"name": "Test",
			"otherModel": otherDict
		]
		
		struct Model: ModelType {
			let id: Int
			let name: String
			let other: OtherModel?
			
			init(data: ModelDict) {
				id = data.parse("id", or: 0)
				name = data.parse("name", or: "")
				other = data.parse(from: "otherModel") as OtherModel?
			}
		}
		
		struct OtherModel: ModelType {
			let id: Int
			
			init(data: ModelDict) {
				id = data.parse("id", or: 0)
			}
		}
		
		let data = dict.parse() as Model?
		
		XCTAssertNotNil(data)
		XCTAssertEqual(data?.id, 3)
		XCTAssertEqual(data?.name, "Test")
		XCTAssertNotNil(data?.other)
		XCTAssertEqual(data?.other?.id, 12)
	}
}

extension Date: Parseable {
	public static func parse(_ data: Any) -> Parseable? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		
		if let dateString = data as? String, let date = dateFormatter.date(from: dateString) {
			return date
		}
		
		return nil
	}
}
