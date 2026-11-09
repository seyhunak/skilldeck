// Renders the Skilldeck app icon into an .appiconset. Run: swift scripts/make_app_icon.swift <appiconset-dir>
import AppKit

let out = URL(fileURLWithPath: CommandLine.arguments[1])
func render(_ px: Int) -> Data {
    let s = CGFloat(px)
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8, samplesPerPixel: 4,
                               hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let inset = s * 0.1
    let rect = NSRect(x: inset, y: inset, width: s - 2 * inset, height: s - 2 * inset)
    let path = NSBezierPath(roundedRect: rect, xRadius: rect.width * 0.225, yRadius: rect.width * 0.225)
    NSGradient(colors: [NSColor(red: 0.27, green: 0.24, blue: 0.80, alpha: 1), NSColor(red: 0.10, green: 0.62, blue: 0.70, alpha: 1)])!
        .draw(in: path, angle: -60)
    // Three stacked cards.
    let cw = rect.width * 0.52, ch = rect.height * 0.36
    for i in 0..<3 {
        let off = CGFloat(i) * rect.width * 0.07
        let card = NSRect(x: rect.midX - cw / 2 - rect.width * 0.07 + off, y: rect.midY - ch / 2 + rect.height * 0.07 - off, width: cw, height: ch)
        let p = NSBezierPath(roundedRect: card, xRadius: cw * 0.12, yRadius: cw * 0.12)
        NSColor.white.withAlphaComponent([0.35, 0.6, 1.0][i]).setFill()
        p.fill()
    }
    // Spark on the front card.
    let front = NSRect(x: rect.midX - cw / 2 + rect.width * 0.07, y: rect.midY - ch / 2 - rect.height * 0.07, width: cw, height: ch)
    let cfg = NSImage.SymbolConfiguration(pointSize: ch * 0.55, weight: .bold)
    if let sym = NSImage(systemSymbolName: "sparkles", accessibilityDescription: nil)?.withSymbolConfiguration(cfg) {
        let tinted = NSImage(size: sym.size, flipped: false) { r in
            sym.draw(in: r); NSColor(red: 0.27, green: 0.24, blue: 0.80, alpha: 1).set(); r.fill(using: .sourceAtop); return true
        }
        tinted.draw(in: NSRect(x: front.midX - sym.size.width / 2, y: front.midY - sym.size.height / 2, width: sym.size.width, height: sym.size.height))
    }
    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}
var images: [[String: String]] = []
for (pt, scales) in [(16, [1, 2]), (32, [1, 2]), (128, [1, 2]), (256, [1, 2]), (512, [1, 2])] {
    for sc in scales {
        let name = "icon_\(pt)x\(pt)\(sc == 2 ? "@2x" : "").png"
        try! render(pt * sc).write(to: out.appendingPathComponent(name))
        images.append(["idiom": "mac", "size": "\(pt)x\(pt)", "scale": "\(sc)x", "filename": name])
    }
}
let json = try! JSONSerialization.data(withJSONObject: ["images": images, "info": ["version": 1, "author": "xcode"]], options: [.prettyPrinted, .sortedKeys])
try! json.write(to: out.appendingPathComponent("Contents.json"))
try! render(1024).write(to: out.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("docs/assets/icon.png"))
