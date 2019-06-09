//
//  DragDownAlertMenu.swift
//  Slide for Reddit
//
//  Created by Carlos Crane on 6/9/19.
//  Copyright © 2019 Haptic Apps. All rights reserved.
//

import Anchorage
import SDWebImage
import UIKit

class AlertMenuAction: NSObject {
    var title: String
    var icon: UIImage
    var action: () -> Void
    
    init(title: String, icon: UIImage, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
}

class BottomActionCell: UITableViewCell {
    var background = UIView()
    var title = UILabel()
    var icon = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutViews()
        themeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAction(action: AlertMenuAction) {
        title.text = action.title
        icon.image = action.icon
    }

    func layoutViews() {
        self.contentView.addSubviews(background, title, icon)
        background.verticalAnchors == self.contentView.verticalAnchors + 4
        background.horizontalAnchors == self.contentView.horizontalAnchors + 8
        title.leftAnchor == background.leftAnchor + 16
        title.verticalAnchors == background.verticalAnchors
        title.centerYAnchor == background.centerYAnchor
        
        icon.leftAnchor == title.rightAnchor + 16
        icon.rightAnchor == background.rightAnchor - 16
        icon.centerYAnchor == background.centerYAnchor
        icon.heightAnchor == 44
    }
    
    func themeViews() {
        self.background.backgroundColor = ColorUtil.theme.foregroundColor
        self.background.layer.cornerRadius = 10
        self.background.clipsToBounds = true
        
        self.title.textColor = ColorUtil.theme.fontColor
        self.title.font = UIFont.systemFont(ofSize: 16)
        
        self.icon.contentMode = .center
        
        self.contentView.backgroundColor = ColorUtil.theme.backgroundColor
    }
    
}

class DragDownAlertMenu: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    var descriptor: String
    var subtitle: String
    var icon: String?
    var actions: [AlertMenuAction] = []
    var tableView = UITableView()
    var headerView = UIView()

    init(title: String, subtitle: String, icon: String?) {
        self.descriptor = title
        self.subtitle = subtitle
        self.icon = icon
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    var backgroundView = UIView().then {
        $0.backgroundColor = .clear
    }

    var interactionController: DragDownDismissInteraction?

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(_ vc: UIViewController) {
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
        vc.present(self, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        self.headerView = view
    }
    
    func stylize() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(BottomActionCell.classForCoder(), forCellReuseIdentifier: "action")
        self.tableView.separatorStyle = .none
    }
    
    func addAction(title: String, icon: UIImage, action: @escaping () -> Void) {
        actions.append(AlertMenuAction(title: title, icon: icon, action: action))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = actions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "action") as! BottomActionCell
        cell.setAction(action: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    var isPresenting = false

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if #available(iOS 11.0, *) {
            return 30 + self.additionalSafeAreaInsets.bottom + 20
        } else {
            return 30 + 20
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    var height = CGFloat.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(backgroundView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DragDownAlertMenu.handleTap(_:)))
        backgroundView.addGestureRecognizer(tapGesture)
        self.tableView = UITableView()
        self.view.addSubview(tableView)
        backgroundView.edgeAnchors == view.edgeAnchors

        self.tableView.centerXAnchor == self.view.centerXAnchor
        self.tableView.widthAnchor == min(self.view.frame.size.width, 450)
        self.tableView.bottomAnchor == self.view.bottomAnchor + 20
        self.tableView.bounces = false
        self.tableView.backgroundColor = ColorUtil.theme.backgroundColor
        self.tableView.layer.cornerRadius = 15
        self.tableView.layer.masksToBounds = true
        height = min(UIScreen.main.bounds.height * (2 / 3), CGFloat(80 + (60 * actions.count)))
        self.tableView.heightAnchor == height
        stylize()
        self.tableView.reloadData()
        interactionController = DragDownDismissInteraction(viewController: self)
        //self.tableView.roundCorners(UIRectCorner.allCorners, radius: 10)
    }
    
