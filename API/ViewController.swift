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

struct Book {
    var image:String
    var originPrice:Int
    var sellPrice:Int
    var name:String
    var link:String
    var ISBN:Int
    
    init(json:JSON){
        self.image = json["image"].stringValue
        self.originPrice = json["originPrice"].intValue
        self.sellPrice = json["sellPrice"].intValue
        self.name = json["name"].stringValue
        self.link = json["link"].stringValue
        self.ISBN = json["ISBN"].intValue
    }
}
extension Book: Hashable {
    static func == (lhs: Book, rhs: Book) -> Bool {
        return lhs.image == rhs.image &&
            lhs.originPrice == rhs.originPrice &&
            lhs.sellPrice == rhs.sellPrice &&
            lhs.name == rhs.name &&
            lhs.link == rhs.link &&
            lhs.ISBN == rhs.ISBN
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(image)
        hasher.combine(originPrice)
        hasher.combine(sellPrice)
        hasher.combine(name)
        hasher.combine(link)
        hasher.combine(ISBN)
    }
}

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UISearchBarDelegate,UISearchControllerDelegate {
    
    var fullScreenSize :CGSize! = UIScreen.main.bounds.size
    @IBOutlet weak var MyCollection: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    var searchController: UISearchController!
    
    //ParseJSONData from API
    var bookshelfUrl="https://bookshelf.goodideas-studio.com/api"
    var books = [Book]()
    var searchBook = [Book]()
    var selectBook = [Book]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "BookInfo", bundle: nil)
        self.MyCollection.register(nib, forCellWithReuseIdentifier: "MyCell")
        self.getBooks()
        
        if #available(iOS 11.0, *) {
            self.configureSearchController()
        } else {
            // Fallback on earlier versions
        }
        
        // 設置底色
        self.view.backgroundColor = UIColor.white
        
        // 註冊 cell 以供後續重複使用
        //MyCollection.register(BookInfo.self, forCellWithReuseIdentifier: "MyCell")
        // 設置委任對象
        MyCollection.delegate = self
        MyCollection.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
        self.view.addSubview(MyCollection)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.searchBook.isEmpty{
            return self.books.count
        }
        else{
            return self.searchBook.count
        }
    }
    
    // 必須實作的方法：每個 cell 要顯示的內容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 依據前面註冊設置的識別名稱 "Cell" 取得目前使用的 cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! BookInfo
        // 設置 cell 內容 (即自定義元件裡 增加的圖片與文字元件)
        if self.searchBook.isEmpty{
            let url = URL(string:self.books[indexPath.item].image)
            cell.BookImage.kf.setImage(with: url)
            cell.BookTitle.text = "SalePrice: \(self.books[indexPath.item].sellPrice)"
        }
        else{
            let url = URL(string:self.searchBook[indexPath.item].image)
            cell.BookImage.kf.setImage(with: url)
            cell.BookTitle.text = "SalePrice: \(self.searchBook[indexPath.item].sellPrice)"
        }
        
        return cell
    }
    
    // 有幾個 section
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.searchBook.isEmpty{
            selectBook = [books[indexPath.row]]
            performSegue(withIdentifier: "BookDetail", sender: self)
        }
        else{
            selectBook = [searchBook[indexPath.row]]
            performSegue(withIdentifier: "BookDetail", sender: self)
        }
    }
    
    
    //GET BookInfo
    func getBooks() {
        LoadingOverlay.shared.showOverlay(view:self.view)
        guard let url = URL(string: bookshelfUrl) else { return }
        Alamofire.request(url).validate().responseJSON { (response) in
            LoadingOverlay.shared.hideOverlayView()
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                //var books = [Book]()
                // 獲取我們 list Array
                let list = json["list"].arrayValue
                // 創建一個 [Book] 來存放獲取的 Array
                for bookJson in list {
                    // 實例化一個 Book，並透過 bookJson 初始化它
                    let book = Book(json: bookJson)
                    // 加到上面 books 中
                    self.books.append(book)
                    //let deduplicationBooks = Array(Set(self.books))
                    //self.MyCollection.reloadData()
                    //print(self.books)
                }
            //print(self.books)
            case .failure(let error):
                print(error)
            }
            let deduplicationBooks = Array(Set(self.books))
            self.MyCollection.reloadData()
            print("原有資料數目：\(self.books.count)")
            print("去重資料書目：\(deduplicationBooks.count)")
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @available(iOS 11.0, *)
    func configureSearchController() {
        // 實例化 UISearchController
        searchController = UISearchController(searchResultsController: nil)
        // 將 delegate 設為 self，之後會使用 UISearchResultsUpdater 的方法
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "搜尋書名..."
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barTintColor = .white
        // 搜尋時是否隱藏 NavigationBar
        searchController.hidesNavigationBarDuringPresentation = false
        // 搜尋期間底層是否變暗
        searchController.dimsBackgroundDuringPresentation = false
        // 將 navigationItem.searchController 設置為我們的 searchController
        navigationItem.searchController = searchController
    }
}
extension ViewController : UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        // 獲取 searchBar 中的 text
        if let text = searchController.searchBar.text {
            // 將 books 中的 book.name 是否包含我們輸入的文字
            // 若為 true 則加入到我們的 searchBooks
            searchBook = books.filter({ (book) -> Bool in
                // 這邊加上 lowercased() 將我們的文字都換成英文小寫
                return book.name.lowercased().contains(text.lowercased())
            })
        }
        self.MyCollection.reloadData()
    }
    //Diffrerent viewContronller pass data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! BookDetail //BookDetail >> seque ID
        controller.books = self.selectBook
    }
}
