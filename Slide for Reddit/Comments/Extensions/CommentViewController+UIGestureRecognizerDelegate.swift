//
//  CommentViewController+UIGestureRecognizerDelegate.swift
//  Slide for Reddit
//
//  Created by Josiah Agosto on 8/3/20.
//  Copyright © 2020 Haptic Apps. All rights reserved.
//

import UIKit

extension CommentViewController: UIGestureRecognizerDelegate {
    // MARK: - Methods
    func setupGestures() {
        cellGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panCell(_:)))
        cellGestureRecognizer.delegate = self
        cellGestureRecognizer.maximumNumberOfTouches = 1
        tableView.addGestureRecognizer(cellGestureRecognizer)
        if UIDevice.current.userInterfaceIdiom != .pad {
            cellGestureRecognizer.require(toFail: tableView.panGestureRecognizer)
        }
        if let parent = parent as? ColorMuxPagingViewController {
            parent.requireFailureOf(cellGestureRecognizer)
        }
        if let nav = self.navigationController as? SwipeForwardNavigationController {
            nav.fullWidthBackGestureRecognizer.require(toFail: cellGestureRecognizer)
            if let interactivePop = nav.interactivePopGestureRecognizer {
                cellGestureRecognizer.require(toFail: interactivePop)
            }
        }
    }
        
    func setupSwipeGesture() {
        if swipeBackAdded {
            return
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            if #available(iOS 14, *) {
                return
            }
        }
        if SettingValues.commentGesturesMode == .FULL {
            return
        }
        fullWidthBackGestureRecognizer = UIPanGestureRecognizer()
        if let interactivePopGestureRecognizer = parent?.navigationController?.interactivePopGestureRecognizer, let targets = interactivePopGestureRecognizer.value(forKey: "targets"), parent is ColorMuxPagingViewController, !swipeBackAdded {
            swipeBackAdded = true
            fullWidthBackGestureRecognizer.require(toFail: tableView.panGestureRecognizer)
            if let navGesture = self.navigationController?.interactivePopGestureRecognizer {
                fullWidthBackGestureRecognizer.require(toFail: navGesture)
            }
            for view in parent?.view.subviews ?? [] {
                if view is UIScrollView {
                    (view as! UIScrollView).panGestureRecognizer.require(toFail: fullWidthBackGestureRecognizer)
                }
            }

            fullWidthBackGestureRecognizer.setValue(targets, forKey: "targets")
            fullWidthBackGestureRecognizer.delegate = self
            //parent.requireFailureOf(fullWidthBackGestureRecognizer)
            tableView.addGestureRecognizer(fullWidthBackGestureRecognizer)
            if #available(iOS 13.4, *) {
                fullWidthBackGestureRecognizer.allowedScrollTypesMask = .continuous
            }
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !(otherGestureRecognizer == cellGestureRecognizer && otherGestureRecognizer.state != .ended)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: tableView)
            if panGestureRecognizer == cellGestureRecognizer {
                if abs(translation.y) >= abs(translation.x) {
                    return false
                }
                if translation.x < 0 {
                    if gestureRecognizer.location(in: tableView).x > tableView.frame.width * 0.5 || SettingValues.commentGesturesMode == .FULL {
                        return true
                    }
                } else if SettingValues.commentGesturesMode == .FULL && abs(translation.x) > abs(translation.y) {
                    return gestureRecognizer.location(in: tableView).x > tableView.frame.width * 0.1
                }
                return false
            }
            if panGestureRecognizer == fullWidthBackGestureRecognizer && translation.x >= 0 {
                return true
            }
            return false
        }
        return false
    }

    @objc func panCell(_ recognizer: UIPanGestureRecognizer) {
        
        if recognizer.view != nil {
            let velocity = recognizer.velocity(in: recognizer.view!)

            if (velocity.x < 0 && (SettingValues.commentActionLeftLeft == .NONE && SettingValues.commentActionLeftRight == .NONE) && translatingCell == nil) || (velocity.x > 0 && (SettingValues.commentGesturesMode == .HALF ||  (SettingValues.commentActionRightLeft == .NONE && SettingValues.commentActionRightRight == .NONE)) && translatingCell == nil) {
                return
            }
        }

        if recognizer.state == .began || translatingCell == nil {
            let point = recognizer.location(in: self.tableView)
            let indexpath = self.tableView.indexPathForRow(at: point)
            if indexpath == nil {
                return
            }

            guard let cell = self.tableView.cellForRow(at: indexpath!) as? CommentDepthCell else { return }
            for view in cell.commentBody.subviews {
                let cellPoint = recognizer.location(in: view)
                if (view is UIScrollView || view is CodeDisplayView || view is TableDisplayView) && view.bounds.contains(cellPoint) {
                    recognizer.cancel()
                    return
                }
            }
            tableView.panGestureRecognizer.cancel()
            translatingCell = cell
        }
        
        translatingCell?.handlePan(recognizer)
        if recognizer.state == .ended {
            translatingCell = nil
        }
    }
    
}
