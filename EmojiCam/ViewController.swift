//
//  ViewController.swift
//  EmojiCam
//
//  Created by Aditya Narayan on 6/22/17.
//
//

import UIKit
import AVFoundation
import CoreImage

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var camPreview: UIView!
    
    let captureSession = AVCaptureSession()
    
    //let movieOutput = AVCaptureMovieFileOutput()
    
    @IBOutlet weak var recordButton: UIButton!
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var activeInput: AVCaptureDeviceInput!
    
    var outputURL: URL!
    
    var filePathArray = [URL]()
    
    var videoDataOutput = AVCaptureVideoDataOutput()
    
    var videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
    
    //core image stuff
    var faceDetector = CIDetector()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.videoCollectionVC = VideoCollectionViewController()
        if setupSession() {
            setupPreview()
            startSession()
            setUpAVCapture()
        }
        
        
    }
    
    
    @IBAction func recordPressed(_ sender: Any) {
        startRecording()
    }

    func setUpAVCapture(){
        
        videoDataOutput.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey) : Int(kCMPixelFormat_32BGRA)]
        
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        
        
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }
        
        videoDataOutput.connection(withMediaType: AVMediaTypeVideo).isEnabled = true
    
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        
        captureSession.commitConfiguration()
        
    }
    
    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = camPreview.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        camPreview.layer.insertSublayer(previewLayer, below: self.recordButton.layer)
        
    }
    
    //MARK:- Setup Camera
    
    func setupSession() -> Bool {
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        // Setup Camera
        let camera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        
        // Setup Microphone
        let microphone = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }
        
        
        // Movie output
//        if captureSession.canAddOutput(movieOutput) {
//            captureSession.addOutput(movieOutput)
//        }
        
        return true
    }
    
    func setupCaptureMode(_ mode: Int) {
        // Video Mode
        
    }
    
    //MARK:- Camera Session
    func startSession() {
        
        
        if !captureSession.isRunning {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
    
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    
    func startRecording() {
        
//        if movieOutput.isRecording == false {
//            
//            self.recordButton.setTitle("Stop Recording", for: .normal)
//            self.recordButton.setTitleColor(UIColor.red, for: .normal)
//            
//            let connection = movieOutput.connection(withMediaType: AVMediaTypeVideo)
//            if (connection?.isVideoOrientationSupported)! {
//                connection?.videoOrientation = currentVideoOrientation()
//            }
//            
//            if (connection?.isVideoStabilizationSupported)! {
//                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
//            }
//            
//            let device = activeInput.device
//            if (device?.isSmoothAutoFocusSupported)! {
//                do {
//                    try device?.lockForConfiguration()
//                    device?.isSmoothAutoFocusEnabled = false
//                    device?.unlockForConfiguration()
//                } catch {
//                    print("Error setting configuration: \(error)")
//                }
//                
//            }
//            
//            outputURL = tempURL()
//            self.filePathArray.append(outputURL)
//            movieOutput.startRecording(toOutputFileURL: outputURL, recordingDelegate: self)
//            
//        }
//        else {
//            self.recordButton.setTitle("Record", for: .normal)
//            self.recordButton.setTitleColor(UIColor.blue, for: .normal)
//            stopRecording()
//        }
        
    }
    
    func stopRecording() {
        
//        if movieOutput.isRecording == true {
//            movieOutput.stopRecording()
//        }
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            
            performSegue(withIdentifier: "showLibrary", sender: self)
            
        }
        
    }
    
   //MARK: - CaptureVideoBuffer
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        //captured every frame
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        let attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate) as? [String: Any]
        
        let ciImage = CIImage(cvImageBuffer: imageBuffer!, options: attachments)
        
        
        let features = faceDetector.features(in: ciImage)
        
        let fdescript = CMSampleBufferGetFormatDescription(sampleBuffer)
        let cleanAperture = CMVideoFormatDescriptionGetCleanAperture(fdescript!, false)
        
        findFace(features: features, forVideoBox: cleanAperture)
    }
    
    
    //MARK: - Face
    
    func findFace(features:[CIFeature], forVideoBox clearAperture: CGRect){
        
        for feature in features {
            print(feature.type)
        }
        
    }
}

















































