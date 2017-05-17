//
//  String.swift
//  Pods
//
//  Created by Erik Sargent on 5/17/17.
//
//

import Foundation


extension String {
	public var toCamel: String {
		let comps = self.components(separatedBy: "_")
		let notFirst = comps.dropFirst()
		
		guard !comps.isEmpty else {
			return ""
		}
		
		var value = comps.first!
		
		notFirst.forEach { comp in
			value += comp.capitalized
		}
		
		return value
	}
	
	public var toSnake: String {
		var value = self
		
		while true {
			if let range = value.rangeOfCharacter(from: .uppercaseLetters) {
				var letter = value.substring(with: range).lowercased()
				if value.distance(from: value.startIndex, to: range.lowerBound) > 0 && !value.substring(with: value.index(before: range.lowerBound)..<range.upperBound).contains("_") {
					letter = "_" + letter
				}
				value.replaceSubrange(range, with: letter)
			} else {
				break
			}
		}
		
		return value
	}
	
	public var isDate: Bool {
		guard let regex = try? NSRegularExpression(pattern: "^\\d{1,4}-\\d{1,2}-\\d{1,2}$", options: []) else {
			return false
		}
		
		let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.characters.count))
		
		return matches.count > 0
	}
	
	public var isDateTime: Bool {
		guard let regex = try? NSRegularExpression(pattern: "^\\d{1,4}-\\d{1,2}-\\d{1,2}T\\d\\d:\\d\\d:\\d\\d(Z|-\\d\\d\\d\\d)?$", options: []) else {
			return false
		}
		
		let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.characters.count))
		
		return matches.count > 0
	}
}
