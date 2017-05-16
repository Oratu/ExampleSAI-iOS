//
//  ClassifycationResultsViewController.swift
//  ExampleSAI
//
//  Created by Karol Sladecek on 02/05/2017.
//  Copyright © 2017 Orátu, s.r.o. All rights reserved.
//

import UIKit
import ExamplesSAIIrrelevant
import SAI


/*
 The parent AbstractClassificationResultsViewController implements few basic steps not relevant to the SAI framework.
 1. The View controller creates a list of all images in Data/mnist_png/testing
 2. This list is used as a datasource for the UICollectionView where each cell represents an image
 3. In the „func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)“ method 
    the „classify(image:UIImage, expectedResult:Int) -> (result:Int, probabilities:[Float:Int])?“ method is called
    for each cell, with the input of the image that will be displayed.
 4. Based result of the classification the cell is setup either with a red square if the classification result
    did not match the expected result, or a green one if it matches
 */
class ClassificationResultsViewController: AbstractClassificationResultsViewController {
    
    /*
     The variable „network“ is set on the previous screen in the „override func prepare(for segue: UIStoryboardSegue, sender: Any?)“ method
     with the current network (loaded or created). This network is the used to classify all the images supplied to the collection view.
     */
    var network:FeedForwardNetwork?

    /*
     When we want to move to the ClassificationResultDetailViewController screen we set
     the classification result for the taped cell to the destination view controller.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UICollectionViewCell, let r = self.classificationResultForCell(cell), let dvc = segue.destination as? ClassificationResultDetailViewController {
            dvc.result = r
        }
        super.prepare(for: segue, sender: sender)
    }
    
    /*
     In the „func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)“ method of the parent class
     the „classify(image:UIImage, expectedResult:Int) -> (result:Int, probabilities:[Float:Int])?“ method is called
     for each cell, with the input of the image that will be displayed.
     Here we simply take the image and evaluate it using the current network. Result of our function is:
     1. „result“ which is an Int from 0 to 9 and represents the most probable digit in the image according to our network
     2. „probabilities“ is a map of probabilities of each digit, it is used in the ClassificationResultDetailViewController
        to show the table of probabilities for individual digits. The keys (probabilities) are ordered, and then the representing digit
        (value of the dictionary) is displayed in a table row.
     */
    open override func classify(image:UIImage) -> (result:Int, probabilities:[Float:Int])? {
        //ensure the network is set and an UIImageInputLayer can be created from the image
        guard let net = self.network, let inputLayer = UIImageInputLayer(image: image) else { return nil }

        //evaluate the image and get the array of outputs (first item is the probability of the image being the digit 0 ...and so on... the
        //last item is the probability of the image being a 9)
        let array = net.evaluate(inputLayer: inputLayer).outputs

        //as the result we take the index of the highest probability
        let result = array.index(of: array.max() ?? -10.0) ?? -1

        //we create a reverse map where we can map probabilities to it's digits
        var map = [Float:Int]()
        for (i, k) in array.enumerated() {
            map[k] = i
        }
        return (result, map)
        //The keys (probabilities) are ordered in the ClassificationResultDetailViewController, and then the representing digit
        //(value of the dictionary) is displayed in a table row.
    }
}
