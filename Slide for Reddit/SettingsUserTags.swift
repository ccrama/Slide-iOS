//
//  SettingsUserTags.swift
//  Slide for Reddit
//
//  Created by Carlos Crane on 2/4/19.
//  Copyright © 2019 Haptic Apps. All rights reserved.
//

import Anchorage
import Then
import UIKit

class SettingsUserTags: UITableViewController {
    
    var tags: [String: String] = [:]
    var emptyStateView = EmptyStateView()

    override func viewDidLoad() {
        super.viewDidLoad()
        if !UserDefaults.standard.bool(forKey: "setCcrama") {
            UserDefaults.standard.set("Slide Dev", forKey: "tag+ccrama")
            UserDefaults.standard.set(true, forKey: "setCcrama")
            UserDefaults.standard.synchronize()
        }
        for item in UserDefaults.standard.dictionaryRepresentation().keys.filter({ $0.startsWith("tag+") }) {
           tags[item.split("+")[1]] = UserDefaults.standard.string(forKey: item)
        }
        
        self.view.addSubview(emptyStateView)
        emptyStateView.setText(title: "No User Tags", message: "Add a user tag here or from any user profile.")
        emptyStateView.isHidden = !tags.isEmpty
        emptyStateView.edgeAnchors /==/ self.tableView.edgeAnchors
        
        self.view.bringSubviewToFront(emptyStateView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBaseBarColors()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if UIColor.isLightTheme && SettingValues.reduceColor {
                        if #available(iOS 13, *) {
                return .darkContent
            } else {
                return .default
            }

        } else {
            return .lightContent
        }
    }
    
    func doLayout() {
        setupBaseBarColors()
        
        self.view.backgroundColor = UIColor.backgroundColor
        
        let button = UIButtonWithContext.init(type: .custom)
        button.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        button.setImage(UIImage(sfString: SFSymbol.chevronLeft, overrideString: "back")!.navIcon(), for: UIControl.State.normal)
        button.frame = CGRect.init(x: 0, y: 0, width: 25, height: 25)
        button.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        let barButton = UIBarButtonItem.init(customView: button)
        
        navigationItem.leftBarButtonItem = barButton
    }
    
    @objc public func handleBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = UIColor.backgroundColor
        // set the title
        self.title = "User Tags"
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        self.tableView.register(TagCellView.classForCoder(), forCellReuseIdentifier: "tag")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tag") as! TagCellView
        let tag = tags[indexPath.row]
        cell.setTag(user: tag.key, tag: tag.value)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            UserDefaults.standard.removeObject(forKey: "tag+" + self.tags[indexPath.row].key)
            self.tags.removeValue(forKey: self.tags[indexPath.row].key)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        return [delete]
    }
    
}
class TagCellView: UITableViewCell {
    
    var title: TitleUITextView!
    var body = UIView()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureViews()
        configureLayout()
    }
    
    func configureViews() {
        self.clipsToBounds = true
        
        self.body = UIView().then {
            $0.layer.cornerRadius = 22
            $0.clipsToBounds = true
        }
        
        let layout = BadgeLayoutManager()
        let storage = NSTextStorage()
        storage.addLayoutManager(layout)
        let initialSize = CGSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        let container = NSTextContainer(size: initialSize)
        container.widthTracksTextView = true
        layout.addTextContainer(container)

        self.title = TitleUITextView(delegate: nil, textContainer: container).then {
            $0.doSetup()
        }
        
        self.contentView.addSubview(body)
        self.body.addSubview(title)
    }
    
    func configureLayout() {
        batch {
            body.leftAnchor /==/ contentView.leftAnchor + 8
            body.rightAnchor /==/ contentView.rightAnchor - 8
            body.topAnchor /==/ contentView.topAnchor + 8
            body.bottomAnchor /==/ contentView.bottomAnchor - 8
            
            title.leftAnchor /==/ body.leftAnchor + 16
            title.rightAnchor /==/ body.rightAnchor - 16
            title.centerYAnchor /==/ body.centerYAnchor
        }
    }

    func setTag(user: String, tag: String) {
        
        let attributedTitle = NSMutableAttributedString(string: user, attributes: [NSAttributedString.Key.foregroundColor: UIColor.fontColor, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)])
        if !tag.isEmpty {
            let spacer = NSMutableAttributedString.init(string: "  ")
            
            let tagString = NSMutableAttributedString.init(string: "\u{00A0}\(tag)\u{00A0}", attributes: [NSAttributedString.Key.font: FontGenerator.boldFontOfSize(size: 12, submission: true), .badgeColor: UIColor(rgb: 0x2196f3), NSAttributedString.Key.foregroundColor: UIColor.white])

            attributedTitle.append(spacer)
            attributedTitle.append(tagString)
        }

        title.attributedText = attributedTitle
        title.layoutTitleImageViews()
        
        body.backgroundColor = UIColor.foregroundColor
        self.backgroundColor = UIColor.backgroundColor
    }
}

extension Dictionary {
    subscript(i: Int) -> (key: Key, value: Value) {
        return self[index(startIndex, offsetBy: i)]
    }
}
