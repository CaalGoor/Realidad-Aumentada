//
//  ViewController.swift
//  Proyecto
//
//  Created by Gonzalez Carlos on 11/16/18.
//  Copyright © 2018 Gonzalez Carlos. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import ReplayKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    let  recorder = RPScreenRecorder.shared()
    
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let tapGesture = UITapGestureRecognizer(target: self, action:
            #selector(ViewController.handleTap(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        stopButton.isEnabled = false
    }
    
    @objc
    func handleTap (gestureRecognizer: UITapGestureRecognizer)
    {
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        let imagePlane = SCNPlane(width: sceneView.bounds.width/6000,
                                  height: sceneView.bounds.height/6000)
        imagePlane.firstMaterial?.diffuse.contents = sceneView.snapshot()
        imagePlane.firstMaterial?.lightingModel = .constant
        
        let planeNode = SCNNode(geometry: imagePlane)
        sceneView.scene.rootNode.addChildNode(planeNode)
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.1
        planeNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK ACTIONS
    
    
    @IBAction func startRecording(_ sender: UIButton) {
        recordButton.isEnabled = false
        stopButton.isEnabled = true
        recorder.startRecording(withMicrophoneEnabled: true){(error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    @IBAction func stopRecording(_ sender: UIButton) {
        recorder.stopRecording
        {
            (previewVC, error) in
            if let previewVC = previewVC {
                previewVC.previewControllerDelegate = self as? RPPreviewViewControllerDelegate
                self.present(previewVC, animated: true, completion: nil)
            }
            
            if let error = error{
                print(error)
            }
        }
        stopButton.isEnabled = false
    }
}
