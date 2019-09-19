//
//  ViewController.swift
//  TestDemoTransitionDelegate
//
//  Created by MisnikovRoman on 25.08.2019.
//  Copyright © 2019 MisnikovRoman. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    private let items = [ "Огурец", "Помидор", "Капусточка" ]

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
}

extension StartViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = self.items[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let endVC = self.createEndViewController(title: self.items[indexPath.row])
        // добавление TransitionDelegate
        let backDropTransitionDelegate = BackDropTransitionDelegate()
        endVC.transitioningDelegate = backDropTransitionDelegate
        endVC.modalPresentationStyle = .custom
        self.present(endVC, animated: true)
    }
}

private extension StartViewController {
    func setup() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    func createEndViewController(title: String) -> EndViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "endVC") as! EndViewController
        vc.title = title
        return vc
    }
}
