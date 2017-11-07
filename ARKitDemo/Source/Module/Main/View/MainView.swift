//
//  MainView.swift
//  ARKitDemo
//
//  Created by John, Melvin (Associate Software Developer) on 27/09/2017.
//  Copyright © 2017 John, Melvin (Associate Software Developer). All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class MainView: UIViewController, ARSCNViewDelegate, ARSKViewDelegate {
    
    var presenter: MainPresenter!
    
    var ringContainerNode: RingContainerNode?
    
    // A dictionary of all the current planes being rendered in the scene
    var planes: [UUID : Plane] = [:]
    
    var currentBallNode: BallNode?
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    
    // Ball throwing mechanics
    var startTouchPoint: UITouch!
    var endTouchPoint: UITouch!
    var touchingBall = false
    
    var startHitResult: SCNVector3?
    var endHitResult: SCNVector3?

    // Node that intercept touches in the scene
    lazy var touchCatchingPlaneNode: SCNNode = {
        let node = SCNNode(geometry: SCNPlane(width: 40, height: 40))
        node.opacity = 0.001
        node.castsShadow = false
        return node
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.scene.physicsWorld.gravity = SCNVector3Make(0, -6, 0)
        setupTapGestureRecogniser(for: sceneView)
        sceneView.scene.physicsWorld.contactDelegate = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard ARWorldTrackingConfiguration.isSupported else {
            sessionInfoLabel.text = "ARKit Not Supported"
            return
        }
        
        presenter.setupSceneView(sceneView)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    func setupTapGestureRecogniser(for sceneView: ARSCNView) {
        let tapGestureRec = UITapGestureRecognizer(target: self, action: #selector(tapped(recognizer:)))
        sceneView.addGestureRecognizer(tapGestureRec)
    }
    
    @objc func tapped(recognizer: UIGestureRecognizer) {
        
        guard self.ringContainerNode == nil else { return }
        
        let tapPoint = recognizer.location(in: sceneView)
        let nodeHitResult = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent)

        if let hitResult = nodeHitResult.first {
            addRingToScene(for: hitResult)
            addBallForUsers()
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        for firstTouch in touches {
            
            let location = firstTouch.location(in: sceneView)
            
            startHitResult = SCNVector3Make(Float(location.x), Float(location.y), -1.6)
            touchingBall = true
//            let hitResults = sceneView.hitTest(location, options: [:])
//            if hitResults.first?.node == currentBallNode {
//                startHitResult = hitResults.first
//                startTouchPoint = firstTouch
//            }
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        for touch in touches {
            
            let location = touch.location(in: sceneView)
            endHitResult = SCNVector3Make(Float(location.x), Float(location.y), -1.6)
            touchingBall = true
            throwBall()
//            let hitResults = sceneView.hitTest(location, options: [:])
//
//            if touchingBall {
//                endHitResult = hitResults.first
//                endTouchPoint = touch
//                touchingBall = false
//            }
        
        
        }
    }
    
    func throwBall() {
        guard let hitResultStart = self.startHitResult,
            let hitResultEnd = self.endHitResult else {
                return
        }
        
        print(hitResultStart)
        print(hitResultEnd)
        
        let changeInX = (hitResultEnd.x - hitResultStart.x)/100
        var changeInY = (hitResultEnd.y - hitResultStart.y)/100
        
        if changeInY < 0 {
            changeInY = abs(changeInY)
        }
        
        let changeInZ = hitResultEnd.z
        

//        print("MelvinEND Z", hitResultEnd.worldCoordinates.z)
//        print("MelvinSTART Z", hitResultStart.worldCoordinates.z)
//        print("MelvinEND Y", endYDirection)

//        print("starthitresult", hitResultStart)
//        print("endHitResult", hitResultEnd)
//        print("change", xChange)
        
        // Set up the balls physics properties
        guard let currentBallNode = self.currentBallNode else {
            return
        }
        
        print("MELVIN", SCNVector3Make(changeInX, changeInY, changeInZ))
        currentBallNode.physicsBody = SCNPhysicsBody(type: .dynamic,
                                                    shape: SCNPhysicsShape(geometry: currentBallNode.geometry ?? SCNSphere(radius: 0.1),
                                                                            options: nil))
//        ball.physicsBody?.categoryBitMask = pc.ball
//        ball.physicsBody?.collisionBitMask = pc.sG
//        ball.physicsBody?.contactTestBitMask = pc.base
//        ball.physicsBody?.affectedByGravity = true
//        ball.physicsBody?.isDynamic = true
        
        currentBallNode.physicsBody?.applyForce(SCNVector3Make(changeInX, changeInY, changeInZ), asImpulse: true)
        
        addBallForUsers()
  
    }

    func addRingToScene(for closestHitResult: ARHitTestResult) {
        let ringNode = RingNode()
        
        ringNode.setupRingNode(withCategoryBitMask: CollisionTypes.shape.rawValue,
                                contactTestBitMask: CollisionTypes.target.rawValue)

        
        let containerNode = RingContainerNode(withRingNode: ringNode)
        
        setPosition(hitResult: closestHitResult, withNode: containerNode)
        
        containerNode.constraints = [SCNBillboardConstraint()]

        sceneView.scene.rootNode.addChildNode(containerNode)
        
        self.ringContainerNode = containerNode
    }
    
    func addBallForUsers() {
        
        let ballNode = BallNode()
        ballNode.setupBallNode(withCategoryBitMask: CollisionTypes.shape.rawValue)

        ballNode.position = SCNVector3(x: 0, y: -0.4, z: -1)
        
        self.sceneView.pointOfView?.addChildNode(ballNode)
        self.currentBallNode = ballNode
    }
    
    
    func setPosition(hitResult: ARHitTestResult, withNode node: SCNNode) {
        
        node.position = SCNVector3Make(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y + 0.5,
            hitResult.worldTransform.columns.3.z
        )
        
    }

    
    
    func addNodeToSceneView() {
        let maxVector = SCNVector3Make(0.3, 1, -2)
        let minVector = SCNVector3Make(-0.3, 1, -2)
        
        let position = presenter.randomVector(from: (minVector, maxVector))
        
        let node = presenter.makeNodeAt(position: position)
        sceneView.pointOfView?.addChildNode(node)
    }
    
    
    func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message = presenter.debugMessage(for: frame, trackingState: trackingState)
        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty
    }
    
    /// Tells the delegate that a SceneKit node corresponding to a new AR anchor has been added to the scene.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        let plane = Plane(withAnchor: planeAnchor, hidden: false)
        self.planes[planeAnchor.identifier] = plane
        node.addChildNode(plane)
        
    }
    
    /// - Tag: UpdateARContent
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update content only for plane anchors and nodes matching the setup created in `renderer(_:didAdd:for:)`.
        guard let plane = planes[anchor.identifier],
            let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        plane.update(anchor: planeAnchor)
        
    }
    
}

extension MainView: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
    }
    
}

extension MainView {
    
    struct CollisionTypes : OptionSet {
        let rawValue: Int
        
        static let target  = CollisionTypes(rawValue: 1 << 0)
        static let shape = CollisionTypes(rawValue: 1 << 1)
    }
}
