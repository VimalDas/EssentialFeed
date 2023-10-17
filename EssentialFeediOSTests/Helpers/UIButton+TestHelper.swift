//
//  UIButton+TestHelper.swift
//  EssentialFeediOSTests
//
//  Created by Vimal Das on 17/10/23.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
