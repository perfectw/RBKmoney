//
//  Common.swift
//  RBKmoney
//
//  Created by Roman Spirichkin on 6/17/18.
//  Copyright © 2018 P-W. All rights reserved.
//

import Foundation

extension Int {
	var random: Int {
		return Int(arc4random_uniform(UInt32(self)))
	}

	mutating func increment() {
		self += 1
	}
	mutating func decrement() {
		self -= 1
	}
}

func mostFrequent<T: Hashable>(array: [T]) -> (value: T, count: Int)? {
	let counts = array.reduce(into: [:]) { $0[$1, default: 0] += 1 }
	if let (value, count) = counts.max(by: { $0.1 < $1.1 }) {
		return (value, count)
	}
	return nil
}
