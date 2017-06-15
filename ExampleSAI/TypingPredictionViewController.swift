//
//  TypingPredictionViewController.swift
//  ExampleSAI
//
//  Created by Karol Sladecek on 23/04/2017.
//  Copyright © 2017 Orátu, s.r.o. All rights reserved.
//

import UIKit
import ExamplesSAIIrrelevant
import SAI

/*
 This is the view controller responsible creating a new network, training it and save it to a file.
 
 The parent AbstractTypingPredictionViewController implements few basic steps not relevant to the SAI framework:
 1. Provides text sample date for training
 2. Update the UI based on current application state
 3. Handles IBActions and forward calls like create and train network to this child class
 */
class TypingPredictionViewController: AbstractTypingPredictionViewController {
    
    /* the training layer we use to train the network */
    private var trainingInputLayer:SentenceInputLayer!
    
    /* we store the reference of the current network here (created or loaded)*/
    private var network:BasicTrainableFeedForwardNetwork? = nil
    
    /* here we store the average network error calculated during training */
    private var averageNetworkError:Float?
    
    /* this pointer to a boolean is used to stop an ongoing network training */
    override internal(set) open var stopTraining:UnsafeMutablePointer<Bool>? {
        get {return super.stopTraining}
        set {super.stopTraining = newValue}
    }

    
    /*
     When the create button is pressed, essentially this method is called. We create here all the layers
     required for a network to work
     */
    open override func createNet(numberOfRecurrentLayers:Int) {
        // we could crate a network also without a training layer but we would still need to know the number of inputs for the hidden layer
        // the training layer provides this information as it it created using a sample image from the training set
        // the number of inputs in the input/training layer is the number of distinct words in the training text
        guard let trainingInputLayer = self.createTrainingLayer() else {
            print("Error! Count not create the training layer")
            return
        }
        
        // when we have the number of inputs for the recurrent layer  and the number of recurrent layers  we can create the hidden Elman recurrent layer.
        // Optionally we can adjust the learning rate and/or activation function
        let recurrentHiddenLayer = RecurrentElmanHiddenLayer(
            numberOfInputs: trainingInputLayer.numberOfOutputs,
            numberOfCells: numberOfRecurrentLayers,
            learningRate: 0.01,
            bptt_truncate: 10
        )
        
        // we can create the output layer again knowing the number of inputs this layer will receive. Also we need to know how many
        // reccurent cells (hidden states) the hidden layer has. When we then evaluate the network we will get an array of floats as result
        // which will carry a value from 0.0 to 1.0 and will represent the probability of a word at that position in the vocabulary.
        // if the highest value from the array is on the first index, the network „thinks“ the next word is the one that is first in the vocabulary.
        // Optionally we can adjust the learning rate of the layer.
        let outputLayer = RecurrentElmanOutputLayer(
            numberOfInputs: trainingInputLayer.numberOfOutputs,
            numberOfCells: numberOfRecurrentLayers,
            learningRate: 0.01
        )

        // finally we can create the neural network using the training input layer, the output layer and the hidden layer we created above
        guard let network = BasicTrainableFeedForwardNetwork(
            trainingLayer:trainingInputLayer,
            outputLayer: outputLayer,
            hiddenLayers: [recurrentHiddenLayer]) else {
            print("Error! Count not create the network")
            return
        }
        
        // we store the reference to the created network here for future use (training, prediction, storage)
        self.network = network
        
        // we also initialize the average error member variable which will be recalculated once we start training the network
        self.averageNetworkError = nil
        
        // and last updating the user interface to show info about the created network (and enable/disable buttons)
        self.updateInterface()
    }

