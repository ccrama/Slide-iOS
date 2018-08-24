//
//  SettingsGeneral.swift
//  Slide for Reddit
//
//  Created by Carlos Crane on 6/17/17.
//  Copyright © 2017 Haptic Apps. All rights reserved.
//

import reddift
import UIKit
import XLActionController

class SettingsLayout: UITableViewController {
    
    var imageCell: UITableViewCell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "image")
    
    var cardModeCell: UITableViewCell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "mode")
    
    var actionBarCell: UITableViewCell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "mode") // TODO: Should this have a different reuseIdentifier?

    var flatModeCell: UITableViewCell = UITableViewCell()
    var flatMode = UISwitch()

    var largerThumbnailCell: UITableViewCell = UITableViewCell()
    var largerThumbnail = UISwitch()
    
    var thumbLinkCell: UITableViewCell = UITableViewCell()
    var thumbLink = UISwitch()

    var scoreTitleCell: UITableViewCell = UITableViewCell()
    var scoreTitle = UISwitch()
    
    var commentTitleCell: UITableViewCell = UITableViewCell()
    var commentTitle = UISwitch()

    var infoBelowTitleCell: UITableViewCell = UITableViewCell()
    var infoBelowTitle = UISwitch()

    var abbreviateScoreCell: UITableViewCell = UITableViewCell()
    var abbreviateScore = UISwitch()
    
    var domainInfoCell: UITableViewCell = UITableViewCell()
    var domainInfo = UISwitch()
    
    var leftThumbCell: UITableViewCell = UITableViewCell()
    var leftThumb = UISwitch()
    
    var hideCell: UITableViewCell = UITableViewCell()
    var hide = UISwitch()
    
    var saveCell: UITableViewCell = UITableViewCell()
    var save = UISwitch()
    
    var selftextCell: UITableViewCell = UITableViewCell()
    var selftext = UISwitch()
    
    var smalltagCell: UITableViewCell = UITableViewCell()
    var smalltag = UISwitch()
    
    var linkCell = UITableViewCell()
    
    var link = LinkCellView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBaseBarColors()
    }
    
    func switchIsChanged(_ changed: UISwitch) {
        if changed == smalltag {
            SettingValues.smallerTag = changed.isOn
            UserDefaults.standard.set(changed.isOn, forKey: SettingValues.pref_smallTag)
        } else if changed == selftext {
            SettingValues.showFirstParagraph = changed.isOn
            UserDefaults.standard.set(changed.isOn, forKey: SettingValues.pref_showFirstParagraph)
        } else if changed == largerThumbnail {
            SettingValues.largerThumbnail = changed.isOn
            UserDefaults.standard.set(changed.isOn, forKey: SettingValues.pref_largerThumbnail)
        } else if changed == infoBelowTitle {
            SettingValues.infoBelowTitle = changed.isOn
            UserDefaults.standard.set(changed.isOn, forKey: SettingValues.pref_infoBelowTitle)
            CachedTitle.titles.removeAll()
        } else if changed == abbreviateScore {
            SettingValues.abbreviateScores = changed.isOn
            UserDefaults.standard.set(changed.isOn, forKey: SettingValues.pref_abbreviateScores)
        } else if changed == scoreTitle {
            SettingValues.scoreInTitle = changed.isOn
            UserDefaults.standard.set(changed.isOn, forKey: SettingValues.pref_scoreInTitle)
        } else if changed == commentTitle {
            SettingValues.commentsInTitle = changed.isOn
            UserDefaults.standard.set(changed.isOn, forKey: SettingValues.pref_commentsInTitle)
        } else if changed == thumbLink {
            SettingValues.linkAlwaysThumbnail = changed.isOn
            UserDefaults.standard.set(changed.isOn, forKey: SettingValues.pref_linkAlwaysThumbnail)
        } else if changed == domainInfo {
            SettingValues.domainInInfo = changed.isOn
            UserDefaults.standard.set(changed.isOn, forKey: SettingValues.pref_domainInInfo)
        } else if changed == leftThumb {
            SettingValues.leftThumbnail = changed.isOn
            UserDefaults.standard.set(changed.isOn, forKey: SettingValues.pref_leftThumbnail)
        } else if changed == hide {
            SettingValues.hideButton = changed.isOn
            UserDefaults.standard.set(changed.isOn, forKey: SettingValues.pref_hideButton)
        } else if changed == save {
            SettingValues.saveButton = changed.isOn
            UserDefaults.standard.set(changed.isOn, forKey: SettingValues.pref_saveButton)
        } else if changed == flatMode {
            SettingValues.flatMode = changed.isOn
            UserDefaults.standard.set(changed.isOn, forKey: SettingValues.pref_flatMode)
            SingleSubredditViewController.cellVersion += 1
            SubredditReorderViewController.changed = true
        }
        UserDefaults.standard.synchronize()
        doDisables()
        doLink()
        tableView.reloadData()
    }
    
    func doLink() {
        link.contentView.removeFromSuperview()
        if SettingValues.postImageMode == .THUMBNAIL || SettingValues.linkAlwaysThumbnail {
            link = ThumbnailLinkCellView.init(frame: CGRect.init(x: 0, y: 0, width: self.tableView.frame.size.width, height: 500))
        } else {
            link = BannerLinkCellView.init(frame: CGRect.init(x: 0, y: 0, width: self.tableView.frame.size.width, height: 500))
        }
        
        let fakesub = RSubmission.init()
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let now: NSDate! = NSDate()
        
        let date0 = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now as Date, options: NSCalendar.Options.matchFirst)!
        
        fakesub.id = "234"
        fakesub.name = "234"
        fakesub.author = "ccrama"
        fakesub.created = date0 as NSDate
        fakesub.edited = NSDate(timeIntervalSince1970: 1)
        fakesub.gilded = 0
        fakesub.htmlBody = ""
        fakesub.body = ""
        fakesub.title = "Chameleons are cool!"
        fakesub.subreddit = "all"
        fakesub.archived = false
        fakesub.locked = false
        fakesub.urlString = "http://i.imgur.com/mAs9Lk3.png"
        fakesub.distinguished = ""
        fakesub.isEdited = false
        fakesub.commentCount = 42
        fakesub.saved = false
        fakesub.stickied = false
        fakesub.visited = false
        fakesub.isSelf = false
        fakesub.permalink = ""
        fakesub.bannerUrl = "http://i.imgur.com/mAs9Lk3.png"
        fakesub.thumbnailUrl = "http://i.imgur.com/mAs9Lk3s.png"
        fakesub.lqUrl = "http://i.imgur.com/mAs9Lk3m.png"
        fakesub.lQ = false
        fakesub.thumbnail = true
        fakesub.banner = true
        fakesub.score = 52314
        fakesub.flair = "Cool!"
        fakesub.domain = "imgur.com"
        fakesub.voted = false
        fakesub.height = 288
        fakesub.width = 636
        fakesub.vote = false
        
        link.aspectWidth = self.tableView.frame.size.width
        self.link.configure(submission: fakesub, parent: MediaViewController(), nav: nil, baseSub: "all", test: true)
        self.link.isUserInteractionEnabled = false
        linkCell.contentView.backgroundColor = ColorUtil.backgroundColor
        link.contentView.frame = CGRect.init(x: 0, y: 0, width: self.tableView.frame.size.width, height: link.estimateHeight(false, true))
        linkCell.contentView.addSubview(link.contentView)
        linkCell.frame = CGRect.init(x: 0, y: 0, width: self.tableView.frame.size.width, height: link.estimateHeight(false, true))
        
        switch SettingValues.postViewMode {
        case .CARD:
            cardModeCell.imageView?.image = UIImage.init(named: "card")?.toolbarIcon()
        case .CENTER:
            cardModeCell.imageView?.image = UIImage.init(named: "centeredimage")?.toolbarIcon()
        case .COMPACT:
            cardModeCell.imageView?.image = UIImage.init(named: "compact")?.toolbarIcon()
        case .LIST:
            cardModeCell.imageView?.image = UIImage.init(named: "list")?.toolbarIcon()
        }
        
        switch SettingValues.postImageMode {
        case .CROPPED_IMAGE:
            imageCell.imageView?.image = UIImage.init(named: "crop")?.toolbarIcon()
        case .FULL_IMAGE:
            imageCell.imageView?.image = UIImage.init(named: "full")?.toolbarIcon()
        case .THUMBNAIL:
            imageCell.imageView?.image = UIImage.init(named: "thumb")?.toolbarIcon()
        }
        
        switch SettingValues.actionBarMode {
        case .FULL:
            actionBarCell.imageView?.image = UIImage.init(named: "code")?.toolbarIcon()
        case .NONE:
            actionBarCell.imageView?.image = UIImage.init(named: "hide")?.toolbarIcon()
        case .SIDE:
            actionBarCell.imageView?.image = UIImage.init(named: "up")?.toolbarIcon()
        case .SIDE_RIGHT:
            actionBarCell.imageView?.image = UIImage.init(named: "down")?.toolbarIcon()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 && indexPath.row == 0 {
            let alertController: BottomSheetActionController = BottomSheetActionController()
            alertController.addAction(Action(ActionData(title: "List view", image: UIImage(named: "list")!.menuIcon()), style: .default, handler: { _ in
                UserDefaults.standard.set("list", forKey: SettingValues.pref_postViewMode)
                SettingValues.postViewMode = .LIST
                UserDefaults.standard.synchronize()
                SingleSubredditViewController.cellVersion += 1
                self.doDisables()
                self.doLink()
                tableView.reloadData()
                self.cardModeCell.detailTextLabel?.text = SettingValues.postViewMode.rawValue.capitalize()
                SubredditReorderViewController.changed = true
            }))
            
            alertController.addAction(Action(ActionData(title: "Card view", image: UIImage(named: "card")!.menuIcon()), style: .default, handler: { _ in
                UserDefaults.standard.set("card", forKey: SettingValues.pref_postViewMode)
                SettingValues.postViewMode = .CARD
                UserDefaults.standard.synchronize()
                SingleSubredditViewController.cellVersion += 1
                self.doDisables()
                self.doLink()
                tableView.reloadData()
                self.cardModeCell.detailTextLabel?.text = SettingValues.postViewMode.rawValue.capitalize()
                SubredditReorderViewController.changed = true
            }))
            
            alertController.addAction(Action(ActionData(title: "Centered card view", image: UIImage(named: "centeredimage")!.menuIcon()), style: .default, handler: { _ in
                UserDefaults.standard.set("center", forKey: SettingValues.pref_postViewMode)
                SettingValues.postViewMode = .CENTER
                UserDefaults.standard.synchronize()
                SingleSubredditViewController.cellVersion += 1
                self.doDisables()
                self.doLink()
                tableView.reloadData()
                self.cardModeCell.detailTextLabel?.text = SettingValues.postViewMode.rawValue.capitalize()
                SubredditReorderViewController.changed = true
            }))
            
            alertController.addAction(Action(ActionData(title: "Compact view", image: UIImage(named: "compact")!.menuIcon()), style: .default, handler: { _ in
                UserDefaults.standard.set("compact", forKey: SettingValues.pref_postViewMode)
                SettingValues.postViewMode = .COMPACT
                UserDefaults.standard.synchronize()
                SingleSubredditViewController.cellVersion += 1
                self.doDisables()
                self.doLink()
                tableView.reloadData()
                self.cardModeCell.detailTextLabel?.text = SettingValues.postViewMode.rawValue.capitalize()
                SubredditReorderViewController.changed = true
            }))
            
            VCPresenter.presentAlert(alertController, parentVC: self)
            
        } else if indexPath.section == 1 && indexPath.row == 1 {
            let alertController: BottomSheetActionController = BottomSheetActionController()
            alertController.addAction(Action(ActionData(title: "Full image", image: UIImage(named: "full")!.menuIcon()), style: .default, handler: { _ in
                UserDefaults.standard.set("full", forKey: SettingValues.pref_postImageMode)
                SettingValues.postImageMode = .FULL_IMAGE
                UserDefaults.standard.synchronize()
                self.doDisables()
                self.doLink()
                tableView.reloadData()
                self.imageCell.detailTextLabel?.text = SettingValues.postImageMode.rawValue.capitalize()
                SubredditReorderViewController.changed = true
            }))
            
            alertController.addAction(Action(ActionData(title: "Cropped image", image: UIImage(named: "crop")!.menuIcon()), style: .default, handler: { _ in
                UserDefaults.standard.set("cropped", forKey: SettingValues.pref_postImageMode)
                SettingValues.postImageMode = .CROPPED_IMAGE
                UserDefaults.standard.synchronize()
                self.doDisables()
                self.doLink()
                tableView.reloadData()
                self.imageCell.detailTextLabel?.text = SettingValues.postImageMode.rawValue.capitalize()
                SubredditReorderViewController.changed = true
            }))
            
            alertController.addAction(Action(ActionData(title: "Thumbnail only", image: UIImage(named: "thumb")!.menuIcon()), style: .default, handler: { _ in
                UserDefaults.standard.set("thumbnail", forKey: SettingValues.pref_postImageMode)
                SettingValues.postImageMode = .THUMBNAIL
                UserDefaults.standard.synchronize()
                self.doDisables()
                self.doLink()
                tableView.reloadData()
                self.imageCell.detailTextLabel?.text = SettingValues.postImageMode.rawValue.capitalize()
                SubredditReorderViewController.changed = true
            }))
            
            VCPresenter.presentAlert(alertController, parentVC: self)
        } else if indexPath.section == 2 && indexPath.row == 0 {
            let alertController: BottomSheetActionController = BottomSheetActionController()
            alertController.addAction(Action(ActionData(title: "Full action bar", image: UIImage(named: "code")!.menuIcon()), style: .default, handler: { _ in
                UserDefaults.standard.set("full", forKey: SettingValues.pref_actionbarMode)
                SettingValues.actionBarMode = .FULL
                UserDefaults.standard.synchronize()
                self.doDisables()
                self.doLink()
                tableView.reloadData()
                self.actionBarCell.detailTextLabel?.text = SettingValues.actionBarMode.rawValue.capitalize()
                SingleSubredditViewController.cellVersion += 1
                SubredditReorderViewController.changed = true
            }))
            
            alertController.addAction(Action(ActionData(title: "Side action bar", image: UIImage(named: "up")!.menuIcon()), style: .default, handler: { _ in
                UserDefaults.standard.set("side", forKey: SettingValues.pref_actionbarMode)
                SettingValues.actionBarMode = .SIDE
                UserDefaults.standard.synchronize()
                self.doDisables()
                self.doLink()
                tableView.reloadData()
                self.actionBarCell.detailTextLabel?.text = SettingValues.actionBarMode.rawValue.capitalize()
                SingleSubredditViewController.cellVersion += 1
                SubredditReorderViewController.changed = true
            }))
            
            alertController.addAction(Action(ActionData(title: "Right side action bar", image: UIImage(named: "down")!.menuIcon()), style: .default, handler: { _ in
                UserDefaults.standard.set("right", forKey: SettingValues.pref_actionbarMode)
                SettingValues.actionBarMode = .SIDE_RIGHT
                UserDefaults.standard.synchronize()
                self.doDisables()
                self.doLink()
                tableView.reloadData()
                self.actionBarCell.detailTextLabel?.text = SettingValues.actionBarMode.rawValue.capitalize()
                SingleSubredditViewController.cellVersion += 1
                SubredditReorderViewController.changed = true
            }))

            alertController.addAction(Action(ActionData(title: "Hide action bar", image: UIImage(named: "hide")!.menuIcon()), style: .default, handler: { _ in
                UserDefaults.standard.set("none", forKey: SettingValues.pref_actionbarMode)
                SettingValues.actionBarMode = .NONE
                UserDefaults.standard.synchronize()
                self.doDisables()
                self.doLink()
                tableView.reloadData()
                self.actionBarCell.detailTextLabel?.text = SettingValues.actionBarMode.rawValue.capitalize()
                SingleSubredditViewController.cellVersion += 1
                SubredditReorderViewController.changed = true
            }))
            
            VCPresenter.presentAlert(alertController, parentVC: self)
        }
    }
    
    public func createCell(_ cell: UITableViewCell, _ switchV: UISwitch? = nil, isOn: Bool, text: String) {
        cell.textLabel?.text = text
        cell.textLabel?.textColor = ColorUtil.fontColor
        cell.backgroundColor = ColorUtil.foregroundColor
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        if let s = switchV {
            s.isOn = isOn
            s.addTarget(self, action: #selector(SettingsLayout.switchIsChanged(_:)), for: UIControlEvents.valueChanged)
            cell.accessoryView = s
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    override func loadView() {
        super.loadView()
        doLink()
        self.view.backgroundColor = ColorUtil.backgroundColor
        // set the title
        self.title = "General"
        self.tableView.separatorStyle = .none
        
        createCell(selftextCell, selftext, isOn: SettingValues.showFirstParagraph, text: "Show selftext preview")
        
        createCell(cardModeCell, isOn: false, text: "Layout mode")
        cardModeCell.detailTextLabel?.textColor = ColorUtil.fontColor
        cardModeCell.detailTextLabel?.text = SettingValues.postViewMode.rawValue.capitalize()
        cardModeCell.detailTextLabel?.numberOfLines = 0
        cardModeCell.detailTextLabel?.lineBreakMode = .byWordWrapping
        
        createCell(imageCell, isOn: false, text: "Image mode")
        imageCell.detailTextLabel?.textColor = ColorUtil.fontColor
        imageCell.detailTextLabel?.text = SettingValues.postImageMode.rawValue.capitalize()
        imageCell.detailTextLabel?.numberOfLines = 0
        imageCell.detailTextLabel?.lineBreakMode = .byWordWrapping
        
        createCell(actionBarCell, isOn: false, text: "Action Bar mode")
        actionBarCell.detailTextLabel?.textColor = ColorUtil.fontColor
        actionBarCell.detailTextLabel?.text = SettingValues.actionBarMode.rawValue.capitalize()
        actionBarCell.detailTextLabel?.numberOfLines = 0
        actionBarCell.detailTextLabel?.lineBreakMode = .byWordWrapping

        createCell(smalltagCell, smalltag, isOn: SettingValues.smallerTag, text: "Smaller content tag")
        createCell(largerThumbnailCell, largerThumbnail, isOn: SettingValues.largerThumbnail, text: "Larger thumbnail")
        createCell(commentTitleCell, commentTitle, isOn: SettingValues.commentsInTitle, text: "Show comment count under title")
        createCell(scoreTitleCell, scoreTitle, isOn: SettingValues.scoreInTitle, text: "Show post score under title")
        createCell(abbreviateScoreCell, abbreviateScore, isOn: SettingValues.abbreviateScores, text: "Abbreviate post scores (ex: 10k)")
        createCell(infoBelowTitleCell, infoBelowTitle, isOn: SettingValues.infoBelowTitle, text: "Show information bar below the title")
        createCell(domainInfoCell, domainInfo, isOn: SettingValues.domainInInfo, text: "Show domain in info line")
        createCell(leftThumbCell, leftThumb, isOn: SettingValues.leftThumbnail, text: "Thumbnail on left side")
        createCell(hideCell, hide, isOn: SettingValues.hideButton, text: "Show hide post button")
        createCell(saveCell, save, isOn: SettingValues.saveButton, text: "Show save button")
        createCell(thumbLinkCell, thumbLink, isOn: SettingValues.linkAlwaysThumbnail, text: "Always show thumbnail on link posts")
        createCell(flatModeCell, flatMode, isOn: SettingValues.flatMode, text: "Flat Mode")

        doDisables()
        self.tableView.tableFooterView = UIView()
        
    }
    
    func doDisables() {
        if SettingValues.actionBarMode != .FULL {
            hide.isEnabled = false
            save.isEnabled = false
        } else {
            hide.isEnabled = true
            save.isEnabled = true
        }
        if SettingValues.postImageMode == .THUMBNAIL {
            thumbLink.isEnabled = false
        } else {
            thumbLink.isEnabled = true
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 70
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label: UILabel = UILabel()
        label.textColor = ColorUtil.baseAccent
        label.font = FontGenerator.boldFontOfSize(size: 20, submission: true)
        let toReturn = label.withPadding(padding: UIEdgeInsets.init(top: 0, left: 12, bottom: 0, right: 0))
        toReturn.backgroundColor = ColorUtil.backgroundColor
        
        switch section {
        case 0: label.text  = "Preview"
        case 1: label.text  = "Display"
        case 2: label.text = "Actionbar"
        default: label.text  = ""
        }
        return toReturn
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return link.estimateHeight(false)
        }
        return 60
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return linkCell
        case 1:
            switch indexPath.row {
            case 0: return self.cardModeCell
            case 1: return self.imageCell
            case 2: return self.largerThumbnailCell
            case 3: return self.leftThumbCell
            case 4: return self.thumbLinkCell
            case 5: return self.selftextCell
            case 6: return self.smalltagCell
            case 7: return self.flatModeCell
                
            default: fatalError("Unknown row in section 1")
            }
        case 2:
            switch indexPath.row {
            case 0: return self.actionBarCell
            case 1: return self.infoBelowTitleCell
            case 2: return self.commentTitleCell
            case 3: return self.scoreTitleCell
            case 4: return self.abbreviateScoreCell
            case 5: return self.domainInfoCell
            case 6: return self.hideCell
            case 7: return self.saveCell
                
            default: fatalError("Unknown row in section 2")
            }
        default: fatalError("Unknown section")
        }
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 8
        case 2: return 8
        default: fatalError("Unknown number of sections")
        }
    }
}
