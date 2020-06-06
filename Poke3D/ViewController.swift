//
//  ViewController.swift
//  Poke3D
//
//  Created by Anh Dinh on 6/4/20.
//  Copyright © 2020 Anh Dinh. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // automatically add light
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        // change configuration to ARImageTrackingConfiguration()
        let configuration = ARImageTrackingConfiguration()
        
        // tell the App the image it's should track which is inside of the Assets.xcassets
        // "Pokemon Cards" is the group name that we create
        // Bundle.main is the position of the current protject, it's where the group "Pokemon Cards" is
        // imageToTrack is optional, optional binding it, which means when there's goup of "Pokemon Cards", then we keep going
        if let imageToTrack = ARReferenceImage.referenceImages(inGroupNamed: "Pokemon Cards", bundle: Bundle.main){
            
            // set the images that ARKit should detect and track to be the imageToTrack
            configuration.trackingImages = imageToTrack
            
            // number of maximum images to track
            configuration.maximumNumberOfTrackedImages = 1
            
            print("Image successfully added")
            
        }
        
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: - Delegate Method to detect anchor and return a 3D object
    //this function is to dectect anchor, in this case it's the card and it will return an 3D object.
    // this func is slightly differ from the one that we use to detect the horizontal plane because for this one we need to return an 3D object, we have to create a node, for the other func, the node is already created by delegate.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        // optional binding to check if the anchor is detected as an image in physical world.
        // ARImageAnchor is the position and orientation of detected image in real world.
        if let imageAnchor = anchor as? ARImageAnchor{
            // tell AR to look at the image it detects and measure the physical size and use it to create a plane's width and height.
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            
            // set the detected plane not to be white so we can see through
            plane.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.5)
            
            // create plane node, add plane to it.
            let planeNode = SCNNode(geometry: plane)
            
            // at first, the detected plane is vertical, we need to rotate it down by -pi/2 so that the plane lay down on horizontal surface.
            planeNode.eulerAngles.x = -.pi/2
            
            // add node to rootNode
            node.addChildNode(planeNode)
            
            //MARK: - 3D eevee part
            // create a scene with the 3D model that we import
            if let pokeScene = SCNScene(named: "art.scnassets/eevee.scn"){
                // create a node for the 3D eevee
                if let pokeNode = pokeScene.rootNode.childNodes.first{
                    
                    // rotate pokeNode so that eevee stands on the card
                    pokeNode.eulerAngles.x = .pi/2
                    
                    // add eevee node to planeNode, planeNode is where we want eevee to show up.
                    planeNode.addChildNode(pokeNode)
                }
            }
            
        }
        return node
    }
    
}

/*
 - 06/05/2020: One thing to remember: because we set up the image to track and ask AR to detect that image, so when AR is running, it only detects the image that matches the one we ask it to detect, if you run in on other card, AR won't detect those cards
 
 */
