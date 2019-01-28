//
//  AppDelegate.swift
//  SimpleVideoCreator
//
//  Created by Ted Kim on 2019-01-26.
//  Copyright © 2019 Ted Kim. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirestoreService.shared.configure()
    
    window = UIWindow(frame: UIScreen.main.bounds)
    window!.rootViewController = rootViewController()
    window!.makeKeyAndVisible()
    
    setupAppearance()
    
    return true
  }

  private func rootViewController() -> UINavigationController? {
    let navigationController = UINavigationController()
    let storyboard = UIStoryboard(name: "CreateVideoViewController", bundle: nil)
    let createViewController = storyboard.instantiateInitialViewController() as! CreateVideoViewController
    navigationController.viewControllers = [createViewController]
    return navigationController
  }
  
  private func setupAppearance() {
    UINavigationBar.appearance().tintColor = .white
    UINavigationBar.appearance().barTintColor = .clear
    UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
  }
  
}

