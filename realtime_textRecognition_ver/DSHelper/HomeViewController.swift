import Foundation
import UIKit
import AVFoundation /* Voice */
import Vision /* imageClassification */

class HomeViewController: UIViewController {
    
    // MARK: textRecognition
    var request: VNRecognizeTextRequest!
    let stringTracker = StringTracker()
    // MARK: textRecognition end
    
    var dss = [DS]() /* JSON */
    
    var scanned = false
    var DSName = String()
    
    var captureSession = AVCaptureSession() // Create capture session /* imageClassification */
    /* imageClassification2 */
//    @IBOutlet var cameraImageView : UIImageView!
    var cameraImageView = UIImageView()
    /* imageClassification2 end */
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        HomeView() /* UILayout */
        captureLiveVideo() /* imageClassification */
        
        /* Voice */
        let utterance = AVSpeechUtterance(string: "Welcome to DS Helper! Please scan information printed on dietary supplements.")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.pitchMultiplier = 1.5
        utterance.rate = 0.33
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
        /* Voice end */

    }
    
    override func viewDidLoad() {
        // MARK: textRecognition4
        // Set up vision request before letting ViewController set up the camera
        // so that it exists when the first buffer is received.
        request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        // MARK: textRecognition4 end
        
        super.viewDidLoad()
    }
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
    /* JSON2 */
    // Use the two methods we created to reading JSON
    private func DSInfo(DSID rowNo: Int) -> String?{
        // 1. Reading the local data.json file.
        if let localData = readLocalFile(forName: "data") {
            parse(jsonData: localData)
        }
        // 2. Read and print the contents of the hosted JSON file.
//        let urlString = "https://raw.githubusercontent.com/programmingwithswift/ReadJSONFileURL/master/hostedDataFile.json"
//        self.loadJson(fromURLString: urlString) { (result) in
//            switch result {
//            case .success(let data):
//                self.parse(jsonData: data)
//            case .failure(let error):
//                print(error)
//            }
//        }
        let ds = dss[rowNo]
        DSName = "\(ds.title)"
        let DSInformation = "\(ds.title)" + " \(ds.price)" + "\n\nSupplement Facts\nServing Size: \(ds.servingSize)" + "\nServings Per Container: \(ds.servingsPerContainer)" + "\nAmount Per Serving / % Daily Value\n\(ds.supplementFact)" + "\n\(ds.supplementFact2)" + "\n\(ds.supplementFact3)" + "\n\(ds.supplementFact4)" + "\n\(ds.supplementFact5)" + "\n\(ds.supplementFact6)" + "\n\(ds.supplementFact7)" + "\n\nSuggested use\n\(ds.suggestedUse)"
        return DSInformation
    }
    /* JSON2 end */

    /* JSON3 */
    // 1. Read the local JSON file
    private func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"),
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        return nil
    }
    // 2. Create loadJson from URL method
