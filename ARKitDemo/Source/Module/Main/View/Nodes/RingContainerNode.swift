//
//  RingContainerNode.swift
//  ARKitDemo
//
//  Created by John, Melvin (Associate Software Developer) on 01/11/2017.
//  Copyright © 2017 John, Melvin (Associate Software Developer). All rights reserved.
//

import ARKit

class RingContainerNode: SCNNode {
    
    let ringNode: RingNode
    
    init(withRingNode ringNode: RingNode) {
        self.ringNode = ringNode
        
        super.init()
        
        let boxGeometry: SCNGeometry = SCNBox(width: 0.8, height: 0.8, length: 0.8, chamferRadius: 0)
        boxGeometry.materials.first?.diffuse.contents = UIColor.clear
        
        geometry = boxGeometry
        addChildNode(ringNode)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
