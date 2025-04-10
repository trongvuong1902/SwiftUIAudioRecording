//
//  AudioPlayerView.swift
//  VoiceRecord
//
//  Created by Fury on 10/4/25.
//

import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
	@StateObject var viewModel: AudioPlayerViewModel
	@Binding var audioURL: URL?
	
	// For slider dragging state
	@State private var isDragging = false
	
	var body: some View {
		if (audioURL != nil) {
			 VStack(spacing: 20) {
				// Playback time indicators
			 HStack {
				 Text(formattedTime(viewModel.currentTime))
					 .font(.caption.monospacedDigit())
					 .frame(width: 50, alignment: .leading)
				 
				 Spacer()
				 
				 Text(formattedTime(viewModel.duration))
					 .font(.caption.monospacedDigit())
					 .frame(width: 50, alignment: .trailing)
			 }
			 
			 // Progress slider
			 Slider(
				 value: $viewModel.currentTime,
				 in: 0...viewModel.duration,
				 onEditingChanged: { editing in
					 isDragging = editing
					 if !editing {
						 viewModel.seek(to: viewModel.currentTime)
					 }
				 }
			 )
			 .accentColor(.blue)
			 
			 // Control buttons
			 HStack(spacing: 40) {
				 // Stop button
				 Button(action: {
					 viewModel.stopPlayback()
				 }) {
					 Image(systemName: "stop.fill")
						 .font(.system(size: 24))
						 .foregroundColor(.red)
						 .frame(width: 44, height: 44)
						 .background(Circle().fill(Color.red.opacity(0.2)))
				 }
				 
				 // Play/Pause button
				 Button(action: {
					 viewModel.togglePlayback()
				 }) {
					 Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
						 .font(.system(size: 32))
						 .foregroundColor(.white)
						 .frame(width: 60, height: 60)
						 .background(Circle().fill(.blue))
				 }
				 
				 // Skip forward 15 seconds
				 Button(action: {
					 viewModel.seek(to: min(viewModel.duration, viewModel.currentTime + 15))
				 }) {
					 Image(systemName: "goforward.15")
						 .font(.system(size: 24))
						 .frame(width: 44, height: 44)
				 }
			 }
			 .buttonStyle(.plain)
			 
			 // Error message
			 if let error = viewModel.playbackError {
				 Text(error)
					 .foregroundColor(.red)
					 .font(.caption)
					 .multilineTextAlignment(.center)
			 }
		 }
		 .padding()
		 .onAppear {
			 viewModel.loadAudio(from: audioURL!)
		 }
		 .onDisappear {
			 viewModel.stopPlayback()
		 }
		} else {
			 EmptyView()
		}
	}
	
	private func formattedTime(_ time: TimeInterval) -> String {
		let minutes = Int(time) / 60
		let seconds = Int(time) % 60
		return String(format: "%02d:%02d", minutes, seconds)
	}
}

// Preview Provider
struct AudioPlayerView_Previews: PreviewProvider {
	static var previews: some View {
		// Create a dummy URL for preview purposes
		@State var dummyURL = URL(fileURLWithPath: Bundle.main.path(forResource: "example", ofType: "m4a") ?? "")
		
		// Create a view model for preview
		let viewModel = AudioPlayerViewModel()
	
		AudioPlayerView(viewModel: viewModel, audioURL: .constant(dummyURL))
			.previewLayout(.sizeThatFits)
			.padding()
	}
}