    var lastY: CGFloat = 0.0

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentY = scrollView.contentOffset.y
        let currentBottomY = scrollView.frame.size.height + currentY
        if currentY > lastY {
            tableView.bounces = true
        } else {
            if currentBottomY < scrollView.contentSize.height + scrollView.contentInset.bottom {
                tableView.bounces = false
            }
        }
        lastY = scrollView.contentOffset.y
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label: UILabel = UILabel()
        label.numberOfLines = 2
        let toReturn = UIView()
        toReturn.backgroundColor = ColorUtil.theme.backgroundColor
        let attributedTitle = NSMutableAttributedString(string: self.descriptor, attributes: [NSAttributedString.Key.foregroundColor: ColorUtil.theme.fontColor, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)])
        attributedTitle.append(NSAttributedString(string: "\n" + subtitle, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: ColorUtil.theme.fontColor.withAlphaComponent(0.6)]))
        label.attributedText = attributedTitle
        let close = UIImageView(image: UIImage(named: "close")?.navIcon())
        close.contentMode = .center
        toReturn.addSubview(close)
        close.centerYAnchor == toReturn.centerYAnchor
        close.rightAnchor == toReturn.rightAnchor - 16
        close.heightAnchor == 30
        close.widthAnchor == 30
        close.addTapGestureRecognizer {
            self.dismiss(animated: true, completion: nil)
        }
        if icon != nil {
            let image = UIImageView()
            image.layer.cornerRadius = 7
            image.clipsToBounds = true
            toReturn.addSubviews(image, label)
            image.leftAnchor == toReturn.leftAnchor + 12
            image.centerYAnchor == toReturn.centerYAnchor
            image.heightAnchor == 45
            image.widthAnchor == 45
            image.contentMode = .scaleAspectFill
            
            image.sd_setImage(with: URL(string: icon!), placeholderImage: LinkCellImageCache.web)
            label.leftAnchor == image.rightAnchor + 8
            label.rightAnchor == close.leftAnchor - 8
            label.verticalAnchors == toReturn.verticalAnchors
        } else {
            toReturn.addSubview(label)
            label.leftAnchor == toReturn.leftAnchor + 16
            label.rightAnchor == close.leftAnchor - 8
            label.verticalAnchors == toReturn.verticalAnchors
        }
        let bar = UIView().then {
            $0.backgroundColor = .clear // ColorUtil.theme.fontColor.withAlphaComponent(0.25)
        }
        toReturn.addSubview(bar)
        bar.horizontalAnchors == toReturn.horizontalAnchors
        bar.bottomAnchor == toReturn.bottomAnchor
        bar.heightAnchor == 1
        return toReturn
    }
    
    var headers = [String]()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true) {
            self.actions[indexPath.row].action()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

//Based off of https://stackoverflow.com/a/45525284/3697225
extension DragDownAlertMenu: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let presentationController = DragDownPresentationController(presentedViewController: presented,
                                                                          presenting: presenting)
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let menu = presented as? DragDownAlertMenu else {
            return nil
        }
        return DragDownPresentationAnimator(isPresentation: true, interactionController: menu.interactionController)
    }
    
    func animationController(forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            guard let menu = dismissed as? DragDownAlertMenu else {
                return nil
            }
            return DragDownPresentationAnimator(isPresentation: false, interactionController: menu.interactionController)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animator as? DragDownPresentationAnimator,
            let interactionController = animator.interactionController,
            interactionController.interactionInProgress
            else {
                return nil
        }
        return interactionController
    }
}

final class DragDownPresentationAnimator: NSObject {
    
    let isPresentation: Bool
    var interactionController: DragDownDismissInteraction?
    
