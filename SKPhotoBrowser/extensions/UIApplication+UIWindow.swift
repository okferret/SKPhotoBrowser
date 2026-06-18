//
//  UIApplication+UIWindow.swift
//  SKPhotoBrowser
//
//  Created by Josef Dolezal on 25/09/2017.
//  Copyright © 2017 suzuki_keishi. All rights reserved.
//

import UIKit

internal extension UIApplication {
    var preferredApplicationWindow: UIWindow? {
        // Since delegate window is of type UIWindow??, we have to
        // unwrap it twice to be sure the window is not nil
        if let appWindow = UIApplication.shared.delegate?.window, let window = appWindow {
            return window
        }

        // On iOS 13+ the app may use multiple scenes, so prefer the active
        // foreground scene's key window before falling back to the deprecated API.
        if #available(iOS 13.0, *) {
            let windows = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .filter { $0.activationState == .foregroundActive }
                .flatMap { $0.windows }

            if let keyWindow = windows.first(where: { $0.isKeyWindow }) ?? windows.first {
                return keyWindow
            }
        }

        return UIApplication.shared.keyWindow
    }
}
