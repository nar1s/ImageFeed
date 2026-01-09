import Foundation

enum Logger {
    static func logError(context: String, error: Error, request: URLRequest? = nil, extra: String? = nil) {
        var params = ""
        if let request = request {
            params += "[method: \(request.httpMethod ?? "") url: \(request.url?.absoluteString ?? "")] "
        }
        if let extra = extra {
            params += extra
        }
        print("[\(context)]: [\(type(of: error))] \(params)error: \(error)")
    }
}
