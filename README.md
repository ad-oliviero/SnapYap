# SnapYap

An iOS app for capturing a moment as a photo paired with a short voice note, a "yap".

When you take a picture it starts out blurred. To reveal it you hold the record
button and start talking: the photo sharpens as you record (8s minimum, 30s max).
Each snap is saved as a picture you can browse in a gallery, play it back, and flip over to read when it was taken.

## Built With

*   [Swift & SwiftUI](https://swift.org/) - Language and UI
*   [SwiftData](https://developer.apple.com/documentation/swiftdata/) - Persistence
*   [AVFoundation](https://developer.apple.com/documentation/avfoundation/) - Camera capture and audio recording/playback
*   [Accelerate](https://developer.apple.com/documentation/accelerate/) - Waveform signal processing

## Building

Open the project in Xcode and build to a device (camera and microphone access are required).

## License

Distributed under the MIT license, see [LICENSE](./LICENSE) for details.
