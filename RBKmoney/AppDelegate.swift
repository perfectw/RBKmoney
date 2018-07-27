//
//  AppDelegate.swift
//  RBKmoney
//
//  Created by Roman Spirichkin on 6/15/18.
//  Copyright © 2018 P-W. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		AnnualCycle().run()
		return true
	}

}
