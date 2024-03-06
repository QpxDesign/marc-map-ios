import StoreKit
// 2:
class Store: ObservableObject {
    // 3:
    private var productIDs = ["donation1", "donation2", "donation3"]
    @Published var purchasedNonConsumables = [Product]()
    
    // 4:
    @Published var products = [Product]()
    // 5:
    init() {
        Task {
            await requestProducts()
        }
    }
    // 6:
    @MainActor
    func requestProducts() async {
        do {
            // 7:
            products = try await Product.products(for: productIDs)
        } catch {
            // 8:
            print(error)
        }
    }
    @MainActor
    func purchase(_ product: Product) async throws {
        // 1:
        let result =
        try await product.purchase()
        switch result {
            // 2:
        case .success(.verified(let transaction)):
            // 3:
            purchasedNonConsumables.append(product)
            // 4:
            await transaction.finish()

        default:
            return;
        }
    }

}
