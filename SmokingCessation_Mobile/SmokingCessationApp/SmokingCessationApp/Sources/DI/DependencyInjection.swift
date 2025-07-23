//
//  DependencyInjection.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 3/6/25.
//

import Foundation
import Swinject

/// Central Swinject container
final class DIContainer {
    static let shared = DIContainer()
    let container = Container()

    private init() {
        registerDependencies()
    }

    func resolve<Service>(_ serviceType: Service.Type) -> Service? {
          return container.resolve(serviceType)
    }

    private func registerDependencies() {
        // Register HTTPClient
        container.register(HTTPClient.self) { _ in
            HTTPClient.shared
        }.inObjectScope(.container)

        // AuthService depends on HTTPClient
        container.register(AuthServiceProtocol.self) { resolver in
            let client = resolver.resolve(HTTPClient.self)!
            return AuthService(httpClient: client)
        }
        container.register(PackageServiceProtocol.self) { _ in
            return PackageService()
        }
        // LoginViewModel depends on AuthService
        container.register(LoginViewModel.self) { resolver in
            let authService = resolver.resolve(AuthServiceProtocol.self)!
            return LoginViewModel(authService: authService)
        }

        // RegisterViewModel
        container.register(RegisterViewModel.self) { resolver in
            let authService = resolver.resolve(AuthServiceProtocol.self)!
            return RegisterViewModel(authService: authService)
        }

        // LoginCoordinator depends on a UINavigationController
        container.register(LoginCoordinator.self) { (_, navController: UINavigationController) in
            return LoginCoordinator(navigationController: navController, container: self.container)
        }
        container.register(PackagesViewModel.self) { resolver in
            let packageService = resolver.resolve(PackageServiceProtocol.self)!
            return PackagesViewModel(service: packageService)
        }

        container.register(CoachServiceProtocol.self) { _ in CoachService() }
        
        container.register(BlogServiceProtocol.self) { _ in BlogService() }

        container.register(MemberServiceProtocol.self) { _ in MemberService() }
    }
}
