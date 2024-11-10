//
//  ViewController.swift
//  SparrowMarathon-UIKIt-MixerTable
//
//  Created by Sergey Leontiev on 10.11.24..
//

import UIKit

class ViewController: UIViewController {
    private var items: [ItemViewModel] = (0...40).map { ItemViewModel(title: String($0), isSelected: false) }
    
    private var dataSource: UITableViewDiffableDataSource<Section, ItemViewModel.ID>?
    private lazy var mixerTable: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.register(Cell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTableView()
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard var snapshot = dataSource?.snapshot() else { return }
        items[indexPath.row].isSelected.toggle()
        snapshot.reloadItems([items[indexPath.row].id])
        
        guard items[indexPath.row].isSelected else {
            dataSource?.apply(snapshot)
            return
        }
        
        guard let firstItem = items.first else { return }
        let item = items.remove(at: indexPath.row)
        items.insert(item, at: 0)
        snapshot.moveItem(item.id, beforeItem: firstItem.id)
        
        dataSource?.apply(snapshot)
    }
}

private extension ViewController {
    func setupViews() {
        title = "Mixer Table"
        view.addSubview(mixerTable)
        
        NSLayoutConstraint.activate([
            mixerTable.topAnchor.constraint(equalTo: view.topAnchor),
            mixerTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mixerTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mixerTable.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Shuffle", image: nil, target: self, action: #selector(shuffle))
    }
    
    func setupTableView() {
        dataSource = UITableViewDiffableDataSource<Section, ItemViewModel.ID>(tableView: mixerTable) { tableView, indexPath, id in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            guard let item = self.items.first(where: { $0.id == id }) else { return UITableViewCell() }
            cell.textLabel?.text = item.title
            cell.accessoryType = item.isSelected ? .checkmark : .none
            return cell
        }
        
        var originalSnaphot = NSDiffableDataSourceSnapshot<Section, ItemViewModel.ID>()
        originalSnaphot.appendSections([.main])
        originalSnaphot.appendItems(items.map(\.id), toSection: .main)
        
        dataSource?.apply(originalSnaphot)
    }
    
    @objc func shuffle() {
        guard var snapshot = dataSource?.snapshot() else { return }
        snapshot.deleteItems(items.map(\.id))
        let shuffledItems = items.shuffled()
        snapshot.appendItems(shuffledItems.map(\.id))
        dataSource?.apply(snapshot)
    }
}

enum Section {
    case main
}

struct ItemViewModel: Identifiable {
    let id = UUID()
    let title: String
    var isSelected: Bool
}

class Cell: UITableViewCell {
    
}