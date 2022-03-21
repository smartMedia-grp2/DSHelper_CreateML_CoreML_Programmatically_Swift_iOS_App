import Foundation
import UIKit
import AVFoundation /* Voice */
import Vision /* imageClassification */

class HomeViewController: UIViewController {
    
    var dss = [DS]() /* JSON */
    
    var scanned = false
    var DSName = String()
    
    var captureSession = AVCaptureSession() // Create capture session /* imageClassification */
    /* imageClassification2 */
//    @IBOutlet var cameraImageView : UIImageView!
    var cameraImageView = UIImageView()
    /* imageClassification2 end */
    
    /* imageClassification4 */
    // Load ML model
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: dsClassifier(configuration: MLModelConfiguration()).model)
            return VNCoreMLRequest(model: model, completionHandler: { [weak self]
                request, error in
                self?.processClassifications(for: request, error: error)
            })
        } catch {
            fatalError("Fail to load ML model: \(error)")
        }
        print("classificationRequset OK")
    }()
    /* imageClassification4 end */
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        HomeView() /* UILayout */
        captureLiveVideo() /* imageClassification */
        
        /* Voice */
        let utterance = AVSpeechUtterance(string: "Welcome to DS Helper! Please scan information printed on dietary supplements.")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.25
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
        /* Voice end */

//        print("viewDidAppear OK")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("viewDidLoad OK")
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
        print("showScannedView OK")
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
        
//        print("captureLiveVideo OK")
    }
    /* imageClassification end */
    
    /* imageClassification5 */
    // Classification
    /// Updates the UI with the results of the classification.
    /// - Tag: ProcessClassifications
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            
            guard let results = request.results else{
                print("Unable to classify image")
                return
            }
//            print("results OK")

            let classifications = results as! [VNClassificationObservation]
