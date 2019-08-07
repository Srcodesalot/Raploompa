//
//  ViewController.swift
//  Aloompa task
//
//  Created by Aidan Gutierrez on 8/1/19.
//  Copyright © 2019 Aidan Gutierrez. All rights reserved.
//
import UIKit
import CoreData

struct Artists: Decodable{
    let artists: [Wrapper]
}
struct Wrapper: Decodable{
    let id: String
    let name: String
    let description: String
    let image: String
}

class ViewController: UIViewController, UISearchBarDelegate{
    
    var buttons: [UIButton] = []
    var carryId: String = " "
    var carryName: String = ""
    var carryDescription: String = ""
    var carryImage: UIImage? = nil
    var noContent: UILabel = UILabel()
    var offline = false
    var search: UISearchBar = UISearchBar()
    var wrappers: [Wrapper] = []

    //components
    var stackview: UIStackView = {
        var stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        stack.axis = .vertical
        stack.spacing = 40
        return stack
    }()
    
    //creates individual buttons that will work as stacks
    func createButtons(){
        for rapper in  wrappers{
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
            button.setBackgroundImage(parsePhoto(urlString: rapper.image), for: .normal)
            button.setTitle(rapper.name, for: .normal)
            button.addTarget(self, action: #selector(handelButton), for: .touchUpInside)
            button.titleLabel?.backgroundColor = .init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
            button.contentMode = .scaleAspectFill
            button.clipsToBounds = true
            buttons.append(button)
        }
        loadstacks()
    }
    
    // creates each individual stack viewpiece so if there are more rappers added to the list you do not have to make more individual views for each individual one
    func loadstacks (){
        view.addSubview(stackview)
        stackview.heightAnchor.constraint(equalToConstant: view.frame.height - 200).isActive = true
        stackview.widthAnchor.constraint(equalToConstant: view.frame.width - 40).isActive = true
        stackview.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackview.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noContent.text = "Sorry! No Rapper Found"
        noContent.textAlignment = .center
        noContent.textColor = .darkGray
        noContent.isHidden = true
        stackview.addArrangedSubview(noContent)
        for button in buttons{
            button.imageView?.contentMode = .scaleAspectFill
            button.subviews.first?.contentMode = .scaleAspectFill
            stackview.addArrangedSubview(button)
        }
    }
    
    //retrieves json information and caches it
    func parseJson() {
        guard let appDeli = UIApplication.shared.delegate as? AppDelegate else {return}
        let container = appDeli.persistentContainer.viewContext
        let rapperEntity = NSEntityDescription.entity(forEntityName: "Rapper", in: container )!
        //offline check meathod 1
        //if the device is offline this pulls data from the cache and populates a list
        if offline == true{
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Rapper")
            do{
                let fetched = try container.fetch(fetch)
                for data in fetched as! [NSManagedObject]{
                    let rapper = Wrapper.init(id: data.value(forKey: "id") as! String, name: data.value(forKey: "name") as! String, description: data.value(forKey: "about") as! String, image: data.value(forKey: "image") as! String)
                    wrappers.append(rapper)
                    offline = true
                    createButtons()
                }
            }catch let error{
                print(error)
            }
        }
        // however if it is online it will initially pull the json to check for updates
        else{
            let rapperJson = "http://assets.aloompa.com.s3.amazonaws.com/rappers/rappers.json"
            guard let url = URL(string: rapperJson) else {return}
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {print(error)}
                guard let data = data else {return}
                do{
                    let rappers = try JSONDecoder().decode(Artists.self, from: data)
                    self.wrappers.append(contentsOf: rappers.artists)
                }catch let err{
                    print (err)
                }
                }
                .resume()
  
            //cache data
            for x in wrappers{
                let rapper  = NSManagedObject(entity: rapperEntity , insertInto: container)
                rapper.setValue( x.name, forKey: "name")
                rapper.setValue( x.id, forKey: "id")
                rapper.setValue( x.image, forKey: "image")
                rapper.setValue( x.description, forKey: "about")
            }
            do{
                try container.save()
            }catch let error{
                print(error)
            }
        }
    }
    
    func parsePhoto(urlString : String ) -> UIImage {
        // first the code attempts to hit the json to get the most up to date data but if that fails(aka offline) it pulls frome the cache
        guard let appDeli = UIApplication.shared.delegate as? AppDelegate else {return #imageLiteral(resourceName: "Image") }
        let container = appDeli.persistentContainer.viewContext
        let rapperPicEntity = NSEntityDescription.entity(forEntityName: "RapperPic", in: container )!
            let rapperPic  = NSManagedObject(entity: rapperPicEntity , insertInto: container)
            if let url = URL(string: urlString){
                breakPoint: do{
                    let data = try Data (contentsOf: url)
                    guard let rapImg: UIImage = UIImage(data: data) else { break breakPoint}
                    rapperPic.setValue(urlString, forKey: "name")
                    rapperPic.setValue(rapImg.jpegData(compressionQuality: 1), forKey: "data")
                    try container.save()
                    return (rapImg)
                }catch let error{
                    print(error)
                    offline = true
                }
                if  offline == true {
                let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "RapperPic")
                reakPoint: do{
                    let fetched = try container.fetch(fetch)
                    for data in fetched as! [NSManagedObject]{
                        if data.value(forKey: "name") as! String == urlString{
                            let data = data.value(forKey: "data")
                            guard let rapImg: UIImage = UIImage(data: data as! Data) else {break reakPoint}
                            return (rapImg)
                        }
                    }
                }catch let error{
                    print(error)
                }
                }
            }
        return( #imageLiteral(resourceName: "Image-1"))
    }
    
    // functional functions
    @objc func handelButton(sender: UIButton){
        for rapper in wrappers {
            if rapper.name == sender.titleLabel?.text{
                carryName = rapper.name
                carryDescription = rapper.description
                carryImage = sender.currentBackgroundImage
            }
        }
        let RVC = RapperViewController()
        RVC.Name = carryName
        RVC.Image = carryImage
        RVC.Description = carryDescription
        self.present(RVC, animated: true, completion: nil)
    }
    
    func searchBar(_ search: UISearchBar, textDidChange textSearched: String){
        var hidden = 0
        for button in buttons{
            if textSearched == ""{
                noContent.isHidden = true
                button.isHidden = false
            }
            else if !(button.titleLabel?.text?.contains(textSearched) ?? false) {
                noContent.isHidden = true
                button.isHidden = true
                hidden = hidden + 1
            }
            else {
                noContent.isHidden = true
                button.isHidden = false
                hidden = hidden - 1
            }
        }
        if hidden == buttons.count{
            noContent.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parseJson()
        
        //subviews
        search = UISearchBar(frame: CGRect(x: 0, y: 30, width: view.frame.width, height: 0))
        search.searchBarStyle = .minimal
        search.barStyle = .blackOpaque
        search.backgroundColor = .white
        search.placeholder = ("Finda Wrapper")
        search.sizeToFit()
        search.delegate = self
        view.addSubview(stackview)
        view.addSubview(search)
        
        //logic
        var x = 0
        var y = 0
        while x<1{
            y = y+1
            //this works as a timer while the json is parsing and populating the wrappers array
            if y == 5000 {
                print("error loading json")
                offline = true
                //createButtons()
                x = 1
            }
            if wrappers.count != 0{
                createButtons()
            }
            if wrappers.count == 5 {
                x = 1
            }
        }
    }
}

