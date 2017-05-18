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
        return unicodeScalars.reduce("") {
            if let last = $0.unicodeScalars.last, CharacterSet.uppercaseLetters.union(CharacterSet.decimalDigits).contains($1) && last != "_" {
                if CharacterSet.decimalDigits.contains(last) && CharacterSet.decimalDigits.contains($1) {
                    return $0 + String($1)
                } else {
                    return $0 + "_" + String($1).lowercased()
                }
            } else {
                return $0 + String($1).lowercased()
            }
        }
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
