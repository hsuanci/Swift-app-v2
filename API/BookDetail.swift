//
//  ViewController.swift
//  API
//
//  Created by hsuanchi on 2019/4/26.
//  Copyright © 2019年 hsuanchi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher


class BookDetail: UIViewController {
    var books = [Book]()
    @IBOutlet weak var ImageBook: UIImageView!
    @IBOutlet weak var BookName: UILabel!
    @IBOutlet weak var OGPrice: UILabel!
    @IBOutlet weak var SGPrice: UILabel!
    @IBOutlet weak var Link: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: books[0].image)!
        ImageBook.kf.setImage(with: url)
        
        BookName.text = "BookTitle : \(self.books[0].name)"
        OGPrice.text = "OrginalPrice : \(self.books[0].originPrice)"
        SGPrice.text = "SalePrice : \(self.books[0].sellPrice)"
        Link.text = "Link : \(self.books[0].link)"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
