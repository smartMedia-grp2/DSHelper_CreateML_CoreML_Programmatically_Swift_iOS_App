import Foundation
import UIKit
import AVFoundation
import Vision

class HomeViewController: UIViewController {
    
    var scanned = false
    
    var captureSession = AVCaptureSession() // Create capture session
//    @IBOutlet var cameraImageView : UIImageView!
    var cameraImageView = UIImageView()
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        HomeView()
        captureLiveVideo()
        
        let utterance = AVSpeechUtterance(string: "Welcome to DS Helper! Please scan information printed on dietary supplements.")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.25
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
        
//        print("viewDidAppear OK")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print("viewDidLoad OK")
    }
    
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
                
                let observations = classifications.prefix(3)
                
                var prediction = Float()
                let _: [()] = observations.map { observation in
                    prediction = observation.confidence * 100
//                    "%.2f" means percentageFloorTo2Decimal a Float. "%@" would be a String
//                    return String(format: "(%.2f)%@", observation.confidence, observation.identifier)
                }
                print(prediction)
                
                func classify(){
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
                    // Our hardcoded data provides more accurate and understandable information, avoids misrecognition of small text in low light and handshake conditions, and also makes complex meanings easier
                    if (predictedDS == "001"){
                        self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                        let DSDesc =
                        "Sundown Naturals, Calcium, Magnesium & Zinc, 100 Caplets" +
                        "HK$34.97" + "- \(prediction)" + "\n\n" + "Supplement Facts\n\nServing Size:" +
                        "3 Caplets" + "\nServings Per Container:" +
                        "33" + "\n\nAmount Per Serving\n" +
                        "Calcium (as Calcium Carbonate and Calcium Gluconate)    1,000 mg" + "\n" +
                        "Magnesium (as Magnesium Oxide and Magnesium Gluconate)    400 mg" + "\n" +
                        "Zinc (as Zinc Oxide and Zinc Citrate)    25 mg" + "\n\nSuggested use\n" +
                        "For adults, take three (3) caplets daily, preferably with a meal. As a reminder, discuss the supplements and medications you take with your health care providers."
                        UserDefaults.standard.set(DSDesc, forKey: "Key") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                        print("001")
                    } else if (predictedDS == "002"){
                        self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                        let DSDesc =
                        "Source Naturals, B-50 Complex, 50 mg, 100 Tablets" +
                        "HK$81.93" + "- \(prediction)" + "\n\n" + "Supplement Facts\n\nServing Size:" +
                        "1 Tablet" + "\n\nAmount Per Serving\n" +
                        "Thiamin (as mononitrate) (vitamin B-1)    50 mg" + "\n" +
                        "Riboflavin (vitamin B-2)    50 mg" + "\n" +
                        "Niacin (as niacinamide)    50 mg" + "\n" +
                        "Vitamin B-6 (as pyridoxine HCI)    50 mg" + "\n" +
                        "Folate (as folic acid)    1,360 mcg" + "\n" +
                        "Vitamin B-12 (as cyanocobalamin)    50 mcg" + "\n" +
                        "Biotin    50 mcg" + "\n" +
                        "Pantothenic Acid (as calcium D-pantothenate)    100 mg" + "\n" +
                        "Choline (as choline bitartrate)    50 mg" + "\n" +
                        "Inositol    50 mg" + "\n" +
                        "PABA (as para-amino benzoic acid)    30 mg" + "\n\nSuggested use\n" +
                        "1 tablet 1 to 2 times daily."
                        UserDefaults.standard.set(DSDesc, forKey: "Key") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                        print("002")
                    } else if (predictedDS == "003"){
                        self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                        let DSDesc =
                        "Solgar, Magnesium with Vitamin B6, 250 Tablets" +
                        "HK$119.24" + "- \(prediction)" + "\n\n" + "Supplement Facts\n\nServing Size:" +
                        "3 Tablets" + "\nServings Per Container:" +
                        "83" + "\n\nAmount Per Serving\n" +
                        "Vitamin B6 (as pyridoxine HCl)    25 mg" + "\n" +
                        "Magnesium (as magnesium oxide)    400 mg" + "\n\nSuggested use\n" +
                        "As a dietary supplement for adults, take three (3) tablets daily, preferably with a meal or as directed by a healthcare practitioner."
                        UserDefaults.standard.set(DSDesc, forKey: "Key") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                        print("003")
                    } else if (predictedDS == "004"){
                        self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                        let DSDesc =
                        "California Gold Nutrition, Ferrochel Iron (Bisglycinate), 36 mg, 90 Veggie Capsules" +
                        "HK$56.90" + "- \(prediction)" + "\n\n" + "Supplement Facts\n\nServing Size:" +
                        "1 Capsule" + "\nServings Per Container:" +
                        "90" + "\n\nAmount Per Serving\n" +
                        "Iron (as Ferrous Bisglycinate Chelate)    36 mg" + "\n\nSuggested use\n" +
                        "Take 1 capsule daily without food. Best when taken as directed by a qualified healthcare professional."
                        UserDefaults.standard.set(DSDesc, forKey: "Key") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                        print("004")
                    } else if (predictedDS == "005"){
                        self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                        let DSDesc =
                        "California Gold Nutrition, Vitamin C Gummies, Natural Orange Flavor, Gelatin Free, 90 Gummies" +
                        "HK$73.15" + "- \(prediction)" + "\n\n" + "Supplement Facts\n\nServing Size:" +
                        "3 Gummies" + "\nServings Per Container:" +
                        "30" + "\n\nAmount Per Serving\n" +
                        "Calories    30" + "\n" +
                        "Total Carbohydrate    6 g" + "\n" +
                        "Total Sugars    6 g" + "\n" +
                        "Includes 6 g Added Sugars" + "\n" +
                        "Vitamin A(as Beta Carotene)    75 mcg" + "\n" +
                        "Vitamin C (as Ascorbic Acid)    250 mg" + "\n\nSuggested use\n" +
                        "Adults and children 4 years of age or older, take 3 gummies daily, with or without food, or as directed by your qualified healthcare professional. Please ensure child chews gummies thoroughly."
                        UserDefaults.standard.set(DSDesc, forKey: "Key") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                        print("005")
                    } else if (predictedDS == "006"){
                        self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                        let DSDesc =
                        "California Gold Nutrition, LactoBif Probiotics, 5 Billion CFU, 10 Veggie Capsules" +
                        "HK$8.13" + "- \(prediction)" + "\n\n" + "Supplement Facts\n\nServing Size:" +
                        "1 Capsule" + "\nServings Per Container:" +
                        "10" + "\n\nAmount Per Serving\n" +
                        "Probiotic Bacteria Blend    5 Billion CFU" + "\n" +
                        "Composed of the following strains:    " + "\n" +
                        "Lactobacillus acidophilus (La-14)    " + "\n" +
                        "Bifidobacterium lactis (Bl-04)    " + "\n" +
                        "Lactobacillus rhamnosus (Lr-32)    " + "\n" +
                        "Lactobacillus plantarum (Lp-115)    " + "\n" +
                        "Bifidobacterium longum (Bl-05)    " + "\n" +
                        "Bifidobacterium breve (Bb-03)    " + "\n" +
                        "Lactobacillus casei (Lc-11)    " + "\n" +
                        "Lactobacillus salivarius (Ls-33)    " + "\n\nSuggested use\n" +
                        "Take 1 capsule daily, with or without food. Best when taken as directed by a qualified healthcare professional."
                        UserDefaults.standard.set(DSDesc, forKey: "Key") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                        print("006")
                    } else if (predictedDS == "007"){
                        self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                        let DSDesc =
                        "Life Extension, BioActive Complete B-Complex, 60 Vegetarian Capsules" +
                        "HK$80.43" + "- \(prediction)" + "\n\n" + "Supplement Facts\n\nServing Size:" +
                        "2 Vegetarian Capsules" + "\nServings Per Container:" +
                        "30" + "\n\nAmount Per Serving\n" +
                        "Thiamine (vitamin B1) (as thiamine HCI)    100 mg" + "\n" +
                        "Riboflavin (vitamin B2) (as riboflavin and riboflavin 5'-phosphate)" + "\n" +
                        "Niacin (as niacinamide and niacin)    100 mg" + "\n" +
                        "Vitamin B6 (as pyridoxine HCI and pyridoxal 5' phosphate)    100 mg" + "\n" +
                        "Folate (as L-5-methyltetrahydrofolate calcium salt)    680 mcg" + "\n" +
                        "Vitamin B12 (as methylcobalamin)    300 mcg" + "\n" +
                        "Biotin    1000 mcg" + "\n" +
                        "Pantothenic acid (as D-calcium pantothenate)    500 mg" + "\n" +
                        "Calcium (as D-calcium pantothenate, dicalcium phosphate)    50 mg" + "\n" +
                        "Inositol    100 mg" + "\n" +
                        "PABA (para-aminobenzoic acid)    50 mg" + "\n\nSuggested use\n" +
                        "Read the entire label and follow the directions carefully prior to use. Take two (2) capsules daily with food, or as recommended by a healthcare practitioner."
                        UserDefaults.standard.set(DSDesc, forKey: "Key") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                        print("007")
                    } else if (predictedDS == "008"){
                        self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                        let DSDesc =
                        "Sports Research, Omega-3 Fish Oil, Triple Strength, 1,250 mg , 120 Softgels" +
                        "HK$252.47" + "- \(prediction)" + "\n\n" + "Supplement Facts\n\nServing Size:" +
                        "1 Liquid Softgel" + "\nServings Per Container:" +
                        "120" + "\n\nAmount Per Serving\n" +
                        "Calories     15" + "\n" +
                        "Total Fat    1.5 g" + "\n" +
                        "Omega-3 Fish Oil Concentrate from Wild Caught Fish    1250 mg" + "\n" +
                        "Total Omega-3 Fatty Acids as TG     1055 mg" + "\n" +
                        "Eicosapentaenoic Acid (EPA as TG)    685 mg" + "\n" +
                        "Docosahexaenoic Acid (DHA as TG)    310 mg" + "\n" +
                        "Other Omega-3 Fatty Acids as TG    60 mg" + "\n\nSuggested use\n" +
                        "use"
                        UserDefaults.standard.set(DSDesc, forKey: "Key") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                        print("008")
                    } else if (predictedDS == "009"){
                        self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                        let DSDesc =
                        "California Gold Nutrition, Immune 4, 60 Veggie Capsules" +
                        "HK$8.13" + "- \(prediction)" + "\n\n" + "Supplement Facts\n\nServing Size:" +
                        "1 Capsule" + "\nServings Per Container:" +
                        "60" + "\n\nAmount Per Serving\n" +
                        "Vitamin C (as Ascorbic Acid)    500 mg" + "\n" +
                        "Vitamin D (as D3, Cholecalciferol) (from Lanolin)    25 mcg" + "\n" +
                        "Zinc (as Zinc Picolinate)     10 mg" + "\n" +
                        "Selenium (as L-Selenomethionine)     50 mcg" + "\n\nSuggested use\n" +
                        "Take 1 capsule, once or twice daily with food. Best when taken as directed by a qualified healthcare professional."
                        UserDefaults.standard.set(DSDesc, forKey: "Key") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                        print("009")
                    } else if (predictedDS == "010"){
                        self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                        let DSDesc =
                        "Natrol, Biotin, Maximum Strength, 10,000 mcg, 100 Tablets" +
                        "HK$81.90" + "- \(prediction)" + "\n\n" + "Supplement Facts\n\nServing Size:" +
                        "1 Tablet" + "\nServings Per Container:" +
                        "100" + "\n\nAmount Per Serving\n" +
                        "Biotin    10,000 mcg" + "\n" +
                        "Calcium (from Dibasic Calcium Phosphate)    66 mg" + "\n\nSuggested use\n" +
                        "Take 1 tablet, one time daily, with a meal."
                        UserDefaults.standard.set(DSDesc, forKey: "Key") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                        print("010")
                    } else if (predictedDS == "011"){
                        self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                        let DSDesc =
                        "ChildLife, Vitamin D3, Natural Berry Flavor, 1 fl oz (30 ml)" +
                        "HK$52.38" + "- \(prediction)" + "\n\n" + "Supplement Facts\n\nServing Size:" +
                        "8 drops" + "\nServings Per Container:" +
                        "115" + "\n\nAmount Per Serving\n" +
                        "Vitamin D3 (as Cholecalciferol)    500 IU" + "\n\nSuggested use\n" +
                        "Infants 0 - 12: 6 drops daily\nChildren 1+ yrs: 8 drops daily\nShake well before use. Give directly or mix in your child's favorite drink."
                        UserDefaults.standard.set(DSDesc, forKey: "Key") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                        print("011")
                    } else if (predictedDS == "012"){
                        self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                        let DSDesc =
                        "Vital Proteins, Collagen Peptides, Unflavored, 1.25 lbs (567 g)" +
                        "HK$286.06" + "- \(prediction)" + "\n\n" + "Supplement Facts\n\nServing Size:" +
                        "2 Scoops (20 g)" + "\nServings Per Container:" +
                        "About 28" + "\n\nAmount Per Serving\n" +
                        "Calories    70" + "\n" +
                        "Protein    18 g" + "\n" +
                        "Sodium    110 mg" + "\n" +
                        "Collagen peptides (from bovine)    20 g" + "\n" +
                        "Contains 8 of 9 Essential Amino Acids" + "\n\nSuggested use\n" +
                        "Combine 1-2 scoops with 8 fl oz of liquid, mix thoroughly."
                        UserDefaults.standard.set(DSDesc, forKey: "Key") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                        print("012")
                    } else if (predictedDS == "013"){
                        self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                        let DSDesc =
                        "Natural Factors, Lutein, 20 mg , 30 Softgels" +
                        "HK$31.78" + "- \(prediction)" + "\n\n" + "Supplement Facts\n\nServing Size:" +
                        "1 Softgel" + "\nServings Per Container:" +
                        "LuteinRich™ Lutein (Tagetes erecta) (marigold flower extract)      20 mg" + "\n" +
                        "Zeaxanthin (Tagetes erecta)(marigold flower extract)     3.5 mg" + "\n\nSuggested use\n" +
                        "1 softgel per day or as directed by a health professional."
                        UserDefaults.standard.set(DSDesc, forKey: "Key") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                        print("013")
                    } else if (predictedDS == "014"){
                        self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                        let DSDesc =
                        "Jarrow Formulas, Lutein, 20 mg, 120 Softgels" +
                        "HK$168.79" + "- \(prediction)" + "\n\n" + "Supplement Facts\n\nServing Size:" +
                        "1 Softgel" + "\nServings Per Container:" +
                        "120" + "\n\nAmount Per Serving\n" +
                        "Lutein (Tagetes erecta)(Marigold Petal Extract)    20 mg" + "\n" +
                        "Zeaxanthin (Tagetes erecta)(Marigold petal extract)    4 mg" + "\n\nSuggested use\n" +
                        "Take 1 softgel per day with food or as directed by your qualified healthcare professional."
                        UserDefaults.standard.set(DSDesc, forKey: "Key") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                        print("014")
                    } else if (predictedDS == "015"){
                        self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                        let DSDesc =
                        "NaturesPlus, Ultra Omega 3/6/9, 120 Softgels" +
                        "HK$174.11" + "- \(prediction)" + "\n\n" + "Supplement Facts\n\nServing Size:" +
                        "1 Softgel" + "\nServings Per Container:" +
                        "Calories    15" + "\n" +
                        "Calories from Fat    10" + "\n" +
                        "Total Fat    1 g" + "\n" +
                        "Saturated Fat    0 g" + "\n" +
                        "Polyunsaturated Fat    0.5 g" + "\n" +
                        "Monounsaturated Fat    0 g" + "\n" +
                        "Cholesterol    <5 mg" + "\n" +
                        "Vitamin E (mixed tocopherols)    10 IU" + "\n" +
                        "Omega 3/6/9 Proprietary Blend (non-GMO borage oil, fish oil [sardine and anchovy] and flax oil)    1200 mg" + "\n\nSuggested use\n" +
                        "As a dietary supplement for essential fatty acids, one softgel three times daily."
                        UserDefaults.standard.set(DSDesc, forKey: "Key") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                        print("015")
                    } else if (predictedDS == "016"){
                        self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                        let DSDesc =
                        "title" +
                        "price" + "- \(prediction)" + "\n\n" + "Supplement Facts\n\nServing Size:" +
                        "size" + "\nServings Per Container:" +
                        "servings" + "\n\nAmount Per Serving\n" +
                        "a" + "\n" +
                        "b" + "\n" +
                        "c" + "\n\nSuggested use\n" +
                        "use"
                        UserDefaults.standard.set(DSDesc, forKey: "Key") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                        print("016")
                    } else if (predictedDS == "017"){
                        self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                        let DSDesc =
                        "title" +
                        "price" + "- \(prediction)" + "\n\n" + "Supplement Facts\n\nServing Size:" +
                        "size" + "\nServings Per Container:" +
                        "servings" + "\n\nAmount Per Serving\n" +
                        "a" + "\n" +
                        "b" + "\n" +
                        "c" + "\n\nSuggested use\n" +
                        "use"
                        UserDefaults.standard.set(DSDesc, forKey: "Key") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                        print("017")
                    } else if (predictedDS == "018"){
                        self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                        let DSDesc =
                        "title" +
                        "price" + "- \(prediction)" + "\n\n" + "Supplement Facts\n\nServing Size:" +
                        "size" + "\nServings Per Container:" +
                        "servings" + "\n\nAmount Per Serving\n" +
                        "a" + "\n" +
                        "b" + "\n" +
                        "c" + "\n\nSuggested use\n" +
                        "use"
                        UserDefaults.standard.set(DSDesc, forKey: "Key") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                        print("018")
                    } else if (predictedDS == "019"){
                        self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                        let DSDesc =
                        "title" +
                        "price" + "- \(prediction)" + "\n\n" + "Supplement Facts\n\nServing Size:" +
                        "size" + "\nServings Per Container:" +
                        "servings" + "\n\nAmount Per Serving\n" +
                        "a" + "\n" +
                        "b" + "\n" +
                        "c" + "\n\nSuggested use\n" +
                        "use"
                        UserDefaults.standard.set(DSDesc, forKey: "Key") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                        print("019")
                    } else if (predictedDS == "020"){
                        self.scanned = UserDefaults.standard.bool(forKey: "Key2")
                        let DSDesc =
                        "title" +
                        "price" + "- \(prediction)" + "\n\n" + "Supplement Facts\n\nServing Size:" +
                        "size" + "\nServings Per Container:" +
                        "servings" + "\n\nAmount Per Serving\n" +
                        "a" + "\n" +
                        "b" + "\n" +
                        "c" + "\n\nSuggested use\n" +
                        "use"
                        UserDefaults.standard.set(DSDesc, forKey: "Key") //setObject
                        showScanned()
                        self.scanned = true
                        UserDefaults.standard.set(String(predictedDS), forKey: "DS_ID") //setObject
                        print("020")
                    }
                    print("classify() end")
                }
                
                switch prediction {
                case 100.0...:
                    classify()
                    print("Confidence: 100.0...")
                    break
                case 75.0..<100.0:
                    classify()
                    print("Confidence: 75.0..<100.0...")
                    break
                case 50.0..<75.0:
                    print("Confidence: 50.0..<75.0")
                    break
                case 25.0..<50.0:
                    print("Confidence: 25.0..<50.0")
                    break
                case 10.0..<25.0:
                    print("Confidence: 10.0..<25.0")
                    break
                case 1.0..<10.0:
                    print("Confidence: 1.0..<10.0")
                    break
                case ..<1.0:
                    print("Confidence: ..<1.0")
                    break
                default:
                    print("Confidence: N/A")
                }
                
            }
//            print("DispatchQueue.main.async OK")
        }
//        print("processClassifications OK")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        print("preferredStatusBarStyle OK")
        return .lightContent
    }
}

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
