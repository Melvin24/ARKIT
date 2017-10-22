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
    
    //category bit masks for ball node and target node
    // ball = 0001 -> 1 and target = 0010 ->2
    static let collisionRollingBall: Int = 1 << 0
    static let collsionTarget: Int = 1 << 1
    
    var finiteTimer: Timer!
    
    var presenter: MainPresenter!
    
    var ringNode: SCNNode?
    var detectorNode: SCNNode?
    
    // A dictionary of all the current planes being rendered in the scene
    var planes: [UUID : Plane] = [:]
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.scene.physicsWorld.gravity = SCNVector3Make(0, -1, 0)
        setupTapGestureRecogniser(for: sceneView)
        sceneView.scene.physicsWorld.contactDelegate = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard ARWorldTrackingConfiguration.isSupported else {
            sessionInfoLabel.text = "ARKit Not Supported"
            return
        }
        
        finiteTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: didCallTimer)
        presenter.setupSceneView(sceneView)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        
        finiteTimer.invalidate()
    }
    
    func didCallTimer(timer: Timer) {
//        addNodeToSceneView()
    }
    
    
    func addNodeToSceneView() {
        let maxVector = SCNVector3Make(0.3, 1, -2)
        let minVector = SCNVector3Make(-0.3, 1, -2)
        
        let position = presenter.randomVector(from: (minVector, maxVector))

        let node = presenter.makeNodeAt(position: position)
        sceneView.pointOfView?.addChildNode(node)
    }
    
    func setupTapGestureRecogniser(for sceneView: ARSCNView) {
        let tapGestureRec = UITapGestureRecognizer(target: self, action: #selector(tapped(recognizer:)))
        sceneView.addGestureRecognizer(tapGestureRec)
    }
    
    
    @objc func tapped(recognizer: UIGestureRecognizer) {
        let tapPoint = recognizer.location(in: sceneView)
        let nodeHitResult = sceneView.hitTest(tapPoint, options: nil)

        if let firstHitNode = nodeHitResult.first {
            let node = firstHitNode.node
            node.physicsBody?.applyForce(SCNVector3Make(-0.1, 0.1, -0.1), asImpulse: true)
//            node.isHidden = true
//            node.removeFromParentNode()
//            self.selectedNode = firstHitNode.node
//            self.hitResultWorldCoordinate = firstHitNode.worldCoordinates
        }
        
        addRingToScene(for: tapPoint)
       
    }

    func addRingToScene(for tapPoint: CGPoint) {
        let hitResult = sceneView.hitTest(tapPoint, types: [.featurePoint])
        guard ringNode == nil, let closestHitResult = hitResult.first  else {
            return
        }
        
        let detectorNode = presenter.detectorNode()
        
        ringNode = presenter.ringNode()
        self.detectorNode = detectorNode
        
        setPosition(hitResult: closestHitResult, withNode: ringNode!)
        self.detectorNode?.position = SCNVector3Make(0, 0.16, 0)
        self.ringNode?.addChildNode(self.detectorNode!)
        
        sceneView.scene.rootNode.addChildNode(ringNode!)
        
    }
    
    func setPosition(hitResult: ARHitTestResult, withNode node: SCNNode) {
        
        node.position = SCNVector3Make(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y - 0.2,
            hitResult.worldTransform.columns.3.z
        )
        
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
