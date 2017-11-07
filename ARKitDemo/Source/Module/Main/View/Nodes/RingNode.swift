//
//  RingNode.swift
//  ARKitDemo
//
//  Created by John, Melvin (Associate Software Developer) on 01/11/2017.
//  Copyright © 2017 John, Melvin (Associate Software Developer). All rights reserved.
//

import Foundation
import ARKit

class RingNode: SCNNode {
    
    override init() {
        super.init()
    }
    
    func setupRingNode(withCategoryBitMask categoryBitMask: Int, contactTestBitMask: Int) {
        
        let geometry:SCNGeometry = SCNTorus(ringRadius: 0.4, pipeRadius: 0.08)
        geometry.materials.first?.diffuse.contents = UIColor.blue
        self.geometry = geometry
        self.eulerAngles.x = -.pi / 1.6
        
        self.addChildNode(detectorNode(withCategoryBitMask: categoryBitMask, contactTestBitMask: contactTestBitMask))
        
    }
    
    func detectorNode(withCategoryBitMask categoryBitMask: Int, contactTestBitMask: Int) -> SCNNode {
        
        let aBox = SCNBox(width: 0.6, height: 0.6, length: 0.1, chamferRadius: 0.2)
        aBox.firstMaterial?.diffuse.contents = UIColor.yellow
        
        let node = SCNNode(geometry: aBox)
        node.eulerAngles.x = -.pi / 2
        
        let targetShape = SCNPhysicsShape(geometry: aBox, options: nil)
        let targetBody = SCNPhysicsBody(type: .kinematic, shape: targetShape)
        
        targetBody.restitution = 0.0
        targetBody.friction = 1.0
        
        targetBody.categoryBitMask = categoryBitMask
        targetBody.contactTestBitMask = contactTestBitMask
        
        node.physicsBody = targetBody
        node.position = SCNVector3Make(0, 0.16, 0)
        return node
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
