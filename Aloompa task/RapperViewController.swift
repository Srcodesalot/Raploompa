//
//  RapperViewController.swift
//  Aloompa task
//
//  Created by Aidan Gutierrez on 8/5/19.
//  Copyright © 2019 Aidan Gutierrez. All rights reserved.
//

import Foundation
import UIKit
class RapperViewController: UIViewController {
    var Name: String?
    var Description: String?
    var Image: UIImage?
    
    @objc func backAction (sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        
        let rapperPic = UIImageView(image: Image)
        rapperPic.clipsToBounds = true
        rapperPic.frame = CGRect(x: view.center.x - 175, y: view.frame.height/10, width: 350, height: 350)
        rapperPic.contentMode = .scaleAspectFill
         view.addSubview(rapperPic)
        
        let rapperName = UILabel(frame: CGRect(x:view.center.x - 100, y: rapperPic.center.y + 200, width: 200,height: 21))
        rapperName.text = Name
        rapperName.textAlignment = .center
        view.addSubview(rapperName)
        
        let rapperDescription = UILabel(frame: CGRect(x:view.center.x - 175, y: rapperPic.center.y + 200, width: 350,height: 200))
        rapperDescription.text = Description
        rapperDescription.textAlignment = .natural
        rapperDescription.numberOfLines = 0
        rapperDescription.clipsToBounds = false
        view.addSubview(rapperDescription)
        
        let back = UIButton(frame: CGRect(x:20, y: 20, width: 100,height: 50))
        back.setTitle("< Back", for: .normal)
        back.setTitleColor(.blue, for: .normal)
        back.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        view.addSubview(back)
    }
    
}
