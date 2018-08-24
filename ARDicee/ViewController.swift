//
//  ViewController.swift
//  ARDicee
//
//  Created by Pedro Carmezim on 21/08/18.
//  Copyright © 2018 Pedro Carmezim. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //see in real time it trying to find the plane surface
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        
        //let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        
//        let sphere = SCNSphere(radius: 0.2)
//
//        let material = SCNMaterial()
//
//        material.diffuse.contents = UIImage(named: "art.scnassets/8k_moon.jpg")
//
//        sphere.materials = [material]
//
//        //Create where the cube will be
//        let node = SCNNode()
//
//        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
//
//        //add geometry
//
//        node.geometry = sphere
//
//        //adding child node, many child nodes
//        sceneView.scene.rootNode.addChildNode(node)
        
        
        sceneView.autoenablesDefaultLighting = true
        
//        // Create a new scene
//        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
//
//        if let diceNode = diceScene.rootNode.childNode(withName: "Dice" ,recursively: true){
//
//        diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1)
//
//        sceneView.scene.rootNode.addChildNode(diceNode)
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ARWorldTrackingConfiguration.isSupported{
            

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
            
        //enable horizontal plane detection
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
            
        }else{
            // Create a session configuration
            let configuration = AROrientationTrackingConfiguration()
            
            // Run the view's session
            sceneView.session.run(configuration)
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    //MARK: - Detecting taps in the screen
    
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            if let touch = touches.first{
            let touchLocation = touch.location(in: sceneView)

            //Convert 2d to 3d location based on the value of Z,
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)

                if let hitResult = results.first {
                    print(hitResult)
    //MARK: - Tap to create a new node
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!

                    if let diceNode = diceScene.rootNode.childNode(withName: "Dice" ,recursively: true){

                    diceNode.position = SCNVector3(
                    //colums from the matrix, colum 4 is for the position "0-scale,1-rotation,2,3-position"
                        x: hitResult.worldTransform.columns.3.x,
                        y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                        z: hitResult.worldTransform.columns.3.z
                        )
                    //diceNode.boundingSphere.radius is half of the hight of the dice
                    diceArray.append(diceNode)
                    sceneView.scene.rootNode.addChildNode(diceNode)

                        roll(dice: diceNode)
                        
                    }
                    
                    
                    
                    
                }
            }
        }
    
    //MARK: - Method to roll all
    func rollAll() {
        if !diceArray.isEmpty{
            for dice in diceArray{
                roll(dice: dice)
            }
        }
    }
    
    //MARK: - Method to roll once
    func roll (dice:SCNNode) {
        
        //pi/2 is 90 degres
        
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        //run as animation
        dice.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomX * 5),
                y: 0,
                z: CGFloat(randomZ * 5),
                duration: 0.5)
        )
    }
    //Pressed to rol all
    @IBAction func roolAgainPressed(_ sender: UIBarButtonItem) {
        
        rollAll()
    }
    
    //end move to roal all
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    
    //Ramove all dices
    @IBAction func removeDices(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty{
            for dice in diceArray{
                dice.removeFromParentNode()
            }
        }
        
    }
    
    
    
   //MARK: - call when detect an horizontal plane
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor{
            //print("Plane detected")
            
            //Change the type from ARAnchor -> ARPlaneAnchor
            let planeAnchor = anchor as! ARPlaneAnchor
            
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let planeNode = SCNNode()
            
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            
            //by default, plane node are created vertilcaly, need to be rotated
            
            //This use Radians 1pi = 180º
            
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            //Rotations only has a x component
            
            //create a grid with a png file FromApple
            
            let gridMaterial = SCNMaterial()
            
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            
            planeNode.geometry = plane
            
            //sceneView.scene.rootNode.addChildNode(node)
            //Use the node created from didAdd - node -
            
            node.addChildNode(planeNode)
            
            
            
        }else{
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
