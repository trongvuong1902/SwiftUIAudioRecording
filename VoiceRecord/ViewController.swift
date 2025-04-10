//
//  ViewController.swift
//  VoiceRecord
//
//  Created by Fury on 10/4/25.
//

import UIKit
import SwiftUICore
import Combine

class ViewController: UIViewController {
	
	private var cancellables = Set<AnyCancellable>()
	override func viewDidLoad() {
		super.viewDidLoad()
		let mainView = MainView()
		addSwiftUIView(mainView)
		
	}


}