    /*
     To train a net we need a set of input sequences with matiching output sequences.
     This is what the SencenceInputLayer provides.
     We begin the training by calling the train(count: Int, stop: Bool...) method where we tell the network how many times the
     training set should be repeated (how many training rounds) and we provide a pointer to a boolean that if set to true will
     stop the training prematurely.
     */
    open override func trainNet(samples:String, repeating:Int) {
        //we need a neural network instance to be able to train so we guard here that a net was created or loaded
        guard let net = self.network else {return}
        
        //we stop the display sleep timer
        UIApplication.shared.isIdleTimerDisabled = true
        
        //to not block the main thread we dispatch the training to a different thread
        DispatchQueue.global().async {
            
            //setting the current action label to reflect current action
            self.setCurrentAction("Training…")
            self.setSampleProgressView.maxValue = net.trainingLayer?.datasetCount ?? 0
            //finally we begin to train the network
            net.train(count: repeating, stop: self.stopTraining,
                trainingSetSampleCompletion: { index in //one sample processed callback
                //this callback is called every time one sample of the provided training set has been used (one sentence pair)
                //update the sample progress view
                self.setSampleProgressView.currentValue = index + 1

            }, trainingSetCompletion: { index in //one training round finished callback
                //this callback is called when all samples from the provided training set have been completed (one training round)
                //update the round progress view
                self.setProgressView.currentValue = index + 1

                //update the average net error
                let stride = net.trainingLayer!.datasetCount/(net.trainingLayer!.datasetCount/10) //we only want to calculate from 10% of samples (to speed things up)
                self.setCurrentAction("Calculating avg. error…")
                net.calculateTrainingSetErrorRate(stride: stride, stop: nil, trainingSetSampleCompletion:  {index in
                    self.setSampleProgressView.currentValue = index + 1
                }, completion: { (finished, avgError) in
                    self.setSampleProgressView.currentValue = index + 1
                    self.averageNetworkError = (net.outputLayer as? RecurrentElmanOutputLayer)?.normalizeError(rawError: avgError).roundToSignificant(places:3)
                    self.setCurrentAction("Training…")
                })
                self.updateInterface()
            }, completion: { finished in
                //this callback is called when the training is completed.
                //the finished parameter is true if the training did complete by going thru all the samples the requested number of times.
                //It is false when the training was prematurely ended by setting the „stop“ boolean pointer to true.
                //Here we calculate the final error rate from all samples (can be stopped by pressing the stop button)
                self.stopTraining?.pointee = false
                self.setCurrentAction("Calculating avg. error…")
                net.calculateTrainingSetErrorRate(stride: 1, stop: self.stopTraining, trainingSetSampleCompletion: {index in
                    self.setSampleProgressView.currentValue = index + 1
                }, completion: { (finished, avgError) in
                    self.averageNetworkError = (net.outputLayer as? RecurrentElmanOutputLayer)?.normalizeError(rawError: avgError).roundToSignificant(places:3)
                    //we erase the stop training pointer (it's nil / not nil value is used to update the enabled state of some buttons by the parent class)
                    self.stopTraining = nil

                    //we update the interface (enabling/disabling buttons mostly)
                    self.updateInterface()

                    //we also enable the display sleep timer
                    UIApplication.shared.isIdleTimerDisabled = false

                    //and finally as nothing is going on at the moment we erase the current action label
                    self.setCurrentAction(nil)
                })

            })
        }
    }
    
    /*
     To save a network we will utilize the provided SAIStorageService which will serialize the
     network in to a JSON and return it as a pretty printed JSON string. We then use the name
     provided by the user to create a file in the app's document directory and save the string content in this file
     */
    open override func saveNet(name:String) {
        //we need a neural network instance to be able to save it so we guard here that a net was created or loaded
        guard let net = self.network else {return}
        
        //we get the string representing the network from the SAIStorageService
        guard let netString = SAIStorageService.saveNet(network: net) else {return}
        
        //finally we get the documents directory for the app and write the string into a file
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent(ELMAN_RNN_NET_SUBDIR)
            if !FileManager.default.fileExists(atPath: path.path) {
                let _ = try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
            }
            let _ = try? netString.write(to: path.appendingPathComponent("\(name).json"), atomically: false, encoding: .utf8)
        }
    }

    /*
     There we create an SentenceInputLayer for which we only need a path to a file containing some text or the text it's self as string.
     The max vocabulary parameter can limit the number of distinct words that will be used for the training. If the number of distinct words
     in the sample text is higher, the least frequent words will be replaced by an "unknown word" token.
     */
    private func createTrainingLayer() -> SentenceInputLayer? {
        //create the training layer using the sampleText provided.
        return SentenceInputLayer(string: self.loadTextSourceFile(), maxVocabularySize: 800, includeEndToken: true)
    }


    ////////////////////////////////////////////////////////////////////////////////////////////////
    //some less important staff happens here below, but might be relevant to understand the app flow
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    /*
     When we want to move to the TypingResultViewController screen we set
     the network to be used for the classification as the current network reference stored here.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? TypingResultViewController {
            // set the destination view controller „network“ member variable to the current network
            dvc.network = self.network
            // set the Sentence input layer which contains the coding of words to hot vectors and back
            dvc.inputLayer = self.network?.trainingLayer as? SentenceInputLayer
            //set the source text to serve as an inspiration for typing
            dvc.sourceText = self.loadTextSourceFile()
        } else if let dvc = segue.destination as? LoadNetTableViewController {
            dvc.subdir = ELMAN_RNN_NET_SUBDIR
        }
    }
    
    /*
     When we return to this screen from the Load network screen and the Load network screen did
     load a network we will use the network as the current network for all future actions (training, prediction, saving).
     */
    @IBAction func returnedLonadNetTyping(segue : UIStoryboardSegue, sender: Any?) {
        if let svc = segue.source as? LoadNetTableViewController, let n = svc.network as? BasicTrainableFeedForwardNetwork {
            // create a new training layer for the new network
            n.trainingLayer = self.createTrainingLayer()
            // store the reference to the load net here as the current network
            self.network = n
            //update user interface (handled by the parent class, enables/disables buttons etc...
            self.updateInterface()
        }
    }
    
    /*
     Used by the parent class to update the user interface (enables/disables buttons etc...)
     */
    open override func isNetworkInitialized() -> Bool {
        return self.network != nil
    }

    /*
     Used by the parent class to show info about the network on the screen...
     */
    open override func networkDescription() -> String? {
        guard let net = self.network, let hiddenLayer = net.hiddenLayers.first as? RecurrentElmanHiddenLayer else {
            return nil
        }
        let err = self.averageNetworkError == nil ? "Unknown" : "\(self.averageNetworkError!*100)%"
        return "Inputs: \(net.numberOfInputs), Recurrent layers: \(hiddenLayer.numberOfCells)\nAvg. net error: \(err)"
    }
}
