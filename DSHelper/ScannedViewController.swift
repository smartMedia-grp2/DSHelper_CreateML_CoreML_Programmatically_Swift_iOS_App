//
//  ScannedViewController.swift
//  DSHelper
//
//  Created by Cyrus on 21/2/2022.
//

import UIKit
import AVFoundation

class ScannedViewController: UIViewController {
    
    var DSDesc2 = UserDefaults.standard.string(forKey: "Key")

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ScannedView()
        
        let utterance = AVSpeechUtterance(string: DSDesc2!)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.25
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    @objc private func toBookmarksView(){ // View present style 2
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "bookmarksView") as? BookmarksViewController else {
            return
        }
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            UserDefaults.standard.set(false, forKey: "Key2") //Bool
        }
    }
    


//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        let controller = segue.destination as? BookmarksViewController
//        // Pass the selected object to the new view controller.
//    }

}

extension ScannedViewController{
    private func ScannedView(){
        
        let parent = self.view!

//        self.view.backgroundColor = UIColor(red: 0xFF/0xFF, green: 0xFF/0xFF, blue: 0xFF/0xFF, alpha: 0)
//        self.view.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor
        self.view.backgroundColor = .clear
        
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 390, height: 800)
        view.layer.backgroundColor = UIColor(red: 1, green: 0.008, blue: 0.4, alpha: 1).cgColor
        view.layer.cornerRadius = 64
        parent.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 390).isActive = true
        view.heightAnchor.constraint(equalToConstant: 800).isActive = true
        view.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: parent.topAnchor, constant: 144).isActive = true
        
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 339, height: 574)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
//        label.font = UIFont.systemFont(ofSize: 18.0)
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = DSDesc2
        parent.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 339).isActive = true
        label.heightAnchor.constraint(equalToConstant: 574).isActive = true
        label.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 25).isActive = true
        label.topAnchor.constraint(equalTo: parent.topAnchor, constant: 115).isActive = true
        
        let voiceIcon = UIButton()
        voiceIcon.setBackgroundImage(UIImage(named: "campaign_black_24dp") , for: .normal)
        voiceIcon.frame = CGRect(x: 0, y: 0, width: 94, height: 94)
//        voiceIcon.addTarget(self, action: #selector(buttonTouchDown), for: .touchUpInside)
        parent.addSubview(voiceIcon)
        voiceIcon.translatesAutoresizingMaskIntoConstraints = false
        voiceIcon.widthAnchor.constraint(equalToConstant: 94).isActive = true
        voiceIcon.heightAnchor.constraint(equalToConstant: 94).isActive = true
        voiceIcon.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 148).isActive = true
        voiceIcon.topAnchor.constraint(equalTo: parent.topAnchor, constant: 738).isActive = true
        
        let dragHandlerIcon = UIImageView(image: UIImage(named: "drag_handle_black_24dp"))
        dragHandlerIcon.frame = CGRect(x: 0, y: 0, width: 87, height: 87)
//        dragHandlerIcon.addTarget(self, action: #selector(buttonTouchDown), for: .touchUpInside)
        parent.addSubview(dragHandlerIcon)
        dragHandlerIcon.translatesAutoresizingMaskIntoConstraints = false
        dragHandlerIcon.widthAnchor.constraint(equalToConstant: 87).isActive = true
        dragHandlerIcon.heightAnchor.constraint(equalToConstant: 87).isActive = true
        dragHandlerIcon.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 151).isActive = true
        dragHandlerIcon.topAnchor.constraint(equalTo: parent.topAnchor, constant: 120).isActive = true
        
        let bookmarksIcon = UIButton()
        bookmarksIcon.setBackgroundImage(UIImage(named: "bookmarks_black_24dp") , for: .normal)
        bookmarksIcon.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        bookmarksIcon.addTarget(self, action: #selector(toBookmarksView), for: .touchUpInside)
        parent.addSubview(bookmarksIcon)
        bookmarksIcon.translatesAutoresizingMaskIntoConstraints = false
        bookmarksIcon.widthAnchor.constraint(equalToConstant: 70).isActive = true
        bookmarksIcon.heightAnchor.constraint(equalToConstant: 70).isActive = true
        bookmarksIcon.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 290).isActive = true
        bookmarksIcon.topAnchor.constraint(equalTo: parent.topAnchor, constant: 35).isActive = true

        let bookmarkIcon = UIButton()
        bookmarkIcon.setBackgroundImage(UIImage(named: "bookmark_border_black_24dp") , for: .normal)
        bookmarkIcon.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
//        bookmarkIcon.addTarget(self, action: #selector(buttonTouchDown), for: .touchUpInside)
        parent.addSubview(bookmarkIcon)
        bookmarkIcon.translatesAutoresizingMaskIntoConstraints = false
        bookmarkIcon.widthAnchor.constraint(equalToConstant: 70).isActive = true
        bookmarkIcon.heightAnchor.constraint(equalToConstant: 70).isActive = true
        bookmarkIcon.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 19).isActive = true
        bookmarkIcon.topAnchor.constraint(equalTo: parent.topAnchor, constant: 35).isActive = true
    }
}