//    private func loadJson(fromURLString urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
//        if let url = URL(string: urlString) {
//            let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
//                if let error = error {
//                    completion(.failure(error))
//                }
//                if let data = data {
//                    completion(.success(data))
//                }
//            }
//            urlSession.resume()
//        }
//    }
    // Create the JSON Parse method
    private func parse(jsonData: Data) {
        do {
            let decodedData = try JSONDecoder().decode(DSs.self, from: jsonData)
            dss = decodedData.DietarySupplements
        } catch {
            print("decode error")
        }
    }
    /* JSON3 end */
    
    @IBAction private func showScannedView(_ sender: UIButton){
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
    
    /* imageClassification */
    // Capture Live Video
    func captureLiveVideo() {
        // Create a capture device
        captureSession.sessionPreset = .photo
        guard let captureDevice = try? AVCaptureDevice.default(for: .video) else {
            fatalError("Fail to initialize the camera device")
        }
        // Define the device input and output
        // Create device input
        guard let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            fatalError("Fail to retrieve device input")
        }
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:
                                        Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        
        captureSession.addInput(deviceInput)
        captureSession.addOutput(deviceOutput)
        
        // Add preview layer
        // Add a video layer to the image view
        let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer.frame = cameraImageView.layer.frame
        cameraImageView.layer.addSublayer(cameraPreviewLayer)
        
        // Start capturing
        captureSession.startRunning()
        
    }
    /* imageClassification end */
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        print("preferredStatusBarStyle OK")
        return .lightContent
    }
    
    // MARK: textRecognition3
    // Vision recognition handler.
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        var strings = [String]()
        
        guard let results = request.results as? [VNRecognizedTextObservation] else {
            return
        }
        
        if results.isEmpty{
            print("Nothing recognized")
            return
        } else {
            let maximumCandidates = 1
            
            for visionResult in results {
                guard let candidate = visionResult.topCandidates(maximumCandidates).first else { continue }
                
                strings.append(candidate.string)
            }
            // Log any found string.
            stringTracker.logFrame(strings: strings)
            
            // Check if we have any temporally stable numbers.
            if let sureString = stringTracker.getStableString() {
                
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
                }
                // Matching
                if sureString.range(of: "Calcium", options: .caseInsensitive) != nil {
                    if sureString.range(of: "Magnesium", options: .caseInsensitive) != nil {
                        let DSNumber = 0
                        self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                        let DSDesc = self.DSInfo(DSID: DSNumber) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                        UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                        UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(DSNumber), forKey: "DS_ID") //setObject
                        print("DSNumber is" + String(DSNumber))
                    }
                } else if sureString.range(of: "B-50", options: .caseInsensitive) != nil {
                    if sureString.range(of: "Complex", options: .caseInsensitive) != nil {
                        let DSNumber = 1
                        self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                        let DSDesc = self.DSInfo(DSID: DSNumber) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                        UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                        UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(DSNumber), forKey: "DS_ID") //setObject
                        print("DSNumber is" + String(DSNumber))
                    }
                } else if sureString.range(of: "Magnesium", options: .caseInsensitive) != nil {
                    if sureString.range(of: "B6", options: .caseInsensitive) != nil {
                        let DSNumber = 2
                        self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                        let DSDesc = self.DSInfo(DSID: DSNumber) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                        UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                        UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(DSNumber), forKey: "DS_ID") //setObject
                        print("DSNumber is" + String(DSNumber))
                    }
                } else if sureString.range(of: "Iron", options: .caseInsensitive) != nil {
                    if sureString.range(of: "36 mg", options: .caseInsensitive) != nil {
                        let DSNumber = 3
                        self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                        let DSDesc = self.DSInfo(DSID: DSNumber) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                        UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                        UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(DSNumber), forKey: "DS_ID") //setObject
                        print("DSNumber is" + String(DSNumber))
                    }
                } else if sureString.range(of: "Gummies", options: .caseInsensitive) != nil {
                    if sureString.range(of: "Vitamin C", options: .caseInsensitive) != nil {
                        let DSNumber = 4
                        self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                        let DSDesc = self.DSInfo(DSID: DSNumber) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                        UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                        UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(DSNumber), forKey: "DS_ID") //setObject
                        print("DSNumber is" + String(DSNumber))
                    }
                } else if sureString.range(of: "LactoBif", options: .caseInsensitive) != nil {
                    if sureString.range(of: "Probiotics", options: .caseInsensitive) != nil {
                        let DSNumber = 5
                        self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                        let DSDesc = self.DSInfo(DSID: DSNumber) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                        UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                        UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(DSNumber), forKey: "DS_ID") //setObject
                        print("DSNumber is" + String(DSNumber))
                    }
                } else if sureString.range(of: "Life", options: .caseInsensitive) != nil {
                    if sureString.range(of: "B-Complex", options: .caseInsensitive) != nil {
                        let DSNumber = 6
                        self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                        let DSDesc = self.DSInfo(DSID: DSNumber) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                        UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                        UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(DSNumber), forKey: "DS_ID") //setObject
                        print("DSNumber is" + String(DSNumber))
                    }
                } else if sureString.range(of: "Omega-3", options: .caseInsensitive) != nil {
                    if sureString.range(of: "Fish Oil", options: .caseInsensitive) != nil {
                        let DSNumber = 7
                        self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                        let DSDesc = self.DSInfo(DSID: DSNumber) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                        UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                        UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(DSNumber), forKey: "DS_ID") //setObject
                        print("DSNumber is" + String(DSNumber))
                    }
                } else if sureString.range(of: "Immune", options: .caseInsensitive) != nil {
                    if sureString.range(of: "4", options: .caseInsensitive) != nil {
                        let DSNumber = 8
                        self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                        let DSDesc = self.DSInfo(DSID: DSNumber) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                        UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                        UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(DSNumber), forKey: "DS_ID") //setObject
                        print("DSNumber is" + String(DSNumber))
                    }
                } else if sureString.range(of: "Biotin", options: .caseInsensitive) != nil {
                    if sureString.range(of: "10,000 mcg", options: .caseInsensitive) != nil {
                        let DSNumber = 9
                        self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                        let DSDesc = self.DSInfo(DSID: DSNumber) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                        UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                        UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(DSNumber), forKey: "DS_ID") //setObject
                        print("DSNumber is" + String(DSNumber))
                    }
                } else if sureString.range(of: "Vitamin", options: .caseInsensitive) != nil {
                    if sureString.range(of: "D3", options: .caseInsensitive) != nil {
                        let DSNumber = 10
                        self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                        let DSDesc = self.DSInfo(DSID: DSNumber) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                        UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                        UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(DSNumber), forKey: "DS_ID") //setObject
                        print("DSNumber is" + String(DSNumber))
                    }
                } else if sureString.range(of: "Collagen", options: .caseInsensitive) != nil {
                    if sureString.range(of: "Peptides", options: .caseInsensitive) != nil {
                        let DSNumber = 11
                        self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                        let DSDesc = self.DSInfo(DSID: DSNumber) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                        UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                        UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(DSNumber), forKey: "DS_ID") //setObject
                        print("DSNumber is" + String(DSNumber))
                    }
                } else if sureString.range(of: "Lutein", options: .caseInsensitive) != nil {
                    if sureString.range(of: "20 mg", options: .caseInsensitive) != nil {
                        let DSNumber = 12
                        self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                        let DSDesc = self.DSInfo(DSID: DSNumber) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                        UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                        UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(DSNumber), forKey: "DS_ID") //setObject
                        print("DSNumber is" + String(DSNumber))
                    }
                } else if sureString.range(of: "Lutein", options: .caseInsensitive) != nil {
                    if sureString.range(of: "20 mg", options: .caseInsensitive) != nil {
                        let DSNumber = 13
                        self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                        let DSDesc = self.DSInfo(DSID: DSNumber) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                        UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                        UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(DSNumber), forKey: "DS_ID") //setObject
                        print("DSNumber is" + String(DSNumber))
                    }
                } else if sureString.range(of: "Natures", options: .caseInsensitive) != nil {
                    if sureString.range(of: "120 Softgels", options: .caseInsensitive) != nil {
                        let DSNumber = 14
                        self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                        let DSDesc = self.DSInfo(DSID: DSNumber) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                        UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                        UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(DSNumber), forKey: "DS_ID") //setObject
                        print("DSNumber is" + String(DSNumber))
                    }
                } else if sureString.range(of: "PepZinGI", options: .caseInsensitive) != nil {
                    if sureString.range(of: "120 Veggie Caps", options: .caseInsensitive) != nil {
                        let DSNumber = 15
                        self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                        let DSDesc = self.DSInfo(DSID: DSNumber) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                        UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                        UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(DSNumber), forKey: "DS_ID") //setObject
                        print("DSNumber is" + String(DSNumber))
                    }
                } else if sureString.range(of: "D-Mannose", options: .caseInsensitive) != nil {
                    if sureString.range(of: "500 mg", options: .caseInsensitive) != nil {
                        let DSNumber = 16
                        self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                        let DSDesc = self.DSInfo(DSID: DSNumber) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                        UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                        UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(DSNumber), forKey: "DS_ID") //setObject
                        print("DSNumber is" + String(DSNumber))
                    }
                } else if sureString.range(of: "MCT", options: .caseInsensitive) != nil {
                    if sureString.range(of: "Oil", options: .caseInsensitive) != nil {
                        let DSNumber = 17
                        self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                        let DSDesc = self.DSInfo(DSID: DSNumber) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                        UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                        UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(DSNumber), forKey: "DS_ID") //setObject
                        print("DSNumber is" + String(DSNumber))
                    }
                }
                
                stringTracker.reset(string: sureString)
            }
        }
    }
    // MARK: textRecognition3 end
}

/* imageClassification3 */
// Live video output
extension HomeViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = .portrait

        // MARK: textRecognition2
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            // Configure for running in real-time.
            request.recognitionLevel = .fast
            // Language correction won't help recognizing phone numbers. It also
            // makes recognition slower.
            request.usesLanguageCorrection = false
            
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            do {
                try requestHandler.perform([request])
            } catch {
                print(error)
            }
        }
        // MARK: textRecognition2 end
    }
}
/* imageClassification3 end */

/* UILayout */
extension HomeViewController {
    private func HomeView(){
        
        let parent = self.view!
        
        /* imageClassification2 */
        cameraImageView.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        parent.addSubview(cameraImageView)
        /* imageClassification2 end */
        
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
        
        let smartPhoneIcon = UIButton()
        smartPhoneIcon.setBackgroundImage(UIImage(named: "smartphone_black_24dp"), for: .normal)
        smartPhoneIcon.frame = CGRect(x: 0, y: 0, width: 105, height: 105)
        smartPhoneIcon.addTarget(self, action: #selector(showScannedView(_:)), for: .touchUpInside)
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
/* UILayout end*/
