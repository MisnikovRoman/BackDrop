//
//  ViewController.swift
//  TestSimpleTransitionDelegate
//
//  Created by Мисников Роман on 21/08/2019.
//  Copyright © 2019 Мисников Роман. All rights reserved.
//

import UIKit

class RedViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
	}

	@IBAction func showNextViewController(_ sender: Any) {

		let blueVC = UIStoryboard(name: "Main", bundle: nil)
			.instantiateViewController(withIdentifier: "Blue")

		// setup transition delegate

		self.present(blueVC, animated: true)
	}
}

