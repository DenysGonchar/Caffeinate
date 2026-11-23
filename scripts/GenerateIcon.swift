import AppKit

// ICNS stores PNG images in chunks with four-byte types and big-endian lengths.
func chunk(_ type: String, _ payload: Data) -> Data {
    var length = UInt32(payload.count + 8).bigEndian
    var result = Data(type.utf8)
    withUnsafeBytes(of: &length) { result.append(contentsOf: $0) }
    result.append(payload)
    return result
}

let output = URL(fileURLWithPath: CommandLine.arguments[1])
var images = Data()
let types = [16: ["icp4", "ic11"], 32: ["icp5", "ic12"],
             128: ["ic07", "ic13"], 256: ["ic08", "ic14"], 512: ["ic09", "ic10"]]

for size in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let pixels = size * scale
        let side = CGFloat(pixels)
        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
            isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
        ), let context = NSGraphicsContext(bitmapImageRep: bitmap),
           let symbol = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: nil)?
            .withSymbolConfiguration(NSImage.SymbolConfiguration(paletteColors: [
                NSColor(srgbRed: 0.28, green: 0.17, blue: 0.11, alpha: 1)
            ])) else {
            fatalError("Could not render application icon")
        }

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context
        NSColor(srgbRed: 1, green: 0.94, blue: 0.84, alpha: 1).setFill()
        let background = NSRect(x: side * 0.05, y: side * 0.05, width: side * 0.9, height: side * 0.9)
        NSBezierPath(roundedRect: background, xRadius: side * 0.2, yRadius: side * 0.2).fill()

        let factor = side * 0.64 / max(symbol.size.width, symbol.size.height)
        let width = symbol.size.width * factor
        let height = symbol.size.height * factor
        symbol.draw(in: NSRect(x: (side - width) / 2, y: (side - height) / 2, width: width, height: height))
        NSGraphicsContext.restoreGraphicsState()

        guard let png = bitmap.representation(using: .png, properties: [:]) else {
            fatalError("Could not encode application icon")
        }
        images.append(chunk(types[size]![scale - 1], png))
    }
}
try chunk("icns", images).write(to: output)
