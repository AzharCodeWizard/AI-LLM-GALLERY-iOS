import Foundation
let data = Data(repeating: 0, count: 10)
let url = URL(fileURLWithPath: "head.txt")
let attrs = try! FileManager.default.attributesOfItem(atPath: url.path)
if let size = attrs[.size] as? Int64 {
    print("Int64 size: \(size)")
} else {
    print("Not Int64, type is: \(type(of: attrs[.size]!))")
    let num = attrs[.size] as! NSNumber
    print("NSNumber size: \(num.int64Value)")
}
