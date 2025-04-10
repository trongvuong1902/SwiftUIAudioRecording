//
//  ButtonRecord.swift
//  VoiceRecord
//
//  Created by Fury on 10/4/25.
//

import SwiftUI

struct RecordButtonView: View {
	@Binding  var isRecording: Bool
	var action: () -> Void
	var body: some View {
		VStack {

			// Record button
			Button(action: action) {
				ZStack {
					Circle()
						.fill(isRecording ? Color.red.opacity(0.3) : Color.red.opacity(0.2))
						.frame(width: 80, height: 80)
					
					Circle()
						.fill(isRecording ? Color.red : Color.red)
						.frame(width: 60, height: 60)
					
					Image(systemName: isRecording ? "stop.fill" : "mic.fill")
						.font(.title)
						.foregroundColor(.white)
				}
			}
			.padding()
			
		}
	}
	
}

