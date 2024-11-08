//
//  Tipstore.swift
//  WasteNot
//
//  Created by LUU THANH TAM on 2024/07/28.
//

import Foundation
import StoreKit

// MARK: - typealias
typealias PurchaseResult = Product.PurchaseResult
typealias TransactionListener = Task<Void, Error>

// MARK: - Enums
enum TipsError: LocalizedError {
    case failedVerification
    case system(Error)
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "User transaction verification failed"
        case .system(let error):
            return error.localizedDescription
        }
    }
}
enum TipsAction: Equatable {
    static func == (lhs: TipsAction, rhs: TipsAction) -> Bool {
        switch (lhs, rhs) {
        case (.successful, .successful):
            return true
        case (let .failed(lhsError), let .failed(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
    
    case successful
    case failed(TipsError)
}
// MARK: - TIPSTORE Class
@MainActor
final class TipStore: ObservableObject {
    // MARK: Property
    
    @Published private(set) var items = [Product]()
    @Published private(set) var action: TipsAction? {
        didSet {
            switch action {
            case .failed:
                hasError = true
            default:
                hasError = false
            }
        }
    }
    
    @Published var hasError = false
    var error: TipsError? {
        switch action {
        case .failed(let error):
            return error
        default:
            return nil
        }
    }
    
    private var transactionListener: TransactionListener?
    
    // MARK: Initializer
    init() {
        
        transactionListener = configureTransactionListener()
        
        Task { [weak self] in
            await self?.retrieveProducts()
        }
    }
    
    // MARK: Deinitializer
    deinit {
        transactionListener?.cancel()
    }
    
    // MARK: Functions
    func purchase(_ item: Product) async {
        do {
            let result = try await item.purchase()
            try await handlePurchase(from: result)
            
        } catch {
            action = .failed(.system(error))
            print(error)
        }
    }
    
    func reset() {
        action = nil
    }
}

// MARK: - Extension for TipStore
private extension TipStore {
    
    func configureTransactionListener() -> TransactionListener {
        Task.detached(priority: .background) { @MainActor [weak self] in
            do {
                for await result in Transaction.updates {
                    let transaction = try self?.checkVerified(result)
                    self?.action = .successful
                    await transaction?.finish()
                }
            } catch {
                self?.action = .failed(.system(error))
                print(error)
            }
        }
    }
    
    func retrieveProducts() async {
        do {
            let products = try await Product.products(for: tipProductsIdentifiers).sorted(by: { $0.price < $1.price })
            items = products
        } catch {
            action = .failed(.system(error))
            print(error)
        }
    }
    
    func handlePurchase(from result: PurchaseResult) async throws {
        switch result {
        case .success(let verification):
            print("Purchase was a success, now it's time to verify their purchase")
            
            let transaction = try checkVerified(verification)
            
            action = .successful
            UserDefaults.standard.set(true, forKey: "Tipped")
            await transaction.finish()
        case .pending:
            print("The user needs to complete some action on their account before they can complete purchase")
        case .userCancelled:
            print("The user hit cancel before their transaction started")
        default:
            break
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            print("The verification of the user failed")
            throw TipsError.failedVerification
            
        case .verified(let safe):
            return safe
        }
    }
}
