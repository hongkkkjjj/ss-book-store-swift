//
//  BookListViewController.swift
//  SS Book Store
//
//  Created by Soft Space User on 30/06/2021.
//

import UIKit

class BookListViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet private var bookListTableView: UITableView!
    @IBOutlet private weak var sortByNameButton: UIButton!
    @IBOutlet private weak var sortByAuthorButton: UIButton!
    @IBOutlet private weak var sortByDateButton: UIButton!
    
    // MARK: - Variable Declaration
    
    internal var fromlogin = false
    private var bookData: [BookDetails] = []
    private var sortType: sortByType = .titleAsc

    // MARK: - Override func
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sortByNameButton.setTitleColor(.red, for: .normal)
        addNavBarItem()
        bookListTableView.delegate = self
        bookListTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getBookList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.bookListToDetail {
            if let vc = segue.destination as? BookDetailsViewController,
               let bookDetail = sender as? BookDetails {
                vc.bookDetail = bookDetail
            }
        }
    }
    
    // MARK: - Private func
    
    private func getBookList() {
        if ConstantValue.refreshTime == nil || ConstantValue.refreshTime?.compare(Date()) == ComparisonResult.orderedAscending {
            
            LoadingScreen.shared.showOverlay(view: self)
            
            FirestoreFunction.getBookDataFromFirestore(completion: { (bookList) in
                Util.runInMainThread {
                    let calendar = Calendar.current
                    if let refreshDate = calendar.date(byAdding: .minute, value: 3, to: Date()){
                        ConstantValue.refreshTime = refreshDate
                    }
                    
                    LoadingScreen.shared.hideOverlay(view: self)
                    
                    self.bookData = bookList
                    self.sortBookList()
                    self.bookListTableView.reloadData()
                }
            })
        }
    }
    
    private func addNavBarItem() {
        let createButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(navBarAddBtn(sender:)))
        
        self.navigationItem.rightBarButtonItem = createButton
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.menuButton(self, action: #selector(navBarLogoutBtn(sender:)), imageName: "ic_logout")
    }
    
    private func showDeleteConfirmation(indexPath: IndexPath, completion: @escaping ((_ revertTableViewCell: Bool) -> ())) {
        let okAction = Util.formAlertAction(title: "OK", style: .default, handlerAction: { _ in
            
            LoadingScreen.shared.showOverlay(view: self)
            FirestoreFunction.deleteBookInFirestore(bookId: self.bookData[indexPath.row].firestoreId, completion: { boolResult in
                Util.runInMainThread {
                    LoadingScreen.shared.hideOverlay(view: self)
                    if boolResult {
                        ConstantValue.refreshTime = nil
                        self.bookData.remove(at: indexPath.row)
                        self.bookListTableView.deleteRows(at: [indexPath], with: .automatic)
                        self.bookListTableView.reloadData()
                        self.getBookList()
                    }
                    completion(boolResult)
                }
            })
        })
        let cancelAction = Util.formAlertAction(title: "Cancel", style: .cancel, handlerAction: { _ in
            completion(false)
        })
        showAlertDialog(message: "Are you sure want to delete this book?", alertActions: [okAction, cancelAction])
    }
    
    private func sortBookList() {
        resetButton(button: sortByNameButton)
        resetButton(button: sortByAuthorButton)
        resetButton(button: sortByDateButton)
        
        switch sortType {
        case .authorAsc:
            sortByAuthorButton.setTitle("Author ↓", for: .normal)
            bookData.sort(by: { $0.authorName.uppercased() < $1.authorName.uppercased() })
        case .authorDesc:
            sortByAuthorButton.setTitle("Author ↑", for: .normal)
            bookData.sort(by: { $0.authorName.uppercased() > $1.authorName.uppercased() })
        case .titleAsc:
            sortByNameButton.setTitle("Title ↓", for: .normal)
            bookData.sort(by: { $0.bookTitle.uppercased() < $1.bookTitle.uppercased() })
        case .titleDesc:
            sortByNameButton.setTitle("Title ↑", for: .normal)
            bookData.sort(by: { $0.bookTitle.uppercased() > $1.bookTitle.uppercased() })
        case .dateAsc:
            sortByDateButton.setTitle("Date ↓", for: .normal)
            bookData.sort(by: { $0.date < $1.date })
        case .dateDesc:
            sortByDateButton.setTitle("Date ↑", for: .normal)
            bookData.sort(by: { $0.date > $1.date })
        }
        bookListTableView.reloadData()
    }
    
    private func resetButton(button: UIButton) {
        var text = ""
        if button == sortByNameButton {
            text = "Title ⇅"
        } else if button == sortByDateButton {
            text = "Date ⇅"
        } else {
            text = "Author ⇅"
        }
        button.setTitle(text, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
    }
    
    // MARK: - Objc func
    
    @objc private func navBarLogoutBtn(sender: UIBarButtonItem) {
        UserDefaultUtil.isUserLogin = false
        ConstantValue.refreshTime = nil
        
        if fromlogin {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            if let loginVC = UIStoryboard(name: "Entry", bundle: nil).instantiateViewController(withIdentifier: "loginVC") as? LoginViewController {
                
                self.present(loginVC, animated: true, completion: nil)
            }
        }
    }
    
    @objc private func navBarAddBtn(sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: StoryboardSegue.bookListToDetail, sender: nil)
    }
    
    // MARK: - IBAction
    
    @IBAction private func sortByTitle() {
        if sortType == .titleAsc {
            sortType = .titleDesc
        } else {
            sortType = .titleAsc
        }
        sortBookList()
    }
    
    @IBAction private func sortByAuthor() {
        if sortType == .authorAsc {
            sortType = .authorDesc
        } else {
            sortType = .authorAsc
        }
        sortBookList()
    }
    
    @IBAction private func sortByDate() {
        if sortType == .dateAsc {
            sortType = .dateDesc
        } else {
            sortType = .dateAsc
        }
        sortBookList()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension BookListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "bookListTableViewCell", for: indexPath) as? BookListTableViewCell {
            
            let row = indexPath.row
            cell.authorLabel.text = "by \(bookData[row].authorName)"
            cell.titleLabel.text = bookData[row].bookTitle
            cell.dateLabel.text = bookData[row].strDate
            cell.bookImageView.image = Util.convertBase64StringToImage(imageBase64String: bookData[row].bookImage)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: StoryboardSegue.bookListToDetail, sender: bookData[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = self.delete(rowIndexPathAt: indexPath)
        let swipe = UISwipeActionsConfiguration(actions: [delete])
        
        return swipe
    }
    
    private func delete(rowIndexPathAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete", handler: { [weak self] (_,_, handler) in
            guard let self = self else {
                return
            }
            
            self.showDeleteConfirmation(indexPath: indexPath, completion: { boolResponse in
                handler(boolResponse)
            })
            
        })
        
        return action
    }
}

extension BookListViewController {
    private enum sortByType {
        case titleAsc, titleDesc, authorAsc, authorDesc, dateAsc, dateDesc
    }
}
