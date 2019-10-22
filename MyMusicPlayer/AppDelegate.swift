//
//  AppDelegate.swift
//  MyMusicPlayer
//
//  Created by Jinwoo Kim on 11/02/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import UIKit

import SwiftyBeaver

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let console = ConsoleDestination()
        log.addDestination(console)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        guard let window = window else { return false }
        
        window.rootViewController = MusicPlayerViewController()
        window.makeKeyAndVisible()
        
        return true
    }
}

