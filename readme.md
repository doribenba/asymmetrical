# Asymmetrical

**ADDING COLORFUL BORDERS TO YOUR IMAGES**

Asymmetrical is a native image-framing application for Apple platforms, designed to add customizable borders and frames to one or multiple images.

The app provides a simple workflow for importing images, configuring frame parameters, applying aspect-ratio presets, and exporting the resulting images.

## Features

- Import and process multiple images
- Customizable frame width
- Custom frame colors
- Aspect-ratio presets
- Square, Instagram, and Story formats
- Double Border mode with two independently configurable colors
- Asymmetrical mode with non-uniform frame dimensions
- Optional text overlay in the bottom frame area
- Image export

## Technology

- Swift
- SwiftUI
- PhotosUI
- Core Graphics
- Xcode

## Project Structure

The project is organized around a SwiftUI-based interface and an image-processing pipeline responsible for calculating frame dimensions, rendering borders, compositing text, and exporting the final image.

## Requirements

- macOS with Xcode installed
- A compatible Apple device or simulator
- iOS version supported by the project configuration

## Installation

Clone the repository:

```bash
git clone https://github.com/your-username/asymmetrical.git
```

Open the project in Xcode:

```bash
open Asymmetrical.xcodeproj
```

Select a target device or simulator and build the project.

## License

This project is licensed under the Apache License 2.0. See the `LICENSE` file for more information.
