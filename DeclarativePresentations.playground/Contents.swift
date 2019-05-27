import Foundation
import UIKit
import PlaygroundSupport

//: ## Models
struct Product {
    let name: String
}

struct ShoppingCart {
    var products: [Product]
}

struct Receipt {
    let text: String
    let date: Date
}

extension Receipt {
    init(shoppingCart: ShoppingCart) {
        let text = shoppingCart.products.map { $0.name }.joined(separator: ", ")
        self.init(text: text, date: Date())
    }
}

//: ## App flow
struct PointOfSale {
    let getCurrentShoppingCart: () -> ShoppingCart
    let proceedToCheckout: (ShoppingCart) -> CheckoutFlow
    let storeReceipt: (Receipt) -> FutureResult<Void, Error>

    @discardableResult
    func pay(presentCheckout: (CheckoutFlow) -> FutureResult<Receipt, Error>) -> FutureResult<Void, Error> {
        let shoppingCart = self.getCurrentShoppingCart()
        let checkoutFlow = proceedToCheckout(shoppingCart)

        let future = FutureResult<Void, Error>()

        let result = presentCheckout(checkoutFlow)
        result.observe { checkoutFlowResult in
            switch checkoutFlowResult {
            case .success(let receipt):
                self.storeReceipt(receipt).observe(with: future.complete)
            case .failure(let error):
                future.reject(with: error)
            }
        }

        return future
    }
}

protocol Presentable {
    associatedtype Value
    func start() -> (UIViewController, FutureResult<Value, Error>)
}

struct CheckoutFlow: Presentable {
    let shoppingCart: ShoppingCart

    func start() -> (UIViewController, FutureResult<Receipt, Error>) {
        let receipt = Receipt(shoppingCart: self.shoppingCart)
        let future = FutureResult<Receipt, Error>()
        let actionViewController = ActionViewController(buttonTitle: "Get receipt")
        actionViewController.view.backgroundColor = .yellow
        actionViewController.onAction = {
            future.complete(with: receipt)
        }

        return (actionViewController, future)
    }
}

extension PointOfSale {
    func start() -> UIViewController {
        let actionViewController = ActionViewController(buttonTitle: "Pay")
        actionViewController.view.backgroundColor = .white
        actionViewController.onAction = {
            self.pay(presentCheckout: { checkoutFlow -> FutureResult<Receipt, Error> in
                actionViewController.present(checkoutFlow)
            })
        }
        return actionViewController
    }
}

extension UIViewController {
    func present<P: Presentable, Value>(_ presentable: P) -> FutureResult<Value, Error> where Value == P.Value {
        let (viewController, result) = presentable.start()
        self.present(viewController, animated: true, completion: nil)
        result.observe(with: { _ in
            self.dismiss(animated: true, completion: nil)
        })
        return result
    }
}
//: ## Demo
let berlinProducts = ["Curry wurst", "Club Mate", "Pfefi"].map { Product(name:$0) }

let pointOfSale = PointOfSale(getCurrentShoppingCart: {
    return ShoppingCart(products: berlinProducts)
}, proceedToCheckout: {
    return CheckoutFlow(shoppingCart: $0)
}, storeReceipt: {
    print($0)
    return FutureResult(value: ())
})

PlaygroundPage.current.liveView = pointOfSale.start()
