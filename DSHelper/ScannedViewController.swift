//
//  ScannedViewController.swift
//  DSHelper
//
//  Created by Cyrus on 21/2/2022.
//

import UIKit
import AVFoundation /* Voice */

class ScannedViewController: UIViewController {
    
    var DSName = UserDefaults.standard.string(forKey: "DSName") ?? "Welcome to DS Helper!"
    var DSDesc = UserDefaults.standard.string(forKey: "DSDesc") ?? "Welcome to DS Helper!"
    var DS_ID = UserDefaults.standard.string(forKey: "DS_ID") ?? "000"
    /* Voice2 */
    var voiceIcon = UIButton()
    let synthesizer = AVSpeechSynthesizer()
    /* Voice2 end */
    // Bookmark
    let bookmarkIcon = UIButton()
    let bookmarksIcon = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ScannedView() /* UILayout */
        
        // If DSArray does not exist
        guard (UserDefaults.standard.array(forKey: "DSArray") != nil) else {
            return bookmarksIcon.isEnabled = false
        }
        
        synthesizer.delegate = self /* Voice2 */
    }
    
    // Button action(s)
    @objc private func toBookmarksView(){ // View present style 2
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "bookmarksView") as? BookmarksViewController else {
            return
        }
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    @objc private func bookmark(){
        bookmarkIcon.isEnabled = false
        if var DSArray = UserDefaults.standard.array(forKey: "DSArray") {
            //To add a new element to the end of an Array.
            DSArray.append(DS_ID)
            UserDefaults.standard.set(DSArray, forKey: "DSArray") //setObject
            print(DSArray)
        } else {
            UserDefaults.standard.set([DS_ID], forKey: "DSArray") //setObject
            print([DS_ID])
        }
        
        if var DSNameArray = UserDefaults.standard.array(forKey: "DSNameArray") {
            //To add a new element to the end of an Array.
            DSNameArray.append(DSName)
            UserDefaults.standard.set(DSNameArray, forKey: "DSNameArray") //setObject
            print(DSNameArray)
        } else {
            UserDefaults.standard.set([DSName], forKey: "DSNameArray") //setObject
            print([DSName])
        }
        bookmarksIcon.isEnabled = true
    }
    /* Voice */
    @objc private func textToSpeech(){
        voiceIcon.isEnabled = false
        let utterance = AVSpeechUtterance(string: DSDesc)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.25
        synthesizer.speak(utterance)
    }
    /* Voice end */
    
    // When the user close this view
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            UserDefaults.standard.set(false, forKey: "Scanned") //Bool
            bookmarkIcon.isEnabled = true
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

/* UILayout */
extension ScannedViewController{
    private func ScannedView(){
        
        let parent = self.view!

//        self.view.backgroundColor = UIColor(red: 0xFF/0xFF, green: 0xFF/0xFF, blue: 0xFF/0xFF, alpha: 0)
//        self.view.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor
        self.view.backgroundColor = .clear
        
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 390, height: 830)
        view.layer.backgroundColor = UIColor(red: 1, green: 0.008, blue: 0.4, alpha: 1).cgColor
        view.layer.cornerRadius = 64
        parent.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 390).isActive = true
        view.heightAnchor.constraint(equalToConstant: 830).isActive = true
        view.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: parent.topAnchor, constant: 60).isActive = true
        
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 360, height: 570)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
//        label.font = UIFont.systemFont(ofSize: 18.0)
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = DSDesc
        parent.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 360).isActive = true
        label.heightAnchor.constraint(equalToConstant: 570).isActive = true
        label.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 20).isActive = true
        label.topAnchor.constraint(equalTo: parent.topAnchor, constant: 75).isActive = true
        
        voiceIcon.setBackgroundImage(UIImage(named: "campaign_black_24dp") , for: .normal)
        voiceIcon.frame = CGRect(x: 0, y: 0, width: 94, height: 94)
        voiceIcon.addTarget(self, action: #selector(textToSpeech), for: .touchUpInside)
        parent.addSubview(voiceIcon)
        voiceIcon.translatesAutoresizingMaskIntoConstraints = false
        voiceIcon.widthAnchor.constraint(equalToConstant: 94).isActive = true
        voiceIcon.heightAnchor.constraint(equalToConstant: 94).isActive = true
        voiceIcon.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 148).isActive = true
        voiceIcon.topAnchor.constraint(equalTo: parent.topAnchor, constant: 660).isActive = true
        
        let dragHandlerIcon = UIImageView(image: UIImage(named: "drag_handle_black_24dp"))
        dragHandlerIcon.frame = CGRect(x: 0, y: 0, width: 87, height: 87)
//        dragHandlerIcon.addTarget(self, action: #selector(buttonTouchDown), for: .touchUpInside)
        parent.addSubview(dragHandlerIcon)
        dragHandlerIcon.translatesAutoresizingMaskIntoConstraints = false
        dragHandlerIcon.widthAnchor.constraint(equalToConstant: 87).isActive = true
        dragHandlerIcon.heightAnchor.constraint(equalToConstant: 87).isActive = true
        dragHandlerIcon.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 151).isActive = true
        dragHandlerIcon.topAnchor.constraint(equalTo: parent.topAnchor, constant: 35).isActive = true
        
        bookmarksIcon.setBackgroundImage(UIImage(named: "bookmarks_black_24dp") , for: .normal)
        bookmarksIcon.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        bookmarksIcon.addTarget(self, action: #selector(toBookmarksView), for: .touchUpInside)
        parent.addSubview(bookmarksIcon)
        bookmarksIcon.translatesAutoresizingMaskIntoConstraints = false
        bookmarksIcon.widthAnchor.constraint(equalToConstant: 70).isActive = true
        bookmarksIcon.heightAnchor.constraint(equalToConstant: 70).isActive = true
        bookmarksIcon.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 290).isActive = true
        bookmarksIcon.topAnchor.constraint(equalTo: parent.topAnchor, constant: -7.5).isActive = true

        bookmarkIcon.setBackgroundImage(UIImage(named: "bookmark_border_black_24dp") , for: .normal)
        bookmarkIcon.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        bookmarkIcon.addTarget(self, action: #selector(bookmark), for: .touchUpInside)
        parent.addSubview(bookmarkIcon)
        bookmarkIcon.translatesAutoresizingMaskIntoConstraints = false
        bookmarkIcon.widthAnchor.constraint(equalToConstant: 70).isActive = true
        bookmarkIcon.heightAnchor.constraint(equalToConstant: 70).isActive = true
        bookmarkIcon.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 19).isActive = true
        bookmarkIcon.topAnchor.constraint(equalTo: parent.topAnchor, constant: -7.5).isActive = true
    }
}
/* UILayout end */

/* Voice2 */
extension ScannedViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        //Speaking is done, enable speech UI for next round
        voiceIcon.isEnabled = true
    }
}
/* Voice2 end */
