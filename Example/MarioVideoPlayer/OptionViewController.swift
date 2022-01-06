//
//  OptionViewController.swift
//  MarioVideoPlayer_Example
//
//  Created by Ouch Kemvanra on 1/6/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
protocol PlayerOptionSelectionDelegate: NSObject{
    func optionSelected(_ option: PlayerOption)
}
class PlayerOption{
    var id: String
    var icon: UIImage
    var title: String
    init(id : String, icon: UIImage, title: String){
        self.id = id
        self.icon = icon
        self.title = title
    }
}
class OptionViewController: UIViewController{
    private lazy var tableView: UITableView = {
        let tb = UITableView.init(frame: .zero)
        tb.backgroundColor = .white
        tb.register(OptionCell.self, forCellReuseIdentifier: "cell")
        tb.dataSource = self
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.separatorStyle = .none
        return tb
    }()
    private lazy var titleLabel: UILabel = {
        let lb = UILabel.init(frame: .zero)
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.font = lb.font.withSize(14)
        lb.textColor = .black
        lb.text = "Please select an option"
        lb.backgroundColor = .white
        return lb
    }()
    var data: [PlayerOption] = []
    weak var delegate: PlayerOptionSelectionDelegate?
    init(data: [PlayerOption]){
        super.init(nibName: nil, bundle: nil)
        self.data = data
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        let height: CGFloat = CGFloat(data.count * 40)
        view.addSubview(tableView)
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: height),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.topAnchor.constraint(lessThanOrEqualTo: view.centerYAnchor, constant: 50),
            
            titleLabel.bottomAnchor.constraint(equalTo: tableView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension OptionViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! OptionCell
        cell.setData(data[indexPath.row])
        return cell
    }
}
extension OptionViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: {
            self.delegate?.optionSelected(self.data[indexPath.row])
        })
    }
}

class OptionCell: UITableViewCell{

    private lazy var iconImageView: UIImageView = {
        let imv = UIImageView.init(frame: .zero)
        imv.contentMode = .scaleAspectFit
        imv.translatesAutoresizingMaskIntoConstraints = false
        imv.layer.cornerRadius = 15
        return imv
    }()
    
    private lazy var title: UITextView = {
        let txv = UITextView.init(frame: .zero)
        txv.allowsEditingTextAttributes = false
        txv.isEditable = false
        txv.isSelectable = false
        txv.isScrollEnabled = false
        txv.font = txv.font?.withSize(12)
        txv.textAlignment = .left
        txv.isUserInteractionEnabled = false
        txv.translatesAutoresizingMaskIntoConstraints = false
        txv.backgroundColor = .clear
        return txv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .gray
        setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func setData(_ data: PlayerOption){
        self.iconImageView.image = data.icon
        self.title.text = data.title
    }
    private func setView(){
        contentView.addSubview(iconImageView)
        contentView.addSubview(title)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            
            title.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 20),
            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
}

