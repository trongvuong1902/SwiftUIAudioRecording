//
//  AudioPlayerViewModel.swift
//  VoiceRecord
//
//  Created by Fury on 10/4/25.
//

import AVFoundation
import Combine

class AudioPlayerViewModel: NSObject, ObservableObject {
	// MARK: - Published Properties
	@Published var isPlaying = false
	@Published var currentTime: TimeInterval = 0
	@Published var duration: TimeInterval = 0
	@Published var playbackError: String?
	
	// MARK: - Private Properties
	private var audioPlayer: AVAudioPlayer?
	private var timer: AnyCancellable?
	
	func configureAudioSession() {
		do {
			let session = AVAudioSession.sharedInstance()
			
			// Configure for playback through external speakers/headphones
			try session.setCategory(
				.playback,
				mode: .default,
				options: [.allowBluetooth, .allowBluetoothA2DP, .allowAirPlay]
			)
			
			// Activate the session
			try session.setActive(true)
			
			// Prefer external speakers if available
			try session.overrideOutputAudioPort(.none)
		} catch {
			print("Audio session configuration error: \(error.localizedDescription)")
		}
	}
	
	// MARK: - Playback Control
	func loadAudio(from url: URL) {
		do {
			configureAudioSession()
			// Stop any currently playing audio
			stopPlayback()
			
			
			// Initialize audio player with the file URL
			audioPlayer = try AVAudioPlayer(contentsOf: url)
			audioPlayer?.delegate = self
			audioPlayer?.prepareToPlay()
			
			duration = audioPlayer?.duration ?? 0
			playbackError = nil
		} catch {
			playbackError = "Failed to load audio: \(error.localizedDescription)"
			resetPlayerState()
		}
	}
	
	func togglePlayback() {
		if isPlaying {
			pausePlayback()
		} else {
			startPlayback()
		}
	}
	
	func startPlayback() {
		guard let player = audioPlayer else { return }
		
		if player.play() {
			isPlaying = true
			startPlaybackTimer()
		} else {
			playbackError = "Failed to start playback"
		}
	}
	
	func pausePlayback() {
		audioPlayer?.pause()
		isPlaying = false
		stopPlaybackTimer()
	}
	
	func stopPlayback() {
		audioPlayer?.stop()
		audioPlayer?.currentTime = 0
		isPlaying = false
		currentTime = 0
		stopPlaybackTimer()
	}
	
	func seek(to time: TimeInterval) {
		audioPlayer?.currentTime = time
		currentTime = time
	}
	
	// MARK: - Timer Management
	private func startPlaybackTimer() {
		timer = Timer.publish(every: 0.1, on: .main, in: .common)
			.autoconnect()
			.sink { [weak self] _ in
				guard let self = self else { return }
				self.currentTime = self.audioPlayer?.currentTime ?? 0
			}
	}
	
	private func stopPlaybackTimer() {
		timer?.cancel()
		timer = nil
	}
	
	// MARK: - Cleanup
	private func resetPlayerState() {
		isPlaying = false
		currentTime = 0
		duration = 0
		audioPlayer = nil
	}
	
	deinit {
		stopPlayback()
	}
}

// MARK: - AVAudioPlayerDelegate
extension AudioPlayerViewModel: AVAudioPlayerDelegate {
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		if flag {
			stopPlayback()
		} else {
			playbackError = "Playback finished unexpectedly"
			resetPlayerState()
		}
	}
	
	func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
		playbackError = "Playback error: \(error?.localizedDescription ?? "Unknown error")"
		resetPlayerState()
	}
}
