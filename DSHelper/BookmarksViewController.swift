//
//  CollectionViewController.swift
//  DSHelper
//
//  Created by Cyrus on 21/2/2022.
//

import UIKit

class BookmarksViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        BookmarksView()
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

}

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
        
        func addCardView(txt: String, row: CGFloat, col: CGFloat, imgName: String){
            // View
            let view = UIView()
            view.frame = CGRect(x: 0, y: 0, width: 155, height: 230)
            view.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
            view.layer.cornerRadius = 16
            parent.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.widthAnchor.constraint(equalToConstant: 155).isActive = true
            view.heightAnchor.constraint(equalToConstant: 230).isActive = true
            view.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: (col*172)+31).isActive = true
            view.topAnchor.constraint(equalTo: parent.topAnchor, constant: (1+row)*247).isActive = true
            // Label
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 0, width: 140, height: 80)
            label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            label.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.text = txt
            parent.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.widthAnchor.constraint(equalToConstant: 140).isActive = true
            label.heightAnchor.constraint(equalToConstant: 80).isActive = true
            label.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: (col*172)+43).isActive = true
            label.topAnchor.constraint(equalTo: parent.topAnchor, constant: (row*247)+377.5).isActive = true
            // Image
            let imgSrc:UIImage = UIImage(named: imgName)!
            let img = UIImageView(image: imgSrc)
            img.frame = CGRect(x: 0, y: 0, width: 119, height: 125)
            parent.addSubview(img)
            img.translatesAutoresizingMaskIntoConstraints = false
            img.widthAnchor.constraint(equalToConstant: 119).isActive = true
            img.heightAnchor.constraint(equalToConstant: 125).isActive = true
            img.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: (col*172)+48).isActive = true
            img.topAnchor.constraint(equalTo: parent.topAnchor, constant: (row*247)+251).isActive = true
            
        }
        addCardView(txt: "Sundown Naturals, Calcium, Magnesium & Zinc, 100 Caplets", row: 0, col: 0, imgName: "001")
        addCardView(txt: "Source Naturals, B-50 Complex, 50 mg, 100 Tablets", row: 0, col: 1, imgName: "002")
        addCardView(txt: "Solgar, Magnesium with Vitamin B6, 250 Tablets", row: 1, col: 0, imgName: "003")
        addCardView(txt: "California Gold Nutrition, Ferrochel Iron (Bisglycinate), 36 mg, 90 Veggie Capsules", row: 1, col: 1, imgName: "004")
        
    }
}
