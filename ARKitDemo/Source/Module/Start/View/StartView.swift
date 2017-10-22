//
//  StartView.swift
//  ARKitDemo
//
//  Created by John, Melvin (Associate Software Developer) on 27/09/2017.
//  Copyright © 2017 John, Melvin (Associate Software Developer). All rights reserved.
//

import UIKit

class StartView: UIViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination as? MainView
        
        let presenter = MainPresenter()
        
        presenter.viewController = destination
        
        destination?.presenter = presenter
        
    }
    
}
