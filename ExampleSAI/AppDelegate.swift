//
//  AppDelegate.swift
//  ExampleSAI
//
//  Created by Karol Sladecek on 23/04/2017.
//  Copyright © 2017 Orátu, s.r.o. All rights reserved.
//

import UIKit
import ExamplesSAIIrrelevant

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func applicationDidFinishLaunching(_ application: UIApplication) {
        // following code is irrelevant to the SAI framework, it just copies a sample network to the example app's documents directory
        // if it doesn't already exist there.
        if let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let sampleNetworkUrl = documentsUrl.appendingPathComponent("A well trained net.json")
            if !FileManager.default.fileExists(atPath: sampleNetworkUrl.path) {
                if let defaultNetPath = Bundle(for: InitialViewController.self).url(forResource: "A well trained net", withExtension: "json") {
                    let _ = try? FileManager.default.copyItem(at: defaultNetPath, to: sampleNetworkUrl)
                }
            }
        }
    }
}

