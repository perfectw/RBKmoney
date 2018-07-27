//
//  Trader.swift
//  RBKmoney
//
//  Created by Roman Spirichkin on 6/22/18.
//  Copyright © 2018 P-W. All rights reserved.
//

import Foundation

// MARK: - BASE TRADER

class Trader {
	fileprivate enum Kind: Int { // TODO: CaseIterable in Swift 4.2
		case altruist
		case threw
		case fox
		case haphazard
		case revenge
		case quirk
		case error

		var initBehavior: Deal.Behavior {
			switch self {
			case .altruist, .fox, .revenge, .quirk:
				return .cooperate
			case .threw:
				return .cheat
			case .haphazard:
				return 1.random == 1 ? .cooperate: .cheat
			case .error:
				fatalError("overridable of ancestral trader's KIND is required")
			}
		}

		static let allCasesCount: Int = {
			var index = 0
			while let _ = Kind(rawValue: index) { index += 1 }
			return index - 1
		}()
	}

	fileprivate class var kind: Kind {
		return .error
	}

	fileprivate(set) var nextBehavior: Deal.Behavior
	private let id: Int // for simple identification
	private var deals = [Deal]()

	fileprivate init(id: Int) {
		self.nextBehavior = type(of: self).kind.initBehavior
		self.id = id
	}

	fileprivate func updateBehavior(byIncomeResult result: Deal.IncomeResult) {}

	func annualIncome(inGuild: Guild) -> Int {
		return deals.reduce(0) { $0 + $1.result(forParticipant: self).rawValue }
	}

	func reset(inGuild: Guild) {
		self.nextBehavior = type(of: self).kind.initBehavior
		deals.removeAll()
	}
}

// MARK: - Hashable

extension Trader: Hashable {
	var hashValue: Int {
		return id.hashValue
	}

	static func == (lhs: Trader, rhs: Trader) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}

// MARK: - DealPartisepent

extension Trader: DealParticipant {
	static let mistakesPossibility = 5

	var dealBehavior: Deal.Behavior {
		guard 99.random < Trader.mistakesPossibility else { return nextBehavior }
		return nextBehavior.reversed()
	}

	func keep(newDeal deal: Deal) {
		assert(!deals.contains(where: { $0 === deal}), "do not keep duplicates")
		let result = deal.result(forParticipant: self)
		updateBehavior(byIncomeResult: result)
		deals.append(deal)
	}
}

// MARK: - All TRADER'S CLASSES

// MARK: AltruistTrader

private final class AltruistTrader: Trader {
	override fileprivate class var kind: Kind {
		return .altruist
	}
}

// MARK: ThrewTrader

private final class ThrewTrader: Trader {
	override fileprivate class var kind: Kind {
		return .threw
	}
}

// MARK: FoxTrader

private final class FoxTrader: Trader {
	override fileprivate class var kind: Kind {
		return .fox
	}

	override fileprivate func updateBehavior(byIncomeResult result: Deal.IncomeResult) {
		switch result {
		case .allFair, .sendExclusiveDirty:
			nextBehavior = .cooperate
		case .allDirty, .receiveExclusiveDirty:
			nextBehavior = .cheat
		}
	}
}

// MARK: HaphazardTrader

private final class HaphazardTrader: Trader {
	override fileprivate class var kind: Kind {
		return .haphazard
	}

	override fileprivate func updateBehavior(byIncomeResult result: Deal.IncomeResult) {
		nextBehavior = HaphazardTrader.kind.initBehavior
	}
}

// MARK: RevengeTrader

private final class RevengeTrader: Trader {
	override fileprivate class var kind: Kind {
		return .revenge
	}

	override fileprivate func updateBehavior(byIncomeResult result: Deal.IncomeResult) {
		if result == .receiveExclusiveDirty {
			nextBehavior = .cheat
		}
	}
}

// MARK: QuirkTrader

private final class QuirkTrader: Trader {
	override fileprivate class var kind: Kind {
		return .quirk
	}

	private static let maxIndependentDealsCount = 3
	private var wereAllIndependentDeals = false
	private var dealsIncomeResults: [Deal.IncomeResult] = []

	override fileprivate func updateBehavior(byIncomeResult result: Deal.IncomeResult) {
		guard !wereAllIndependentDeals else { return }
		dealsIncomeResults.append(result)
		guard dealsIncomeResults.count != QuirkTrader.maxIndependentDealsCount else {
			let wasDirty = dealsIncomeResults.contains(where: { $0 == .allDirty || $0 == .receiveExclusiveDirty })
			nextBehavior = wasDirty ? .cheat : .cooperate
			wereAllIndependentDeals = true
			dealsIncomeResults.removeAll()
			return
		}
		nextBehavior = dealsIncomeResults.count == 1 ? .cheat : .cooperate
	}
}

// MARK: - FABRIC

final class TradersFabric {
	private static let shared = TradersFabric()
	private var traderID = 0

	static func newVariousTraders(count: Int) -> [Trader] {
		assert(count % Trader.Kind.allCasesCount == 0, "every traders' kinds must have the same initial count")
		return Array(0 ..< count).compactMap {
			let index = $0 % Trader.Kind.allCasesCount
			guard let kind = Trader.Kind(rawValue: index) else { return nil }
			return shared.newTrader(ofKind: kind)
		}
	}

	static func newTrader(likeTrader trader: Trader) -> Trader {
		return shared.newTrader(ofKind: type(of: trader).kind)
	}

	private func newTrader(ofKind kind: Trader.Kind) -> Trader {
		defer {
			traderID.increment()
		}
		switch kind {
		case .altruist:
			return AltruistTrader(id: traderID)
		case .threw:
			return ThrewTrader(id: traderID)
		case .fox:
			return FoxTrader(id: traderID)
		case .haphazard:
			return HaphazardTrader(id: traderID)
		case .revenge:
			return RevengeTrader(id: traderID)
		case .quirk:
			return QuirkTrader(id: traderID)
		case .error:
			return Trader(id: traderID)
		}
	}
}

// MARK: - EXTENSIONS

extension Deal.Behavior {
	func reversed() -> Deal.Behavior {
		return self == .cheat ? .cooperate : .cheat
	}
}
