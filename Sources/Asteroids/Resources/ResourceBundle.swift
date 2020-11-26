import class Foundation.Bundle
import struct Foundation.URL

/// Get the module's resource URL.
///
/// This is of a workaround for now:
/// a) executable targets do not produce a `Bundle.module`
/// b) we create a separate module just for resources and copy all *.wav files.
/// c) we expose the resourceURL where this was copied
public func bundleResourcesPath() -> URL? {
    Bundle.module.resourceURL
}
