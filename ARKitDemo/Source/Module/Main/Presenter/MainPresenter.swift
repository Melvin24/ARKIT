//
//  MainPresenter.swift
//  ARKitDemo
//
//  Created by John, Melvin (Associate Software Developer) on 27/09/2017.
//  Copyright © 2017 John, Melvin (Associate Software Developer). All rights reserved.
//

import Foundation
import ARKit

class MainPresenter {
    
    weak var viewController: MainView?
    
    func randomPlane(from planes: [UUID: Plane]) -> Plane? {
        guard planes.count > 0 else {
            return nil
        }
        
        let randomIndex = arc4random_uniform(UInt32(planes.count-1))
        
        for (index, keyValueTuple) in planes.enumerated() {
            if randomIndex == UInt32(index) {
                return keyValueTuple.value
            }
        }
        
        return nil
    }
    
    func randomVector(from boundingBox: (min: SCNVector3, max: SCNVector3)) -> SCNVector3 {
        let randomX = floatBetween(boundingBox.min.x, and: boundingBox.max.x)
        let randomY = floatBetween(boundingBox.min.y, and: boundingBox.max.y)
        let randomZ: Float = floatBetween(boundingBox.min.z, and: boundingBox.max.z)
        
        return SCNVector3(randomX, randomY, randomZ)
    }
    
    // random float between upper and lower bound (inclusive)
    func floatBetween(_ first: Float,  and second: Float) -> Float {
        return (Float(arc4random()) / Float(UInt32.max)) * (first - second) + second
    }
    
    func setupSceneView(_ sceneView: ARSCNView) {
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
        
        // Set a delegate to track the number of plane anchors for providing UI feedback.
        sceneView.session.delegate = viewController
        
        sceneView.delegate = viewController
        /*
         Prevent the screen from being dimmed after a while as users will likely
         have long periods of interaction without touching the screen or buttons.
         */
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Show debug UI to view performance metrics (e.g. frames per second).
        sceneView.showsStatistics = true
        
        sceneView.autoenablesDefaultLighting = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    func makeNodeAt(position: SCNVector3) -> SCNNode {
        
        let aBox = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0)
        
        let node = SCNNode(geometry: aBox)
        
        let sphereShape = SCNPhysicsShape(geometry: aBox, options: nil)
        let sphereBody = SCNPhysicsBody(type: .dynamic, shape: sphereShape)
        
        sphereBody.mass = 1.25
//        sphereBody.categoryBitMask = CollisionTypes.shape.rawValue
        node.physicsBody = sphereBody
        aBox.firstMaterial?.diffuse.contents = UIColor.red
        // We insert the geometry slightly above the point the user tapped
        // so that it drops onto the plane using the physics engine
        node.position = position
        
        return node
    }
    
   
    func ballNode() -> SCNNode {
        let geometry:SCNGeometry = SCNSphere(radius: 0.2)
        geometry.materials.first?.diffuse.contents = UIColor.orange
        
        let ball = SCNNode(geometry: geometry)
        
        return ball
    }
    
    func debugMessage(for frame: ARFrame, trackingState: ARCamera.TrackingState) -> String {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move the device around to detect horizontal surfaces."
            
        case .normal:
            // No feedback needed when tracking is normal and planes are visible.
            message = ""
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        }
        
        return message
    }
}
