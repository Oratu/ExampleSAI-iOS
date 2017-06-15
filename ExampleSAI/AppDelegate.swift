//
//  AppDelegate.swift
//  ExampleSAI
//
//  Created by Karol Sladecek on 23/04/2017.
//  Copyright © 2017 Orátu, s.r.o. All rights reserved.
//

import UIKit
import ExamplesSAIIrrelevant

internal let MLP_NET_SUBDIR = "mlp"
internal let ELMAN_RNN_NET_SUBDIR = "rnn-elman"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func applicationDidFinishLaunching(_ application: UIApplication) {
        // following code is irrelevant to the SAI framework, it just copies a sample network to the example app's documents directory
        // if it doesn't already exist there.
        if let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // check MLP sample net
            let mlpSampleNetworkUrl = documentsUrl.appendingPathComponent(MLP_NET_SUBDIR).appendingPathComponent("A well trained mlp.json")
            if !FileManager.default.fileExists(atPath: mlpSampleNetworkUrl.path) {
                let _ = try? FileManager.default.createDirectory(at: mlpSampleNetworkUrl.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                if let defaultNetPath = Bundle(for: InitialViewController.self).url(forResource: "A well trained mlp", withExtension: "json") {
                    let _ = try? FileManager.default.copyItem(at: defaultNetPath, to: mlpSampleNetworkUrl)
                }
            }

            // check elman rnn sample net            
            let ernnSampleNetworkUrl = documentsUrl.appendingPathComponent(ELMAN_RNN_NET_SUBDIR).appendingPathComponent("A well trained ernn.json")
            if !FileManager.default.fileExists(atPath: ernnSampleNetworkUrl.path) {
                let _ = try? FileManager.default.createDirectory(at: ernnSampleNetworkUrl.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                if let defaultNetPath = Bundle(for: InitialViewController.self).url(forResource: "A well trained ernn", withExtension: "json") {
                    let _ = try? FileManager.default.copyItem(at: defaultNetPath, to: ernnSampleNetworkUrl)
                }
            }
        }
    }
}

