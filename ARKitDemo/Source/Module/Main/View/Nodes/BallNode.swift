//
//  BallNode.swift
//  ARKitDemo
//
//  Created by John, Melvin (Associate Software Developer) on 01/11/2017.
//  Copyright © 2017 John, Melvin (Associate Software Developer). All rights reserved.
//

import ARKit

class BallNode: SCNNode {
    
    override init() {
        super.init()

        let geometry:SCNGeometry = SCNSphere(radius: 0.15)
        geometry.materials.first?.diffuse.contents = UIColor.orange
        
        self.geometry = geometry
    }
    
    func setupBallNode(withCategoryBitMask categoryBitMask: Int) {
        self.categoryBitMask = categoryBitMask
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
