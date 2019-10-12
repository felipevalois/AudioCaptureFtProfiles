//
//  extensions.swift
//  AudioCaptureFtProfiles
//
//  Created by Felipe Costa on 10/11/19.
//  Copyright © 2019 Felipe Costa. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    func addTargetForAction(target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
    }
}
