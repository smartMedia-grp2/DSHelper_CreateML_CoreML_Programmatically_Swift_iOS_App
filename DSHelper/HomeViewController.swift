import UIKit
import AVFoundation
import VisionKit
import Vision

class HomeViewController: UIViewController {
    
    var classifierLabel = "Nothing was scanned"
    var scanned = false
    
    var captureSession = AVCaptureSession()
    var cameraImageView = UIImageView()
    
    lazy var classificationRequset: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: dsClassifier(configuration: MLModelConfiguration()).model)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self]
                request, error in
                self?.processClassifications(for: request, error: error)
            })
            return request
        } catch {
            fatalError("Fail to load ML model: \(error)")
        }
        print("classificationRequset OK")
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureLiveVideo()
        
        print("viewDidAppear OK")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HomeView()
        
        UserDefaults.standard.set(classifierLabel, forKey: "Key") //setObject
        
        let utterance = AVSpeechUtterance(string: "Welcome to DS Helper! Please scan information printed on dietary supplements. Welcome to DS Helper! Please scan information printed on dietary supplements.")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.25
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
        
        print("viewDidLoad OK")
    }
    
    func captureLiveVideo() {
        // Create a capture device
        captureSession.sessionPreset = .photo
        guard let captureDevice = try? AVCaptureDevice.default(for: .video) else {
            fatalError("Fail to initialize the camera device")
        }
        // Define the device input and output
        guard let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            fatalError("Fail to retrieve device input")
        }
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:
                                        Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        
        captureSession.addInput(deviceInput)
        captureSession.addOutput(deviceOutput)
        
        // Add a video layer to the image view
        let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer.frame = cameraImageView.layer.frame
        cameraImageView.layer.addSublayer(cameraPreviewLayer)
        
        captureSession.startRunning()
        
        print("captureLiveVideo OK")
    }
    
    /// Updates the UI with the results of the classification.
    /// - Tag: ProcessClassifications
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            
            guard let results = request.results else{
                print("Unable to classify image")
                return
            }
            print("results OK")

            let classifications = results as! [VNClassificationObservation]
            print("classifications OK")

            if classifications.isEmpty{
                print("Nothing recognized")
            } else {
                guard let bestAnswer = classifications.first else {
                    print("bestAnswer OK")
                    return
                }
                
                let predictedDS = bestAnswer.identifier
                
                func showScanned(){
                    if (self.scanned == false) {
                        if #available(iOS 13.0, *) { // View present style 1
    //                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            if let vc = self.storyboard?.instantiateViewController(identifier: "scannedView") {
    //                            vc.isModalInPresentation = true
    //                            vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true, completion: nil)
                            }
                        } else {
                            // Fallback on earlier versions
                            fatalError("Please update to iOS 13.0 or above")
                        }
                    }
                    print("showScanned OK")
                }
                
                var DSDesc = ""
                // Matching
                // Our hardcoded data provides more accurate and understandable information, avoids misrecognition of small text in low light and handshake conditions, and also makes complex meanings easier
                if (predictedDS == "001"){
                    self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                    DSDesc = "Sundown Naturals, Calcium, Magnesium & Zinc, 100 Caplets\n\nSupplement Facts\n\nServing Size: 2 Capsules\nServings Per Container: 200\n\nAmount Per Serving\nL-Leucine    500 mg\nL-Isoleucine    250 mg\nL-Valine    250 mg\n\nSuggested use\nConsume 2 BCAA 1000 Capsules between meals, 35-45 minutes before workouts, and/or immediately after workouts. Intended for use in healthy adults and as part of a healthy, balanced diet and exercise program."
                    showScanned()
                    self.scanned = true
                    UserDefaults.standard.set(false, forKey: "Key2") //Bool
                    print("001")
                } else if (predictedDS == "002"){
                    self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                    DSDesc = "Source Naturals, B-50 Complex, 50 mg, 100 Tablets\n\nSupplement Facts\n\nServing Size: 1 Tablet\n\nAmount Per Serving\nThiamin (as mononitrate) (vitamin B-1)    50 mg\nRiboflavin (vitamin B-2)    50 mg\nNiacin (as niacinamide)    50 mg\nVitamin B-6 (as pyridoxine HCI)    50 mg\nFolate (as folic acid)    1,360 mcg DFE(800 mcg folic acid)\nVitamin B-12 (as cyanocobalamin)    50 mcg\nBiotin    50 mcg\nPantothenic Acid (as calcium D-pantothenate)    100 mg\nCholine (as choline bitartrate)    50 mg\nInositol    50 mg\nPABA (as para-amino benzoic acid)    30 mg\n\nSuggested use\n1 tablet 1 to 2 times daily."
                    showScanned()
                    self.scanned = true
                    UserDefaults.standard.set(false, forKey: "Key2") //Bool
                    print("002")
                } else if (predictedDS == "003"){
                    self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                    DSDesc = "Solgar, Magnesium with Vitamin B6, 250 Tablets\n\nSupplement Facts\n\nServing Size: 3 Tablets\nServings Per Container: 83\n\nAmount Per Serving\nVitamin B6 (as pyridoxine HCl)    25 mg\nMagnesium (as magnesium oxide)    400 mg\n\nSuggested use\nAs a dietary supplement for adults, take three (3) tablets daily, preferably with a meal or as directed by a healthcare practitioner."
                    showScanned()
                    self.scanned = true
                    UserDefaults.standard.set(false, forKey: "Key2") //Bool
                    print("003")
                } else if (predictedDS == "004"){
                    self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                    DSDesc = "California Gold Nutrition, Ferrochel Iron (Bisglycinate), 36 mg, 90 Veggie Capsules\n\nSupplement Facts\n\nServing Size: 1 Capsule\nServings Per Container: 90\n\nAmount Per Serving\nIron (as Ferrous Bisglycinate Chelate)    36 mg\n\nSuggested use\nTake 1 capsule daily without food. Best when taken as directed by a qualified healthcare professional."
                    showScanned()
                    self.scanned = true
                    UserDefaults.standard.set(false, forKey: "Key2") //Bool
                    print("004")
                }
                
                self.classifierLabel = DSDesc
                print("self.classifierLabel OK")
                
                let topClassifications = classifications.prefix(3)
                let descriptions = topClassifications.map { classifications in
                    
                    // (%.2f) %@ : percentageFloorTo2Decimal precentageSymbol noun
                    return String(format: " (%.2f) %@", classifications.confidence, classifications.identifier)
                }
                print("Classification:\n" + descriptions.joined(separator: "\n"))
                
                print("classifications is not empty")
            }
            print("DispatchQueue.main.async OK")
        }
        print("processClassifications OK")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        print("preferredStatusBarStyle OK")
        return .lightContent
    }
}

