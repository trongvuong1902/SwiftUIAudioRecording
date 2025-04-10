//
//  UIViewControllerExtensions.swift
//  VoiceRecord
//
//  Created by Fury on 10/4/25.
//

import SwiftUI
import UIKit

// Helper extension to embed SwiftUI views
extension UIViewController {
	func addSwiftUIView<Content: View>(_ swiftUIView: Content) {
		let hostingController = UIHostingController(rootView: swiftUIView)
		
		// Add as a child view controller
		addChild(hostingController)
		
		// Add the SwiftUI view to the view controller view hierarchy
		view.addSubview(hostingController.view)
		
		// Configure constraints
		hostingController.view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			hostingController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			hostingController.view.widthAnchor.constraint(equalTo: view.widthAnchor),
			hostingController.view.heightAnchor.constraint(equalTo: view.heightAnchor)
		])
		
		// Notify the hosting controller that it has been moved to the current view controller
		hostingController.didMove(toParent: self)
	}
}
