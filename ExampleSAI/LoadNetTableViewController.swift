//
//  LoadNetTableViewController.swift
//  ExampleSAI
//
//  Created by Karol Sladecek on 07/05/2017.
//  Copyright © 2017 Orátu, s.r.o. All rights reserved.
//

import UIKit
import ExamplesSAIIrrelevant
import SAI

/*
 This is the view controller responsible for displaying a table of available (stored) networks that can be loaded.
 It is displayed by taping the „Load“ button. It is also responsible for loading the network when a row is selected.
 
 The parent AbstractLoadNetTableViewController implements few basic steps not relevant to the SAI framework:
 1. Get a list of files from the document directory of this app
 2. Display the list of files in an UITableView
 3. When selecting a row, the URL for the specific row is used to call the loadNetworkFromUrl(_ url: URL) method
 4. When the method returns a not nil result, an exit segue is triggered.
*/
class LoadNetTableViewController: AbstractLoadNetTableViewController {
    
    private(set) public var network:Network?

    /*
     Upon selecting a table row with a file url, this method is called to load an network from the URL.
     When the network successfully loads (i.e. the result of loadNetworkFromUrl(url: url) is not nil) the loaded network
     is assigned to a member variable in this view controller and an exit segue is triggered to return to previous screen.
     On the previous screen the exit segue is handled and the network from this view controller is used for further purposes.
     */
    override func loadNetworkFromUrl(_ url: URL) {
        //Loading a net from an url is as simple as this.
        //The returning network can then be cast to a specific class.
        if let net = SAIStorageService.loadNet(url: url) {
            self.network = net
            switch self.subdir ?? "" {
            case MLP_NET_SUBDIR:
                self.performSegue(withIdentifier: "BackToClassificationSegue", sender: nil)
            case ELMAN_RNN_NET_SUBDIR:
                self.performSegue(withIdentifier: "BackToTypingSegue", sender: nil)
            default:
                break
            }
        }
    }
    
}