extension HomeViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        connection.videoOrientation = .portrait

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do{
            try imageRequestHandler.perform([self.classificationRequset])
        }catch{
            print(error)
        }
        
        print("captureOutput OK")
    }
}

extension HomeViewController {
    private func HomeView(){
        
        let parent = self.view!
        
        cameraImageView.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        parent.addSubview(cameraImageView)
        
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 390, height: 268)
        view.layer.backgroundColor = UIColor(red: 1, green: 0.008, blue: 0.4, alpha: 1).cgColor
        view.layer.cornerRadius = 64
        parent.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 390).isActive = true
        view.heightAnchor.constraint(equalToConstant: 368).isActive = true
        view.centerXAnchor.constraint(equalTo: parent.centerXAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: 100).isActive = true
        
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 335, height: 180)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 33)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        // Line height: 45 pt
        label.textAlignment = .center
        label.text = "Please scan information printed on dietary supplements"
        parent.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 335).isActive = true
        label.heightAnchor.constraint(equalToConstant: 180).isActive = true
        label.centerXAnchor.constraint(equalTo: parent.centerXAnchor, constant: -0.5).isActive = true
        label.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -44).isActive = true
        
        let smartPhoneIcon = UIImageView(image: UIImage(named: "smartphone_black_24dp"))
        smartPhoneIcon.frame = CGRect(x: 0, y: 0, width: 105, height: 105)
        parent.addSubview(smartPhoneIcon)
        smartPhoneIcon.translatesAutoresizingMaskIntoConstraints = false
        smartPhoneIcon.widthAnchor.constraint(equalToConstant: 105).isActive = true
        smartPhoneIcon.heightAnchor.constraint(equalToConstant: 105).isActive = true
        smartPhoneIcon.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
        smartPhoneIcon.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -216).isActive = true
        
        let rightTopCornerImage:UIImage = UIImage(named: "Vector 2")!
        let rightTopCorner = UIImageView(image: rightTopCornerImage)
        rightTopCorner.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        parent.addSubview(rightTopCorner)
        rightTopCorner.translatesAutoresizingMaskIntoConstraints = false
        rightTopCorner.widthAnchor.constraint(equalToConstant: 64).isActive = true
        rightTopCorner.heightAnchor.constraint(equalToConstant: 64).isActive = true
        rightTopCorner.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 291).isActive = true
        rightTopCorner.topAnchor.constraint(equalTo: parent.topAnchor, constant: 39).isActive = true
        
        let leftBottomCornerImage:UIImage = UIImage(cgImage: rightTopCornerImage.cgImage!, scale: rightTopCornerImage.scale, orientation: .down)
        let leftBottomCorner = UIImageView(image: leftBottomCornerImage)
        leftBottomCorner.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        parent.addSubview(leftBottomCorner)
        leftBottomCorner.translatesAutoresizingMaskIntoConstraints = false
        leftBottomCorner.widthAnchor.constraint(equalToConstant: 64).isActive = true
        leftBottomCorner.heightAnchor.constraint(equalToConstant: 64).isActive = true
        leftBottomCorner.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 39).isActive = true
        leftBottomCorner.topAnchor.constraint(equalTo: parent.topAnchor, constant: 435).isActive = true
        
        let rightBottomCornerImage:UIImage = UIImage(cgImage: rightTopCornerImage.cgImage!, scale: rightTopCornerImage.scale, orientation: .right)
        let rightBottomCorner = UIImageView(image: rightBottomCornerImage)
        rightBottomCorner.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        parent.addSubview(rightBottomCorner)
        rightBottomCorner.translatesAutoresizingMaskIntoConstraints = false
        rightBottomCorner.widthAnchor.constraint(equalToConstant: 64).isActive = true
        rightBottomCorner.heightAnchor.constraint(equalToConstant: 64).isActive = true
        rightBottomCorner.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 291).isActive = true
        rightBottomCorner.topAnchor.constraint(equalTo: parent.topAnchor, constant: 435).isActive = true
        
        let leftTopCornerImage:UIImage = UIImage(cgImage: rightTopCornerImage.cgImage!, scale: rightTopCornerImage.scale, orientation: .left)
        let leftTopCorner = UIImageView(image: leftTopCornerImage)
        leftTopCorner.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        parent.addSubview(leftTopCorner)
        leftTopCorner.translatesAutoresizingMaskIntoConstraints = false
        leftTopCorner.widthAnchor.constraint(equalToConstant: 64).isActive = true
        leftTopCorner.heightAnchor.constraint(equalToConstant: 64).isActive = true
        leftTopCorner.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 39).isActive = true
        leftTopCorner.topAnchor.constraint(equalTo: parent.topAnchor, constant: 39).isActive = true
        
        let aIcon = UIImageView(image: UIImage(named: "format_color_text_black_24dp"))
        aIcon.frame = CGRect(x: 0, y: 0, width: 84, height: 84)
        parent.addSubview(aIcon)
        aIcon.translatesAutoresizingMaskIntoConstraints = false
        aIcon.widthAnchor.constraint(equalToConstant: 84).isActive = true
        aIcon.heightAnchor.constraint(equalToConstant: 84).isActive = true
        aIcon.centerXAnchor.constraint(equalTo: parent.centerXAnchor, constant: 0).isActive = true
        aIcon.topAnchor.constraint(equalTo: parent.topAnchor, constant: 230).isActive = true
        
    }
}
