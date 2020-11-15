//
//  ViewController.swift
//  hot dog classification
//
//  Created by Илья Дернов on 15.11.2020.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .savedPhotosAlbum
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("CIImage convert error")
            }
            if let results = detectPhoto(image: ciimage) {
                if let firstResult = results.first?.identifier {
                    self.displayResult(firstResult)
                }
            }
            
        }
        print("dismis")
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detectPhoto(image: CIImage) -> [VNClassificationObservation]? {
        guard let modelML: Resnet50 = try? Resnet50(configuration: MLModelConfiguration.init()) else {
            fatalError("ML model error error")
        }
        guard let model = try? VNCoreMLModel(for: modelML.model) else {
            fatalError("Core ML error")
        }
        var results: [VNClassificationObservation]? = nil
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let tempResult = request.results as? [VNClassificationObservation] else {
                fatalError("Error detection")
            }
            results = tempResult
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print("Error while ML request \(error)")
        }
        return results
    }
    
    func displayResult(_ result: String)
    {
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: "Image detect result", message: result, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: .default))
            self.present(alert, animated: true, completion: nil)
        })
    }

    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

