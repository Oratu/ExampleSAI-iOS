![](SAIFramework.png)

Swift Artificial Intelligence (SAI) framework aims to be an easy to use library for creating, training and evaluating artificial neural networks.

SAI aims to support multitude of platforms including MacOs, iOS and TvOS.

Read more on [saiframework.com](https://www.saiframework.com)

### Installation instructions for this example app

App expects the MNIST image dataset for training and classification of handwritten characters to be present under `Data/mnist_png` (with training and testing subdirectories). You can download the dataset [here](https://www.dropbox.com/s/7k2hh0vo660pnt1/mnist_png14.zip?dl=1).

If you don't download and expand the dataset, the Xcode build process will try it to do automatically so the first build of the app might take longer.

### Quick sample code
```swift
let hiddenLayer = PerceptronHiddenLayer(numberOfInputs: 14*14,
                                        neuronCount: 66,
                                        neuronType: BasicDeepNeuron.self)
let outputLayer = PerceptronOutputLayer(numberOfInputs: hiddenLayer.numberOfOutputs,
                                        neuronCount: 10,
                                        neuronType: BasicOutputNeuron.self)

guard let trainingInputLayer = UIImageTrainingInputLayer(samples: samples) else {return}
guard let network = BasicTrainableFeedForwardNetwork(trainingLayer: trainingInputLayer,
                                                    outputLayer: outputLayer,
                                                    hiddenLayers: [hiddenLayer]) else {return}

network.train(count: 1000,
           stop: nil,
           trainingSetSampleCompletion: nil,
           trainingSetCompletion: nil,
           completion: { finished, avgError in
                //training finished
            })

let inputLayer = UIImageInputLayer(image: image)
let array = net.evaluate(inputLayer: inputLayer).outputs

//as the result we take the index of the highest probability
let result = array.index(of: array.max() ?? -10.0) ?? -1
```

### Currently implemented in SAI
- Multilayer perceptron