//
//  OverlayViewController.swift
//  iOS Sample
//
//  Copyright (c) 2017 Kazuhiro Hayashi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import PagingKit

class OverlayViewController: UIViewController {
    
    let dataSource: [(menu: String, content: UIViewController)] = ["Martinez", "Alfred", "Louis", "Justin", "Tim", "Deborah", "Michael", "Choi", "Hamilton", "Decker", "Johnson", "George"].map {
        let title = $0
        //let vc = UIStoryboard(name: "ContentTableViewController", bundle: nil).instantiateInitialViewController() as! ContentTableViewController
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.random
        return (menu: title, content: vc)
    }

    var menuViewController: PagingMenuViewController!
    var contentViewController: PagingContentViewController!
    var overlayFocusView = OverlayFocusView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initOverlayFocusView()
        initMenuViewController()
        initContentViewController()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
            menuViewController?.dataSource = self
            menuViewController?.delegate = self
        } else if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
            contentViewController?.delegate = self
            contentViewController?.dataSource = self
        }
    }
}

extension OverlayViewController {
    func initOverlayFocusView() {
        overlayFocusView.contentBackgroundColor = UIColor(red: 0.627, green: 0.506, blue: 0.882, alpha: 1)
    }
    
    func initMenuViewController() {
        menuViewController?.register(type: OverlayMenuCell.self,
                                     forCellWithReuseIdentifier: "OverlayMenuCellIdentifier")
        menuViewController?.registerFocusView(view: overlayFocusView, isBehindCell: true)
        menuViewController?.reloadData(with: 0, completionHandler: { [weak self] (vc) in
            (self?.menuViewController.currentFocusedCell as! OverlayMenuCell)
                .updateMask(animated: false)
        })
    }
    
    func initContentViewController() {
        contentViewController?.scrollView.bounces = true
        contentViewController?.reloadData(with: 0)
    }
}

extension OverlayViewController: PagingMenuViewControllerDataSource {
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "OverlayMenuCellIdentifier",
                                                      for: index)  as! OverlayMenuCell
        cell.titleLabel.textAlignment = .center
        cell.highlightLabel.textAlignment = .center
        cell.configure(title: dataSource[index].menu)
        cell.referencedFocusView = viewController.focusView
        cell.referencedMenuView = viewController.menuView
        cell.updateMask()
        
        //FIXME: Remove me
        cell.layer.borderColor = UIColor.red.cgColor
        cell.layer.borderWidth = 1
        return cell
    }

    
    func menuViewController(viewController: PagingMenuViewController,
                            widthForItemAt index: Int) -> CGFloat {
        let offsetLR: CGFloat = 10
        return OverlayMenuCell.sizingCell.calculateWidth(from: viewController.view.bounds.height,
                                                         title: dataSource[index].menu) + offsetLR
    }
    
    func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return dataSource.count
    }
}


extension OverlayViewController: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController,
                               viewControllerAt index: Int) -> UIViewController {
        return dataSource[index].content
    }
}

extension OverlayViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController,
                            didSelect page: Int,
                            previousPage: Int) {
        contentViewController?.scroll(to: page,
                                      animated: true)
    }
    
    func menuViewController(viewController: PagingMenuViewController,
                            willAnimateFocusViewTo index: Int,
                            with coordinator: PagingMenuFocusViewAnimationCoordinator) {
        viewController.visibleCells.compactMap { $0 as? OverlayMenuCell }.forEach { cell in
            cell.updateMask()
        }
        
        coordinator.animateFocusView(alongside: { coordinator in
            viewController.visibleCells.compactMap { $0 as? OverlayMenuCell }.forEach { cell in
                cell.updateMask()
            }
        }, completion: nil)
    }
    
    func menuViewController(viewController: PagingMenuViewController,
                            willDisplay cell: PagingMenuViewCell,
                            forItemAt index: Int) {
        (cell as? OverlayMenuCell)?.updateMask()
    }
}

extension OverlayViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController,
                               didManualScrollOn index: Int,
                               percent: CGFloat) {
        menuViewController.scroll(index: index,
                                  percent: percent,
                                  animated: false)
        menuViewController.visibleCells.forEach {
            guard let cell = $0 as? OverlayMenuCell else { return }
            cell.updateMask()
        }
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}
