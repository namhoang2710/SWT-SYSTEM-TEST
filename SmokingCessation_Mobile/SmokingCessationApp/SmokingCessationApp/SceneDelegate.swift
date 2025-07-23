//
//  SceneDelegate.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 3/6/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene,
                 willConnectTo session: UISceneSession,
                 options connectionOptions: UIScene.ConnectionOptions) {

          guard let windowScene = (scene as? UIWindowScene) else { return }
          let window = UIWindow(windowScene: windowScene)
          self.window = window

//        if let token = UserDefaults.standard.string(forKey: "authToken"), !token.isEmpty {
          if let cookies = HTTPCookieStorage.shared.cookies(for: BaseAPI.baseURL),
             cookies.contains(where: { $0.name == "JSESSIONID" }) {
              // Optional: You might want to verify the cookie hasn't expired.
              // If it's there, assume "logged in" and go straight to HomeTabBarController.
              let homeTabBar = HomeTabBarController()
              window.rootViewController = homeTabBar
              window.makeKeyAndVisible()
          } else {
              // No session cookie => show login flow
              let diContainer = DIContainer.shared.container
              let coordinator = AppCoordinator(window: window, container: diContainer)
              self.appCoordinator = coordinator
              coordinator.start()
          }
      }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else { return }
        DeepLinkManager.handle(url: urlContext.url)
    }

}

