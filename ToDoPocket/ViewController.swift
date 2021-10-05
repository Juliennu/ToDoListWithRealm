//
//  ViewController.swift
//  ToDoPocket
//
//  Created by Juri Ohto on 2021/10/04.
//

import UIKit
import RealmSwift

class ToDoListItem: Object {
    @objc dynamic var item: String = ""
    @objc dynamic var isDone: Bool = false
}


class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var addBarButtonItem: UIBarButtonItem!
    
    var data = [ToDoListItem]()
    let realm = try! Realm()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDataFromRealm()
        tableView.delegate = self
        tableView.dataSource = self
        addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        self.navigationItem.rightBarButtonItem = addBarButtonItem
        tableView.layer.cornerRadius = 20
    }
    
    @objc func addButtonTapped() {
        var alertTextField: UITextField?
        
        let alert = UIAlertController(title: "To Doを入力してください", message: "", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            alertTextField = textField
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
            guard let text = alertTextField?.text, !text.isEmpty else { return }
            
            self.saveItemToRealm(text: text)
            self.fetchDataFromRealm()
        }))
        self.present(alert, animated: true)
    }
    
    
    
    func saveItemToRealm(text: String) {
        realm.beginWrite()
        
        let newItem = ToDoListItem()
        newItem.item = text
        realm.add(newItem)
        try! realm.commitWrite()
    }
    
    func fetchDataFromRealm() {
        data = realm.objects(ToDoListItem.self).map({ $0 })
        tableView.reloadData()
    }
}



extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = data[indexPath.row].item
        
        let attributeString = NSMutableAttributedString(string: data[indexPath.row].item)
        let range = NSMakeRange(0, attributeString.length)
        
        //完了済みセルの文字は灰色＆斜線にする
        if data[indexPath.row].isDone == true {
            cell.tintColor = .systemPink//@色が変わらない
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: range)
            //  打ち消し線も灰色にしたい
//            attributeString.attribute(.strikethroughColor: UIColor.gray, at: 2, effectiveRange: range)
            
        } else {
            attributeString.removeAttribute(.strikethroughStyle, range: range)
            
        }
        content.attributedText = attributeString
        cell.contentConfiguration = content
        return cell
    }
    
    //スワイプで削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! realm.write{
                realm.delete(data[indexPath.row])
            }
        }
        self.data.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    //cell選択時にisDoneのステータスを変更させる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //isDone値の変更
        try! realm.write{
            data[indexPath.row].isDone.toggle()
        }
        //データの更新
        fetchDataFromRealm()
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
}
