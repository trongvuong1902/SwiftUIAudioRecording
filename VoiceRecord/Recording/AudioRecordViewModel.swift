//
//  AudioRecordViewModel.swift
//  VoiceRecord
//
//  Created by Fury on 10/4/25.
//
import Foundation
import AVFoundation
import Combine

class AudioRecorderViewModel: NSObject, ObservableObject {
	// MARK: - Published Properties
	@Published var isRecording = false
	@Published var recordingTime: TimeInterval = 0
	@Published var showError = false
	@Published var errorMessage = ""
	@Published var audioUrl: URL? = nil
	
	
	// MARK: - Private Properties
	private var audioRecorder: AVAudioRecorder?
	private var timer: Timer?
	
	private var recordingUrl: URL?
	
	// MARK: - Recording Control
	func toggleRecording() {
		if isRecording {
			stopRecording()
		} else {
			startRecording()
		}
	}
	
	private func startRecording() {
		// Reset state
		recordingTime = 0
		showError = false
		if (audioUrl != nil) {audioUrl = nil}
		// Setup audio session
		let audioSession = AVAudioSession.sharedInstance()
		do {
			try audioSession.setCategory(.playAndRecord, mode: .default)
			try audioSession.setActive(true)
			
			// Request permission if needed
			AVAudioApplication.requestRecordPermission { [weak self] granted in
				DispatchQueue.main.async {
					if granted {
						self?.setupRecorder()
					} else {
						self?.handleError("Microphone access was denied")
					}
				}
			}
		} catch {
			handleError("Failed to setup audio session: \(error.localizedDescription)")
		}
	}
	
	private func setupRecorder() {
		// Create recording URL
		recordingUrl = getDocumentsDirectory()
			.appendingPathComponent("recording-\(Date().timeIntervalSince1970).m4a")
		
		// Audio settings
		let settings: [String: Any] = [
			AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
			AVSampleRateKey: 12000,
			AVNumberOfChannelsKey: 1,
			AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
		]
		
		do {
			guard let recordingUrl = recordingUrl else {
				handleError("Could not create recording URL")
				return
			}
			
			audioRecorder = try AVAudioRecorder(url: recordingUrl, settings: settings)
			audioRecorder?.delegate = self
			audioRecorder?.record()
			
			// Start timer
			startTimer()
			isRecording = true
		} catch {
			handleError("Failed to start recording: \(error.localizedDescription)")
		}
	}
	
	private func stopRecording() {
		audioRecorder?.stop()
		audioRecorder = nil
		stopTimer()
		isRecording = false
		audioUrl = recordingUrl
	}
	
	// MARK: - Timer Handling
	private func startTimer() {
		timer?.invalidate()
		timer = Timer.scheduledTimer(
			withTimeInterval: 1,
			repeats: true
		) { [weak self] _ in
			self?.recordingTime += 1
		}
	}
	
	private func stopTimer() {
		timer?.invalidate()
		timer = nil
	}
	
	// MARK: - Error Handling
	private func handleError(_ message: String) {
		errorMessage = message
		showError = true
		isRecording = false
		stopTimer()
	}
	
	// MARK: - File Management
	private func getDocumentsDirectory() -> URL {
		FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
	}
	
	// MARK: - Cleanup
	deinit {
		if isRecording {
			stopRecording()
		}
	}
}

// MARK: - AVAudioRecorderDelegate
extension AudioRecorderViewModel: AVAudioRecorderDelegate {
	func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
		if !flag {
			handleError("Recording failed unexpectedly")
		}
	}
	
	func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
		if let error = error {
			handleError("Recording error: \(error.localizedDescription)")
		}
	}
}