    init(isPresentation: Bool, interactionController: DragDownDismissInteraction?) {
        self.isPresentation = isPresentation
        self.interactionController = interactionController
        super.init()
    }
}
extension DragDownPresentationAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isPresentation ? 0.3 : 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let key = isPresentation ? UITransitionContextViewControllerKey.to
            : UITransitionContextViewControllerKey.from
        guard let controller = transitionContext.viewController(forKey: key)! as? DragDownAlertMenu else {
            fatalError("Presented view controller must be an instance of DragDownAlertMenu!")
        }
        
        controller.view.layoutSubviews()
        
        let presentedContentViewFrame = controller.tableView.frame
        var dismissedContentViewFrame = presentedContentViewFrame
        dismissedContentViewFrame.origin.y = transitionContext.containerView.frame.size.height
        let initialContentViewFrame = isPresentation ? dismissedContentViewFrame : presentedContentViewFrame
        let finalContentViewFrame = isPresentation ? presentedContentViewFrame : dismissedContentViewFrame
        controller.tableView.frame = initialContentViewFrame
        
        var curve = UIView.AnimationOptions.curveEaseInOut
        var spring = CGFloat(0.9)
        var initial = CGFloat(0.4)
        if let interactionController = interactionController,
            interactionController.interactionInProgress {
            curve = UIView.AnimationOptions.curveLinear
            spring = 0
            initial = 0
        }
        if !isPresentation {
            spring = 0
        }
        if spring == 0 {
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           delay: 0,
                           options: curve,
                           animations: {
                            controller.tableView.frame = finalContentViewFrame
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
            
        } else {
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           delay: 0,
                           usingSpringWithDamping: spring,
                           initialSpringVelocity: initial,
                           options: curve,
                           animations: {
                            controller.tableView.frame = finalContentViewFrame
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}

class DragDownPresentationController: UIPresentationController {
    
    fileprivate var backgroundView: UIView!
    
    // Mirror Manager params here
    
    override init(presentedViewController: UIViewController,
                  presenting presentingViewController: UIViewController?) {
        
        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)
        
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
        backgroundView.frame = frameOfPresentedViewInContainerView
    }
    
    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width, height: parentSize.height)
    }
    
    override func presentationTransitionWillBegin() {
        let accountView = presentedViewController as! DragDownAlertMenu
        setupDimmingView()
        if let containerView = containerView {
            containerView.insertSubview(backgroundView, at: 0)
            //            accountView.view.removeFromSuperview() // TODO: Risky?
            containerView.addSubview(accountView.view)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.backgroundView.alpha = 0
            }, completion: { context in
                self.backgroundView.alpha = 0.7
            })
        } else {
        }
    }
    
}

// MARK: - Private
private extension DragDownPresentationController {
    func setupDimmingView() {
        backgroundView = UIView(frame: UIScreen.main.bounds).then {
            $0.backgroundColor = .black
            $0.alpha = 0.7
        }
    }
}
class DragDownDismissInteraction: UIPercentDrivenInteractiveTransition, UIGestureRecognizerDelegate {
    var interactionInProgress = false
    
    private var shouldCompleteTransition = false
    private weak var viewController: DragDownAlertMenu!
    private var storedHeight: CGFloat = 400
    
    init(viewController: DragDownAlertMenu) {
        super.init()
        self.viewController = viewController
        self.storedHeight = viewController.height
        prepareGestureRecognizer(in: viewController.tableView)
    }
    
    private func prepareGestureRecognizer(in view: UIView) {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        gesture.direction = UIPanGestureRecognizer.Direction.vertical
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (viewController.tableView.contentOffset.y == 0 || viewController.headerView.bounds.contains(touch.location(in: viewController.headerView)))
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer is UIPanGestureRecognizer && (viewController.tableView.contentOffset.y == 0)
    }
    
    @objc func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let vc = viewController
        
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!)
        let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view!)
        var progress = min(max(0, translation.y), storedHeight) / storedHeight
        progress = max(min(progress, 1), 0) // Clamp between 0 and 1
        print(progress)
        switch gestureRecognizer.state {
        case .began:
            interactionInProgress = true
            viewController.dismiss(animated: true, completion: nil)
            storedHeight = vc!.height
        case .changed:
            shouldCompleteTransition = progress > 0.5 || velocity.y > 1000
            update(progress)
        case .cancelled:
            interactionInProgress = false
            cancel()
        case .ended:
            interactionInProgress = false
            shouldCompleteTransition ? finish() : cancel()
        default:
            break
        }
    }
    
}
