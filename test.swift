import Foundation
let data = try! Data(contentsOf: URL(fileURLWithPath: "head.txt"))
let header = data.prefix(32)
if let str = String(data: header, encoding: .utf8) {
    print("Decoded as: \(str)")
    let lower = str.lowercased()
    print("Lower: \(lower)")
    if lower.contains("<!doctype") || lower.contains("<html") || lower.contains("access denied") {
        print("FAILED!")
    } else {
        print("PASSED!")
    }
} else {
    print("Failed to decode -> returns TRUE (valid)")
}
