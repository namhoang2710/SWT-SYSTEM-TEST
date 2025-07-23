//
//  PackageService.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 17/6/25.
//

import RxSwift

protocol PackageServiceProtocol {
    func fetchAll() -> Single<[Package]>
    func buyPackage(id: Int) -> Single<BuyPackageResponse>
    func fetchPurchased() -> Single<PurchasedPackagesResponse>
    func createSmokingLog(body: [String: Any]) -> Single<Void>
    func fetchSmokingLogs() -> Single<[SmokingLog]>
}

final class PackageService: PackageServiceProtocol {
    func fetchAll() -> Single<[Package]> {
        return HTTPClient.shared.request(APIEndpoints.getAllPackages)
    }
    
    func buyPackage(id: Int) -> Single<BuyPackageResponse> {
        return HTTPClient.shared.request(APIEndpoints.buyPackage(id: id))
    }
    
    func fetchPurchased() -> Single<PurchasedPackagesResponse> {
        return HTTPClient.shared.request(APIEndpoints.getPurchasedPackages)
    }
    
    func createSmokingLog(body: [String: Any]) -> Single<Void> {
        return HTTPClient.shared.requestVoid(APIEndpoints.createSmokingLog(body: body))
    }
    
    func fetchSmokingLogs() -> Single<[SmokingLog]> {
        return HTTPClient.shared.request(APIEndpoints.getSmokingLogs)
    }
}

