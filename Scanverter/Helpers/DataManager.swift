import Foundation
import Combine

public class DataManager {
    static fileprivate func getDocumentsDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    @discardableResult
    static func save<T: Encodable>(_ object: T, withName fileName: String) -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { promise in
            guard let docsUrl = getDocumentsDirectory() else { return promise(.success(false)) }
            let url = docsUrl.appendingPathComponent(fileName, isDirectory: false)
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(object)
                if FileManager.default.fileExists(atPath: url.path) {
                    try FileManager.default.removeItem(at: url)
                }
                FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
            } catch let error {
                print("Saving file error \(error.localizedDescription)")
                promise(.success(false))
            }
            promise(.success(true))
        }.eraseToAnyPublisher()
    }
    
    static func load<T: Decodable>(_ fileName: String, with type: T.Type) -> T? {
        guard let docsUrl = getDocumentsDirectory() else { return nil }
        let url = docsUrl.appendingPathComponent(fileName, isDirectory: false)
        if !FileManager.default.fileExists(atPath: url.path) {
            return nil
        }
        if let data = FileManager.default.contents(atPath: url.path) {
            do {
                let model = try JSONDecoder().decode(type, from: data)
                return model
            } catch let error {
                print("Error decoding data: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }
    
    static func loadData(fromFile fileName: String) -> Data? {
        guard let docsUrl = getDocumentsDirectory() else { return nil }
        let url = docsUrl.appendingPathComponent(fileName, isDirectory: false)
        if !FileManager.default.fileExists(atPath: url.path) {
            return nil
        }
        return FileManager.default.contents(atPath: url.path)
    }
    
    static func loadAll<T: Decodable>(_ type: T.Type) -> [T] {
        guard let docsUrl = getDocumentsDirectory() else { return [] }
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: docsUrl.path)
            var modelObjects: [T] = .init()
            files
                .compactMap({ load($0, with: type) })
                .forEach { file in modelObjects.append(file) }
            return modelObjects
        } catch let error {
            print("Error loading all: \(error.localizedDescription)")
            return []
        }
    }
    
    @discardableResult
    static func delete(file fileName: String) -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { promise in
            guard let docsUrl = getDocumentsDirectory() else { return promise(.success(false)) }
            let url = docsUrl.appendingPathComponent(fileName, isDirectory: false)
            if !FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    promise(.success(false))
                }
            }
            promise(.success(true))
        }.eraseToAnyPublisher()
    }
}
