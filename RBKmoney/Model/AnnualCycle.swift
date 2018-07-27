//
//  AnnualCycle.swift
//  RBKmoney
//
//  Created by Roman Spirichkin on 7/27/18.
//  Copyright © 2018 P-W. All rights reserved.
//

import Foundation

final class AnnualCycle {
	static let shared = AnnualCycle()
	
	func run() {
		for _ in 0 ..< 10 {
			let guild = Guild()
			for i in 0 ..< 100 {
				//			print(i)
				guild.runAnnualCycle()
			}
			let tradersKindsShares = guild.tradersKindsShares
			guard let result = mostFrequent(array: tradersKindsShares) else {
				return assertionFailure()
			}
			print("Winners' kind is: \(result.value)")
		}
	}
}
