//
//  StringTests.swift
//  LKAPI
//
//  Created by Erik Sargent on 5/17/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest


class StringTests: XCTestCase {
	let camel = "thisIsWonderfulCamelCase"
	let snakedCamel = "this_is_wonderful_camel_case"
    let numberCamel = "thisAnd34Numbers"
    let snakedNumberCamel = "this_and_34_numbers"
	
	let SuperCamel = "ThisIsWonderfulCamelCase"
	let snakedSuperCamel = "this_is_wonderful_camel_case"
    let numberSnake = "this_is_34_and_some"
    let cameledNumberSnake = "thisIs34AndSome"
	
	let snake = "this_is_horrible_snake_case"
	let cameledSnake = "thisIsHorribleSnakeCase"
	
	let capitalSnake = "This_Is_Horrible_Snake_Case"
	let cameledCapitalSnake = "ThisIsHorribleSnakeCase"
	
	let spaced = "this is what we are used to"
	let blank = ""
	let emoji = "😀_😃"
	let cameledEmoji = "😀😃"
	
	let kata = "カ_ヌ"
	let cameledKata = "カヌ"
	
	let accented = "résumé"
	
	let date = "2017-04-03"
	let dateTime = "2017-5-4T02:40:90"
	let dateTimeZ = "2017-5-4T02:40:90Z"
	let dateTimeZone = "2017-5-4T02:40:90-0700"
	let dateGarbage = "2017-5-4stuff"
	let dateTimeGarbage = "2017-5-4T02:40:90Stuff"
	
	
	func testToCamel() {
		XCTAssertEqual(camel.toCamel, camel)
		XCTAssertEqual(SuperCamel.toCamel, SuperCamel)
		XCTAssertEqual(snake.toCamel, cameledSnake)
		XCTAssertEqual(capitalSnake.toCamel, cameledCapitalSnake)
		XCTAssertEqual(spaced.toCamel, spaced)
		XCTAssertEqual(blank.toCamel, blank)
		XCTAssertEqual(emoji.toCamel, cameledEmoji)
		XCTAssertEqual(kata.toCamel, cameledKata)
		XCTAssertEqual(accented.toCamel, accented)
        XCTAssertEqual(numberSnake.toCamel, cameledNumberSnake)
	}
	
	func testToSnake() {
		XCTAssertEqual(camel.toSnake, snakedCamel)
		XCTAssertEqual(SuperCamel.toSnake, snakedSuperCamel)
		XCTAssertEqual(snake.toSnake, snake)
		XCTAssertEqual(capitalSnake.toSnake, capitalSnake.lowercased())
		XCTAssertEqual(spaced.toSnake, spaced)
		XCTAssertEqual(blank.toSnake, blank)
		XCTAssertEqual(emoji.toSnake, emoji)
		XCTAssertEqual(kata.toSnake, kata)
		XCTAssertEqual(accented.toSnake, accented)
        XCTAssertEqual(numberCamel.toSnake, snakedNumberCamel)
	}
	
	func testIsDate() {
		XCTAssertTrue(date.isDate)
		XCTAssertFalse(dateTime.isDate)
		XCTAssertFalse(dateTimeZ.isDate)
		XCTAssertFalse(dateTimeZone.isDate)
		XCTAssertFalse(dateGarbage.isDate)
		XCTAssertFalse(dateTimeGarbage.isDate)
	}
	
	func testIsDateTime() {
		XCTAssertFalse(date.isDateTime)
		XCTAssertTrue(dateTime.isDateTime)
		XCTAssertTrue(dateTimeZ.isDateTime)
		XCTAssertTrue(dateTimeZone.isDateTime)
		XCTAssertFalse(dateGarbage.isDateTime)
		XCTAssertFalse(dateTimeGarbage.isDateTime)
	}
}
