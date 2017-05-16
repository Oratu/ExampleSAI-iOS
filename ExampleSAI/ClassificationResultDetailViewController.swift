//
//  ClassifycationResultDetailViewController.swift
//  ExampleSAI
//
//  Created by Karol Sladecek on 03/05/2017.
//  Copyright © 2017 Orátu, s.r.o. All rights reserved.
//

import UIKit
import ExamplesSAIIrrelevant


/*
 The parent AbstractClassificationResultDetailViewController implements few basic steps not relevant to the SAI framework.
 Based on the values set in the „result“ member variable it displays:
 1. Image that has been used as input (based on „result.path“
 2. Label with the expected number we would like as the result (based on „result.expected“
 3. UITable with 10 rows where it displays the probabilities for each possible digit. (based on „result.probabilities“
 */
class ClassificationResultDetailViewController: AbstractClassificationResultDetailViewController {

    /*
     The variable „result“ is set on the previous screen in the „override func prepare(for segue: UIStoryboardSegue, sender: Any?)“ method
     Based on the selected cell (i.e. image we want to see detail for). The override here is just to show what the view controller uses to
     present the ui elements
     */
    override var result:(expected:String, actual:String, path:String, probabilities:[Float:Int])? {
        get {return super.result}
        set {super.result = newValue}
    }
    
}
