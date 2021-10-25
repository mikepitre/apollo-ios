import Foundation
import CommonCrypto
#if !COCOAPODS
import ApolloUtils
#endif

/// A protocol to decouple `ApolloExtension` from `FileManager`. Use it to build objects that can support
/// `ApolloExtension` behavior.
public protocol FileManagerProvider {
  func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool
  func removeItem(atPath path: String) throws
  @discardableResult func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey : Any]?) -> Bool
  func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]?) throws
}

/// Enables the `.apollo` etension namespace.
extension FileManager: ApolloCompatible {}

/// `FileManager` conforms to the `FileManagerProvider` protocol. If it's method signatures change both the protocol and
/// extension will need to be updated.
extension FileManager: FileManagerProvider {}

extension ApolloExtension where Base: FileManagerProvider {

  // MARK: Presence

  /// Checks if the path exists and is a file, not a directory.
  ///
  /// - Parameter path: The path to check.
  /// - Returns: `true` if there is something at the path and it is a file, not a directory.
  public func existsAsFile(atPath path: String) -> Bool {
    var isDirectory = ObjCBool(false)
    let exists = base.fileExists(atPath: path, isDirectory: &isDirectory)

    return exists && !isDirectory.boolValue
  }

  /// Checks if the path exists and is a directory, not a file.
  ///
  /// - Parameter path: The path to check.
  /// - Returns: `true` if there is something at the path and it is a directory, not a file.
  public func existsAsDirectory(atPath path: String) -> Bool {
    var isDirectory = ObjCBool(false)
    let exists = base.fileExists(atPath: path, isDirectory: &isDirectory)

    return exists && isDirectory.boolValue
  }
  
  // MARK: Manipulation

  /// Removes the file or directory at the specified path.
  ///
  /// - Parameter path: The path of the file or directory to delete.
  public func delete(atPath path: String) throws {
    try base.removeItem(atPath: path)
  }

  /// Creates a file at the specified path and writes any given data to it. If a file already exists at `path`, this method overwrites the
  /// contents of that file if the current process has the appropriate privileges to do so.
  ///
  /// - Parameters:
  ///   - path: Path to the file.
  ///   - data: [optional] Data to write to the file path.
  public func createFile(atPath path: String, data: Data? = nil) throws -> Bool {
    try createContainingDirectory(forPath: path)
    return base.createFile(atPath: path, contents: data, attributes: nil)
  }

  /// Creates the containing directory (including all intermediate directories) for the given file URL if necessary.
  ///
  /// - Parameter fileURL: The URL of the file to create a containing directory for if necessary.
  public func createContainingDirectory(forPath path: String) throws {
    let parent = URL(fileURLWithPath: path).deletingLastPathComponent()
    try base.createDirectory(atPath: parent.path, withIntermediateDirectories: true, attributes: nil)
  }

  /// Creates the directory (including all intermediate directories) for the given URL if necessary.
  ///
  /// - Parameter path: The path of the directory to create if necessary.
  public func createDirectory(atPath path: String) throws {
    try base.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
  }
}
