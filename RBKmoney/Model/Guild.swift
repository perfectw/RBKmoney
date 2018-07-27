//
//  Guild.swift
//  RBKmoney
//
//  Created by Roman Spirichkin on 6/23/18.
//  Copyright © 2018 P-W. All rights reserved.
//

import Foundation

final class Guild {
	private enum Const {
		static let tradesInitCount = 12 // 60
		static let tradesRotationsPercentage = 20
		static let sameTradersDealsMaxCount = 10
		static let sameTradersDealsMinCount = 5
	}

	private var allTraders: [Trader]
	private var allDeals = [Deal]()

	init(count: Int = Const.tradesInitCount) {
		allTraders = TradersFabric.newVariousTraders(count: count)
	}

	var tradersKindsShares: [String] {
		return allTraders.map { "\($0)".components(separatedBy: " ").first?.components(separatedBy: "(").last ?? "UnknownTrader" }
	}

	func runAnnualCycle() {
		allDeals.removeAll()
		allTraders.forEach { $0.reset(inGuild: self) }
		makeNewDeals()
		doTradersRotations()
	}

	private func makeNewDeals() {
		guard allTraders.count > 1 else { return }
		for i in 0 ..< allTraders.count - 1 {
			let secondIndexInit = i + 1
			for j in secondIndexInit ..< allTraders.count {
				var dealsCount = Const.sameTradersDealsMinCount + (Const.sameTradersDealsMaxCount - Const.sameTradersDealsMinCount).random
				while dealsCount > 0 {
					let newDeal = Deal(participant1: allTraders[i], participant2: allTraders[j])
					allDeals.append(newDeal)
					dealsCount.decrement()
				}
			}
		}
	}

	private func doTradersRotations() {
		let incomes = allTraders.reduce(into: [Trader: Int]()) {
			$0[$1] = $1.annualIncome(inGuild: self)
			}.sorted(by: { $0.value > $1.value })
		let refreshCount = allTraders.count * Const.tradesRotationsPercentage / 100
		for i in 0 ... refreshCount {
			let topTrader = incomes[i].key
			let newTarder = TradersFabric.newTrader(likeTrader: topTrader)
			let oldTrader = incomes[allTraders.count - 1 - i].key
			guard let rotationIndex = allTraders.index(of: oldTrader) else { continue }
			allTraders[rotationIndex] = newTarder
		}
	}
}
