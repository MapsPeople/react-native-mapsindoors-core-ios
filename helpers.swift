import MapsIndoors

struct ErrorObject: Codable {
    var code: MPError
    var message: String

    public func asJSON() -> String {
        toJSON(self)
    }
}; extension ErrorObject { // Don't want to lose default initializer, so this must be in an extension
    init(from mpError: MPError) {
        code = mpError
        message = String(describing: mpError)
    }
}

public func toJSON<T:Encodable>(_ object: T) -> String {
    let encoder = JSONEncoder()
    let jsonData = try! encoder.encode(object)
    let jsonStr = String(data: jsonData, encoding: .utf8)!
    return jsonStr
}

/// Provide 'type: YourType.self' if the type cannot be inferred from the type of the parameter or variable it will be used in
public func fromJSON<T:Decodable>(_ jsonString: String, type _: T.Type = T.self) throws -> T {
    let decoder = JSONDecoder()
    let result = try decoder.decode(T.self, from: jsonString.data(using: .utf8)!)
    return result
}

private func fileToClassName(_ file: String) -> String {
    return file
        .split(separator: "/").last?
        .split(separator: ".").first
        .map{String($0)} ?? file
}

private func parsePrefix(file: String, func _func: String, line: Int, col: Int) -> String {
    let className = fileToClassName(file)
    let funcName: String = _func.split(separator: "(").first.map{String($0)} ?? _func
    return "\(className).\(funcName):\(line):\(col)"
}

public  func doReject(_ reject: RCTPromiseRejectBlock, message: String,
                      _file: String = #fileID, _func: String = #function, _line: Int = #line, _col: Int = #column) {
    let prefix = parsePrefix(file: _file, func: _func, line: _line, col: _col)
    let err = ErrorObject(code: .unknownError, message: "[\(prefix)] \(message)")
    return reject("NativeError", toJSON(err), err.code)
}

public func doReject(_ reject: RCTPromiseRejectBlock, error: Error,
                      _file: String = #fileID, _func: String = #function, _line: Int = #line, _col: Int = #column) {
    let prefix = parsePrefix(file: _file, func: _func, line: _line, col: _col)
    let err = ErrorObject(code: .unknownError, message: "[\(prefix)] \(error)")
    return reject("NativeError", toJSON(err), error)
}