//            print("classifications OK")

            if classifications.isEmpty{
                print("Nothing recognized")
                return
                
            } else {
                
                guard let bestAnswer = classifications.first else {
                    print("bestAnswer not OK")
                    return
                }
                let predictedDS = bestAnswer.identifier
                
                /* Test */                                
                print("classify() start")
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
                // Matching
                if (predictedDS == "001"){
                    self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                    let DSDesc = self.DSInfo(DSID: 0) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                    UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                    UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                    showScanned()
                    self.scanned = true
                    UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                    print("001")
                } else if (predictedDS == "002"){
                    self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                    let DSDesc = self.DSInfo(DSID: 1) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                    UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                    UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                    showScanned()
                    self.scanned = true
                    UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                    print("002")
                } else if (predictedDS == "003"){
                    self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                    let DSDesc = self.DSInfo(DSID: 2) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                    UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                    UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                    showScanned()
                    self.scanned = true
                    UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                    print("003")
                } else if (predictedDS == "004"){
                    self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                    let DSDesc = self.DSInfo(DSID: 3) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                    UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                    UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                    showScanned()
                    self.scanned = true
                    UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                    print("004")
                } else if (predictedDS == "005"){
                    self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                    let DSDesc = self.DSInfo(DSID: 4) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                    UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                    UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                    showScanned()
                    self.scanned = true
                    UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                    print("005")
                } else if (predictedDS == "006"){
                    self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                    let DSDesc = self.DSInfo(DSID: 5) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                    UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                    UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                    showScanned()
                    self.scanned = true
                    UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                    print("006")
                } else if (predictedDS == "007"){
                    self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                    let DSDesc = self.DSInfo(DSID: 6) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                    UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                    UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                    showScanned()
                    self.scanned = true
                    UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                    print("007")
                } else if (predictedDS == "008"){
                    self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                    let DSDesc = self.DSInfo(DSID: 7) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                    UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                    UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                    showScanned()
                    self.scanned = true
                    UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                    print("008")
                } else if (predictedDS == "009"){
                    self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                    let DSDesc = self.DSInfo(DSID: 8) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                    UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                    UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                    showScanned()
                    self.scanned = true
                    UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                    print("009")
                } else if (predictedDS == "010"){
                    self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                    let DSDesc = self.DSInfo(DSID: 9) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                    UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                    UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                    showScanned()
                    self.scanned = true
                    UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                    print("010")
                } else if (predictedDS == "011"){
                    self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                    let DSDesc = self.DSInfo(DSID: 10) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                    UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                    UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                    showScanned()
                    self.scanned = true
                    UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                    print("011")
                } else if (predictedDS == "012"){
                    self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                    let DSDesc = self.DSInfo(DSID: 11) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                    UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                    UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                    showScanned()
                    self.scanned = true
                    UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                    print("012")
                } else if (predictedDS == "013"){
                    self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                    let DSDesc = self.DSInfo(DSID: 12) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                    UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                    UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                    showScanned()
                    self.scanned = true
                    UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                    print("013")
                } else if (predictedDS == "014"){
                    self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                    let DSDesc = self.DSInfo(DSID: 13) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                    UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                    UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                    showScanned()
                    self.scanned = true
                    UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                    print("014")
                } else if (predictedDS == "015"){
                    self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                    let DSDesc = self.DSInfo(DSID: 14) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                    UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                    UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                    showScanned()
                    self.scanned = true
                    UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                    print("015")
                } else if (predictedDS == "016"){
                    self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                    let DSDesc = self.DSInfo(DSID: 15) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                    UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                    UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                    showScanned()
                    self.scanned = true
                    UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                    print("016")
                } else if (predictedDS == "017"){
                    self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                    let DSDesc = self.DSInfo(DSID: 16) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                    UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                    UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                    showScanned()
                    self.scanned = true
                    UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                    print("017")
                } else if (predictedDS == "018"){
                    self.scanned = UserDefaults.standard.bool(forKey: "Scanned")
                    let DSDesc = self.DSInfo(DSID: 17) // DSID, Int, Int = parsed JSON data array row number, 0 = data of DS "001", 1 = data of DS "002"...
                    UserDefaults.standard.set(DSDesc, forKey: "DSDesc") //setObject
                    UserDefaults.standard.set(self.DSName, forKey: "DSName") //setObject
                    showScanned()
                    self.scanned = true
                    UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                    print("018")
                }
                print("classify() end")
                
/* Origin */
//                let observations = classifications.prefix(3)
//
//                // Get confidence
//                var prediction = Float()
//                let _: [()] = observations.map { observation in
//                    prediction = observation.confidence * 100
//                    return
////                    "%.2f" means percentageFloorTo2Decimal a Float. "%@" would be a String
////                    return String(format: "(%.2f)%@", observation.confidence, observation.identifier)
//                }
//                print(prediction)
//
//                func classify(){
//                    print("classify() start")
//                    func showScanned(){
//                        if (self.scanned == false) {
//                            if #available(iOS 13.0, *) { // View present style 1
//        //                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                                if let vc = self.storyboard?.instantiateViewController(identifier: "scannedView") {
//        //                            vc.isModalInPresentation = true
//        //                            vc.modalPresentationStyle = .fullScreen
//                                    self.present(vc, animated: true, completion: nil)
//                                }
//                            } else {
//                                // Fallback on earlier versions
//                                fatalError("Please update to iOS 13.0 or above")
//                            }
//                        }
//                        print("showScanned OK")
//                    }
////                 Matching
////                 Our hardcoded data provides more accurate and understandable information, avoids misrecognition of small text in low light and handshake conditions, and also makes complex meanings easier
//                if (predictedDS == "001"){...
//                    print("classify() end")
//                }
//
//                switch prediction {
//                case 100.0...:
//                    classify()
//                    print("Confidence: 100.0...")
////                    break
//                case 75.0..<100.0:
//                    classify()
//                    print("Confidence: 75.0..<100.0...")
////                    break
//                case 50.0..<75.0:
//                    print("Confidence: 50.0..<75.0")
////                    break
//                case 25.0..<50.0:
//                    print("Confidence: 25.0..<50.0")
////                    break
//                case 10.0..<25.0:
//                    print("Confidence: 10.0..<25.0")
////                    break
//                case 1.0..<10.0:
//                    print("Confidence: 1.0..<10.0")
////                    break
//                case ..<1.0:
//                    print("Confidence: ..<1.0")
////                    break
//                default:
//                    print("Confidence: N/A")
//                }
                
            }
//            print("DispatchQueue.main.async OK")
        }
//        print("processClassifications OK")
    }
    /* imageClassification5 end */
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        print("preferredStatusBarStyle OK")
        return .lightContent
    }
}

/* imageClassification3 */
// Live video output
extension HomeViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        print("captureOutput start")
        connection.videoOrientation = .portrait

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do{
            try imageRequestHandler.perform([self.classificationRequest])
        }catch{
            print(error)
        }
//        print("captureOutput OK")
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
