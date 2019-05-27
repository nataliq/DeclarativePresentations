import Foundation

/// An encapsulation of a result that might take time to asynchronously produce
public class FutureResult<Value, FutureError: Error> {
    private lazy var callbacks = [(Result<Value, FutureError>) -> Void]()

    public init(value: Value? = nil) {
        result = value.map { Result.success($0) }
    }

    public func observe(with callback: @escaping (Result<Value, FutureError>) -> Void) {
        callbacks.append(callback)
        result.map(callback)
    }

    public func complete(with result: Result<Value, FutureError>) {
        self.result = result
    }

    public func complete(with value: Value) {
        result = .success(value)
    }

    public func reject(with error: FutureError) {
        result = .failure(error)
    }

    private var result: Result<Value, FutureError>? {
        didSet { result.map(report) }
    }

    private func report(result: Result<Value, FutureError>) {
        for callback in callbacks {
            callback(result)
        }
    }
}



/*:
 More info:

 The above implementation is a simplified version of [John's blog post](https://www.swiftbysundell.com/posts/under-the-hood-of-futures-and-promises-in-swift).
 A good implementation is not way longer though. Note that here we're not taking care properly of removing the added observers.

 Some other resources to consider:
 - [iZettle/Flow](https://github.com/iZettle/Flow)
 - [Google/Promises](https://github.com/google/promises)
 - [PromiseKit](https://github.com/mxcl/PromiseKit)
 - [FutureKit](https://github.com/FutureKit/FutureKit)
 - various articles (like [Deriving Future](https://medium.com/izettle-engineering/deriving-future-607aea9abdee) by Måns Bernhardt) and reactive programming libraries
 */
