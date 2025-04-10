//
//  MainView.swift
//  VoiceRecord
//
//  Created by Fury on 10/4/25.
//
import SwiftUI

struct MainView: View {
	@StateObject private var recorderViewModel = AudioRecorderViewModel()
	@StateObject private var playerViewModel = AudioPlayerViewModel()
	var body: some View {
		VStack(spacing: 30) {
			// Your recording interface
			RecordButtonView(isRecording: $recorderViewModel.isRecording, action: recorderViewModel.toggleRecording)
			
			// Player view (shown only when we have a recording)
			
			AudioPlayerView(viewModel: playerViewModel, audioURL: $recorderViewModel.audioUrl)
				.transition(.slide)
		}
		
	}
}
