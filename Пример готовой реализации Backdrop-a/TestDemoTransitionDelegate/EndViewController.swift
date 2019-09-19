//
//  EndViewController.swift
//  TestDemoTransitionDelegate
//
//  Created by MisnikovRoman on 25.08.2019.
//  Copyright © 2019 MisnikovRoman. All rights reserved.
//

import UIKit

class EndViewController: UIViewController {
    var text: String = ""
    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)
        self.label.text = self.title
    }
}
