//
//  ScribeViewController.swift
//  ExampleSAI
//
//  Created by Karol Sladecek on 16/05/2017.
//  Copyright © 2017 Orátu, s.r.o. All rights reserved.
//

import UIKit
import SAI
import ExamplesSAIIrrelevant


class ScribeViewController: AbstractScribeViewController {



    /*
     The variable „network“ is set on the previous screen in the „override func prepare(for segue: UIStoryboardSegue, sender: Any?)“ method
     with the current network (loaded or created). This network is the used to classify image from the scribe view.
     */
    var network:FeedForwardNetwork?


    override func evaluateImage(_ image: UIImage) -> (guess: Int, probability: Float) {
        guard let net = self.network else {return (0,0)}
        let numberOfInputs = net.numberOfInputs
        //we nedd to scale the image to have the desired input count i.e. number of pixels
        let width = CGFloat(sqrt(Double(numberOfInputs)))
        guard let resizedImage = image.grayscaleImageWithSize(CGSize(width: width, height: width)), let imageInputLayer = UIImageInputLayer(image: resizedImage), imageInputLayer.numberOfOutputs == numberOfInputs else {return (0,0)}

        //evaluate the image and get the array of outputs (first item is the probability of the image being the digit 0 ...and so on... the
        //last item is the probability of the image being a 9)
        let array = net.evaluate(inputLayer: imageInputLayer).outputs

        //as the result we take the index of the highest probability
        let probability = array.max() ?? -1.0
        let result = array.index(of: probability ) ?? -1

        return (result, probability)
    }

}

