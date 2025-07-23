import Foundation
import UIKit
import RxSwift

/// Handles incoming URLs and performs side-effects (such as API calls).
struct DeepLinkManager {
    private static let disposeBag = DisposeBag()
    static func handle(url: URL) {
        guard url.scheme == "smokingcessation" else { return }
        // Example: smokingcessation://verification?code=UUID
        if url.host == "verification" {
            if let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?
                .first(where: { $0.name == "code" })?.value {

                print("Received verification code: \(code)")
                // Hit the verify endpoint
                DIContainer.shared
                    .resolve(AuthServiceProtocol.self)!
                    .verify(code: code)
                    .observe(on: MainScheduler.instance)
                    .subscribe(onSuccess: {
                        print("✅ Verification success for code \(code)")

                        // Navigate to Login screen (pop to root of primary navigation)
                        if let window = UIApplication.shared.connectedScenes
                            .compactMap({ $0 as? UIWindowScene })
                            .first?.windows.first(where: { $0.isKeyWindow }),
                           let root = window.rootViewController {

                            // Dismiss any modals
                            root.dismiss(animated: true, completion: nil)

                            var targetVC: UIViewController?
                            if let nav = root as? UINavigationController {
                                nav.popToRootViewController(animated: true)
                                targetVC = nav
                            } else if let tab = root as? UITabBarController,
                                      let nav = tab.selectedViewController as? UINavigationController {
                                nav.popToRootViewController(animated: true)
                                tab.selectedIndex = 0
                                targetVC = nav
                            } else {
                                targetVC = root
                            }

                            let vc = VerificationResultViewController(result: .success(message: "Xác thực thành công! Hãy đăng nhập."))
                            targetVC?.present(vc, animated: true)
                        }
                    }, onFailure: { err in
                        print("❌ Verification failed: \(err.localizedDescription)")
                        if let window = UIApplication.shared.connectedScenes
                            .compactMap({ $0 as? UIWindowScene })
                            .first?.windows.first(where: { $0.isKeyWindow }),
                           let root = window.rootViewController {
                            let vc = VerificationResultViewController(result: .failure(message: err.localizedDescription))
                            root.present(vc, animated: true)
                        }
                    })
                    .disposed(by: disposeBag)
            }
        }
    }
} 
 