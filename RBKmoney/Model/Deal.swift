//
//  Deal.swift
//  RBKmoney
//
//  Created by Roman Spirichkin on 6/22/18.
//  Copyright © 2018 P-W. All rights reserved.
//

import Foundation

// MARK: - DealParticipant

protocol DealParticipant: class {
	var dealBehavior: Deal.Behavior { get }
	func keep(newDeal deal: Deal)
}

// MARK: - Deal

final class Deal {
	enum IncomeResult: Int {
		case allFair = 4
		case allDirty = 2
		case sendExclusiveDirty = 5
		case receiveExclusiveDirty = 1
	}

	enum Behavior {
		case cooperate
		case cheat
	}

	private enum Kind {
		case allCooperate
		case allCheat
		case onlyOneCheat(first: Bool)

		init(behavior1: Behavior, behavior2: Behavior) {
			guard behavior1 == behavior2 else {
				self = .onlyOneCheat(first: behavior1 == .cheat)
				return
			}
			self = behavior1 == .cheat ? .allCheat: .allCooperate
		}
	}

	private unowned let firstParticipant: DealParticipant
	private let kind: Kind

	init(participant1: DealParticipant, participant2: DealParticipant) {
		assert(participant1 !== participant2, "a participant can't make deals with himself")
		self.firstParticipant = participant1
		self.kind = Kind(behavior1: participant1.dealBehavior, behavior2: participant2.dealBehavior)
		participant1.keep(newDeal: self)
		participant2.keep(newDeal: self)
	}

	func result(forParticipant participant: DealParticipant) -> IncomeResult {
		switch kind {
		case .allCooperate:
			return .allFair
		case .allCheat:
			return .allDirty
		case .onlyOneCheat(let isFirst):
			return (isFirst && participant === firstParticipant) ? .sendExclusiveDirty: .receiveExclusiveDirty
		}
	}
}
