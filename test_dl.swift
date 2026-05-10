import Foundation

let url = URL(string: "https://huggingface.co/litert-community/Qwen2.5-1.5B-Instruct/resolve/main/Qwen2.5-1.5B-Instruct_multi-prefill-seq_q8_ekv1280.task")!
let session = URLSession(configuration: .default)
let sema = DispatchSemaphore(value: 0)

let task = session.downloadTask(with: url) { localURL, response, error in
    if let error = error {
        print("Error: \(error)")
    }
    if let response = response as? HTTPURLResponse {
        print("Status: \(response.statusCode)")
    }
    if let localURL = localURL {
        let attrs = try! FileManager.default.attributesOfItem(atPath: localURL.path)
        print("Size: \(attrs[.size] as! Int64)")
    }
    sema.signal()
}
task.resume()
sema.wait()
