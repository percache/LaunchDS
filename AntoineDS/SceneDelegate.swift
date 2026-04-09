//
//  SceneDelegate.swift
//  AntoineDS
//
//  Modified to start with exploit screen before log viewer
//

import UIKit
import CoreLocation

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var streamViewController: StreamViewController?
    var currentBackgroundTimer: Timer?
    var addBatchUponOpening: Bool = false
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        // Start with the launch animation screen
        let launchVC = LaunchAnimationViewController()
        window.rootViewController = launchVC
        window.makeKeyAndVisible()
        self.window = window
    }
    
    func scene(_ scene: UIScene, openURLContexts contexts: Set<UIOpenURLContext>) {
        guard var url = contexts.first?.url, url.pathExtension == "antoinelog" else { return }
        if !url.isFileURL {
            url = URL(fileURLWithPath: url.path)
        }
        
        if let contents = try? Data(contentsOf: url),
           let asEntry = try? JSONDecoder().decode(CodableEntry.self, from: contents),
           let rootVC = window?.rootViewController ?? UIApplication.shared.keyWindow?.rootViewController {
            if let alreadyPresenting = rootVC.presentedViewController {
                alreadyPresenting.dismiss(animated: true) {
                    rootVC.present(EntryViewController(entry: asEntry), animated: true)
                }
            } else {
                rootVC.present(EntryViewController(entry: asEntry), animated: true)
            }
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {
        currentBackgroundTimer?.invalidate()
        ApplicationMonitor.shared.stop()
        if addBatchUponOpening, let streamVC = streamViewController {
            streamVC.addBatch()
            addBatchUponOpening = false
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        backgroundModeHandler()
    }
    
    func backgroundModeHandler() {
        guard let mode = Preferences.backgroundMode else { return }
        guard ApplicationMonitor.shared.locationManager.currentAuthorizationStatus() == .authorizedAlways else {
            ApplicationMonitor.shared.sendNotification(
                title: .localized("Couldn't start background mode"),
                body: .localized("AntoineDS needs Always-On Location Authorization in order to enable Background Mode"),
                categoryId: "BackgroundModeWarnings")
            return
        }
        
        switch mode {
        case .backgroundTime(let time):
            ApplicationMonitor.shared.start()
            let tmr = Timer(timeInterval: time, repeats: false) { [unowned self] _ in
                backgroundModeFinished()
            }
            RunLoop.current.add(tmr, forMode: .default)
            currentBackgroundTimer = tmr
        case .indefinitely:
            ApplicationMonitor.shared.start()
        }
        
        ApplicationMonitor.shared.addAction(title: .localized("Pause"), actionIdentifier: "LoggingStarted", categoryIdentifier: "LoggingStarted")
        ApplicationMonitor.shared.sendNotification(
            title: .localized("Background Mode"),
            body: .localized("AntoineDS is now collecting logs in the background"),
            categoryId: "LoggingStarted")
    }
    
    func backgroundModeFinished(sendNotification: Bool = true) {
        if let streamVC = streamViewController {
            addBatchUponOpening = streamVC.logStream.isStreaming
            streamVC.logStream.cancel()
        }
        if sendNotification {
            ApplicationMonitor.shared.sendNotification(
                title: .localized("Stopped"),
                body: .localized("App has stopped collecting logs in background"),
                categoryId: nil,
                requestID: "CollectingStopped")
        }
        ApplicationMonitor.shared.stop()
        currentBackgroundTimer?.invalidate()
    }
}
