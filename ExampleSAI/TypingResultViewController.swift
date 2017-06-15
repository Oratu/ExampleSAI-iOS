//
//  TypingResultViewController.swift
//  ExampleSAI
//
//  Created by Karol Sladecek on 01/06/2017.
//  Copyright © 2017 Orátu, s.r.o. All rights reserved.
//

import UIKit
import ExamplesSAIIrrelevant
import SAI


/*
 The parent AbstractTypingResultViewController implements few basic steps not relevant to the SAI framework.
 1. Fills the scrollable UITextView with the sample text that the network is trained with
 2. Handles changes in the input fields and parses the entered text into words
 3. Updates the predicted text based on the text returned by the „predictForText(textTokens:)“ method overridden here
 4. Highlights words in the UITextView
 */
class TypingResultViewController: AbstractTypingResultViewController {
    
    /*
     The variable „network“ is set on the previous screen in the „override func prepare(for segue: UIStoryboardSegue, sender: Any?)“ method
     with the current network (loaded or created). This network is the used to predict text based on users input.
     */
    var network:FeedForwardNetwork?

    /*
     The variable „inputLayer“ is set on the previous screen in the „override func prepare(for segue: UIStoryboardSegue, sender: Any?)“ method
     with the current training layer. This layer is the used to map the string inputs to hot vectors and outputs of the network back to words.
     */
    var inputLayer:SentenceInputLayer?

    /*
     This method is called by the super class when the user input changes.
     We receive the entered inputs as separate words and have to use them to predict the next sequence.
     */
    override func predictForText(_ textTokens: [String]) -> [String] {
        guard let net = self.network, let inputLayer = self.inputLayer, textTokens.count > 0 else {
            return [String]()
        }
        var newInput = textTokens.map( {inputLayer.wordToHotVector(word: $0)}) //convert the text tokens we got to hot vectors for the net to understand
        var sentence = newInput.map({inputLayer.hotVectorToWord(vector: $0)}) //convert the hot vectors back to words (this will change all unknown input words to  „unknown tokens“
        let outputWordLimit = 12 //limit the number of words we predict (this includes the already typed words)
        let maxEvalSequence = 8 //limit the input sequence fed to the network, if the limit is achieved, the first words are left out and new are added ad the end for the next word prediction
        repeat {
            //predict new output
            guard let outputLayer = net.evaluate(inputLayer: RecurrentInputLayer(producingOutputs: newInput)) as? RecurrentElmanOutputLayer, (outputLayer.outputs as! [[Float]]).count > 0 else {
                return [String]()
            }
            //take only the last word which should be the new word based on the input
            if let lastWord = outputLayer.outputsAsOneHot().last {
                //if the last word is the sentence end token, just add a dot at the end, otherwise decode the word and add it to the sentence
                let stringWord = inputLayer.isSentenceEnd(vector: lastWord) ? "." : inputLayer.hotVectorToWord(vector: lastWord) 
                sentence.append(stringWord) //append the last word to our output sequence
                newInput.append(lastWord) //use the last word as new input for the net by appending it to the users input
            }
            if newInput.count >= maxEvalSequence {
                newInput.removeFirst() //if the input sequence becomes too long, start to trim first words of the input sentence
            }
        } while sentence.count <= outputWordLimit && !inputLayer.isSentenceEnd(vector: newInput.last!) //we repeat this until we have enough words for our prediction
        return sentence
    }

}
