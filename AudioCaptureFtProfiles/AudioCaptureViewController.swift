//
//  AudioCaptureViewController.swift
//  AudioCaptureFtProfiles
//
//  Created by Felipe Costa on 10/11/19.
//  Copyright © 2019 Felipe Costa. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation


class AudioCaptureViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var channelLabel: UILabel!
    
    @IBOutlet weak var audioQualityBTN: UIButton!
    
    @IBOutlet weak var recordBTN: UIBarButtonItem!
    
    @IBOutlet weak var playBTN: UIBarButtonItem!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    var audioSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer?
    
    var settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    
    var audioFormat = "m4a"
    
    var playAudioURL : URL?
    
    var numChannel = 1
    
    var recordOn = false
    var pauseOn = false
    
    let pickerData = ["m4a", "alac"]
    
    var qualityHigh = true
    var audioQuality = AVAudioQuality.high.rawValue
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return pickerData[row]
    }
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        playAudioURL = getDocumentsDirectory().appendingPathComponent("recording." + pickerData[row])
        profileLoader(profile: pickerData[row])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.recordBTN.isEnabled = false
        self.playBTN.isEnabled = false
        recordBTN.addTargetForAction(target: self, action: #selector(record))
        playBTN.addTargetForAction(target: self, action: #selector(play))
        audioSession = AVAudioSession.sharedInstance()
        self.loadAll()
        
    }

    
    func loadLastAudioFile(){
        playAudioURL = getDocumentsDirectory().appendingPathComponent("recording." + audioFormat)
        let fileManager = FileManager.default
        let filepath = playAudioURL?.path
        if fileManager.fileExists(atPath: filepath!) {
            self.playBTN.isEnabled = true
        }
    }
    
    func loadAll(){
        do{
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission() {_ in
                self.audioSession.requestRecordPermission() { [unowned self] allowed in
                    DispatchQueue.main.async {
                        if allowed {
                            self.loadLastAudioFile()
                            self.recordBTN.isEnabled = true
                        } else {
                            self.recordBTN.isEnabled = false
                            self.playBTN.isEnabled = false
                        }
                    }
                }
            }
        } catch {
            print("Error: Could not allow recording")
        }
        
    }
    
    
    @objc func record (sender:UIButton) {
        if(!recordOn){
            startRecording()
            recordBTN.image = UIImage(named : "stop")
            recordOn = true
        }
        else{
            recordBTN.image = UIImage(named : "record")
            finishRecording(success: true)
            recordOn = false
        }
    }
    
    @objc func play(sender:UIButton) {
        if(!pauseOn){
            recordBTN.isEnabled = false
            audioPlayer?.play()
            playBTN.image = UIImage(named: "pause")
            pauseOn = true
        }
        else{
            recordBTN.isEnabled = true
            audioPlayer?.pause()
            playBTN.image = UIImage(named: "play")
            pauseOn = false
        }
    }
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playBTN.image = UIImage(named: "play")
        pauseOn = false
        recordBTN.isEnabled = true
    }
    
    func startRecording() {
        playBTN.isEnabled = false
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording." + audioFormat)
        
        playAudioURL = audioFilename

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self as AVAudioRecorderDelegate
            audioRecorder.record()
            playAudioURL = audioFilename
        } catch {
            finishRecording(success: false)
        }
    }

    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        playBTN.isEnabled = true
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            print("Recorded Successfully")
            do{
            audioPlayer = try AVAudioPlayer(contentsOf: playAudioURL!)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            self.playBTN.isEnabled = true
            }catch{
                print("Could not load audio player")
            }
            
        } else {
            print("Recorded Nothing!!!!!!!!")
        }
    }
    
    func profileLoader(profile : String){
        switch profile {
        case "m4a":
            settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: numChannel,
                AVEncoderAudioQualityKey: audioQuality
            ]
             audioFormat = "m4a"
            break
        case "alac":
            settings = [
                AVFormatIDKey: Int(kAudioFormatAppleLossless),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: numChannel,
                AVEncoderAudioQualityKey: audioQuality
            ]
             audioFormat = "alac"
            break
        default:
            settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: numChannel,
                AVEncoderAudioQualityKey: audioQuality
            ]
             audioFormat = "m4a"
            
        }
        
    }
    
    @IBAction func minusChannelBTN(_ sender: Any) {
        if(numChannel > 1 ){
            numChannel -= 1
            channelLabel.text = "Number of Channels: " + String(numChannel)
        }
    }
    
    @IBAction func addChannelBTN(_ sender: Any) {
        if(numChannel < 4 ){
            numChannel += 1
            channelLabel.text = "Number of Channels: " + String(numChannel)
        }
    }
    
    
    @IBAction func switchQualityBTN(_ sender: Any) {
        if(qualityHigh){
            audioQuality = AVAudioQuality.low.rawValue
            qualityHigh = false
            audioQualityBTN.setTitle("Switch to High Quality", for: .normal)
            
        }
        else{
            audioQuality = AVAudioQuality.high.rawValue
            qualityHigh = true
            audioQualityBTN.setTitle("Switch to Low Quality", for: .normal)
        }
        
    }
    

}
