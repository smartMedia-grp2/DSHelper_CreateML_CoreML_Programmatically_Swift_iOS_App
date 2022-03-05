//
//  CollectionViewController.swift
//  DSHelper
//
//  Created by Cyrus on 21/2/2022.
//

import UIKit

class BookmarksViewController: UIViewController {
    
    // DS description
    var DSDesc2 = UserDefaults.standard.string(forKey: "Key")!
    // DS array
    var DSArray = UserDefaults.standard.stringArray(forKey: "DSArray")!
    var DSDescArray = UserDefaults.standard.stringArray(forKey: "DSDescArray")!

    /* UILayout */
    private let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let scrollStackViewContainer: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 20
        v.distribution = .fillEqually
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isLayoutMarginsRelativeArrangement = true
        v.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 30, bottom: 20, trailing: 30)
        return v
    }()
    /* UILayout end */

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        BookmarksView() /* UILayout */
        
        // Filter out duplicates in an array
        let DSArrayNoDuplicates:Array = Array(Set(DSArray))
        print(DSArrayNoDuplicates)
        let DSDescArrayNoDuplicates:Array = Array(Set(DSDescArray))
        print(DSDescArrayNoDuplicates)
        
        /* UILayout2 */
        // add the scroll view to self.view
        self.view.addSubview(scrollView)
        scrollView.addSubview(scrollStackViewContainer)
        scrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 247).isActive = true
        scrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        scrollStackViewContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        scrollStackViewContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        scrollStackViewContainer.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        scrollStackViewContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        scrollStackViewContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        /* UILayout2 end */
        
        // To find out where the UserDefaults folder is
        let path: [AnyObject] = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true) as [AnyObject]
            let folder: String = path[0] as! String
            NSLog("Your NSUserDefaults are stored in this folder: %@/Preferences", folder)
        
        /* UILayout2 */
        // Add card(s) algorithm
        var ROW = 0
        var COL = 0
        var twoUp = 0
        for i in 0 ..< DSArrayNoDuplicates.count {
            addCard(txt: "\(DSDescArrayNoDuplicates[i])", row: CGFloat(Int(ROW)), col: CGFloat(Int(COL)), imgName: "\(DSArrayNoDuplicates[i])")
            // Using same row twice, then increment
            if (twoUp < 1){
                twoUp = twoUp + 1
            } else {
                ROW = ROW + 1
                twoUp = 0
            }
            // Check Column is 1 or 0
            if (COL == 0){
                COL = COL + 1
            } else {
                COL = 0
            }
        }
        /* UILayout2 end */

    }

    @IBAction private func backToPreviousView(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    /* UILayout2 */
    private func addCard(txt: String, row: CGFloat, col: CGFloat, imgName: String){
        // View
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 200).isActive = true
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollStackViewContainer.addArrangedSubview(view)
        // Label
        let label = UILabel()
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = txt
        view.addSubview(label)
        label.widthAnchor.constraint(equalToConstant: 200).isActive = true
        label.heightAnchor.constraint(equalToConstant: 100).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 75).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        label.translatesAutoresizingMaskIntoConstraints = false
        // Image
        let imgSrc:UIImage = UIImage(named: imgName)!
        let img = UIImageView(image: imgSrc)
        view.addSubview(img)
        img.widthAnchor.constraint(equalToConstant: 119).isActive = true
        img.heightAnchor.constraint(equalToConstant: 125).isActive = true
        img.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 105).isActive = true
        img.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        img.translatesAutoresizingMaskIntoConstraints = false
    }
    /* UILayout2 end */

}

/* UILayout */
extension BookmarksViewController{
    private func BookmarksView(){
        
        let parent = self.view!
        
        self.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
//        self.view.backgroundColor = UIColor(red: 0x03/0xFF, green: 0x36/0xFF, blue: 0xFF/0xFF, alpha: 1)
        self.view.layer.backgroundColor = UIColor(red: 0.012, green: 0.212, blue: 1, alpha: 1).cgColor

        let arrowBackIcon = UIButton()
        arrowBackIcon.setBackgroundImage(UIImage(named: "arrow_back_ios_new_black_24dp"), for: .normal)
        arrowBackIcon.frame = CGRect(x: 0, y: 0, width: 72, height: 72)
        arrowBackIcon.addTarget(self, action: #selector(backToPreviousView(_:)), for: .touchUpInside)
        parent.addSubview(arrowBackIcon)
        arrowBackIcon.translatesAutoresizingMaskIntoConstraints = false
        arrowBackIcon.widthAnchor.constraint(equalToConstant: 72).isActive = true
        arrowBackIcon.heightAnchor.constraint(equalToConstant: 72).isActive = true
        arrowBackIcon.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 31).isActive = true
        arrowBackIcon.topAnchor.constraint(equalTo: parent.topAnchor, constant: 45).isActive = true

        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 204, height: 35)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 28)
        // Line height: 35 pt
        // (identical to box height)
        label.text = "Good Morning"
        parent.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 204).isActive = true
        label.heightAnchor.constraint(equalToConstant: 35).isActive = true
        label.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 154).isActive = true
        label.topAnchor.constraint(equalTo: parent.topAnchor, constant: 100).isActive = true
        
        let btn = UIButton()
        btn.frame = CGRect(x: 0, y: 0, width: 54, height: 30)
        btn.layer.cornerRadius = 15
        btn.layer.borderWidth = 3
        btn.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        btn.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        btn.setTitle("All", for: .normal)
        btn.titleLabel?.font =  UIFont(name: "HelveticaNeue-Bold", size: 15)
//        btn.addTarget(self, action: #selector(backToPreviousView), for: .touchUpInside)
        parent.addSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 54).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        btn.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 31).isActive = true
        btn.topAnchor.constraint(equalTo: parent.topAnchor, constant: 190).isActive = true
        
        let btn2 = UIButton()
        btn2.frame = CGRect(x: 0, y: 0, width: 96, height: 30)
        btn2.layer.cornerRadius = 15
        btn2.layer.borderWidth = 3
        btn2.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        btn2.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        btn2.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        btn2.setTitle("Vitamins", for: .normal)
        btn2.titleLabel?.font =  UIFont(name: "HelveticaNeue-Bold", size: 15)
//        btn.addTarget(self, action: #selector(buttonTouchDown), for: .touchUpInside)
        parent.addSubview(btn2)
        btn2.translatesAutoresizingMaskIntoConstraints = false
        btn2.widthAnchor.constraint(equalToConstant: 96).isActive = true
        btn2.heightAnchor.constraint(equalToConstant: 30).isActive = true
        btn2.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 99).isActive = true
        btn2.topAnchor.constraint(equalTo: parent.topAnchor, constant: 190).isActive = true
        
        let btn3 = UIButton()
        btn3.frame = CGRect(x: 0, y: 0, width: 91, height: 30)
        btn3.layer.cornerRadius = 15
        btn3.layer.borderWidth = 3
        btn3.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        btn3.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        btn3.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        btn3.setTitle("Calcium", for: .normal)
        btn3.titleLabel?.font =  UIFont(name: "HelveticaNeue-Bold", size: 15)
//        btn.addTarget(self, action: #selector(buttonTouchDown), for: .touchUpInside)
        parent.addSubview(btn3)
        btn3.translatesAutoresizingMaskIntoConstraints = false
        btn3.widthAnchor.constraint(equalToConstant: 91).isActive = true
        btn3.heightAnchor.constraint(equalToConstant: 30).isActive = true
        btn3.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 209).isActive = true
        btn3.topAnchor.constraint(equalTo: parent.topAnchor, constant: 190).isActive = true
            
    }
}
/* UILayout end */
