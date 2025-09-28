import _Volatile

let tileData: [UInt32] = [
  0x0011_1100,
  0x0112_2110,
  0x1121_1211,
  0x1121_1211,
  0x1122_2211,
  0x1121_1211,
  0x0121_1210,
  0x0011_1100,

  0x0011_1100,
  0x0112_2210,
  0x1121_1211,
  0x1112_2211,
  0x1121_1211,
  0x1121_1211,
  0x0112_2210,
  0x0011_1100,
]

func waitForVBlank() {
  let vcount = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x0400_0006)
  while vcount.load() >= 160 {}
  while vcount.load() < 160 {}
}

@main
struct GameMain {
  static func main() {
    let objectPalettes = UnsafeMutablePointer<UInt16>(bitPattern: 0x0500_0200)!
    objectPalettes.update(repeating: 0, count: 256)
    objectPalettes[1] = 0x001f
    objectPalettes[2] = 0x7fff
    objectPalettes[16 + 1] = 0x03e0
    objectPalettes[16 + 2] = 0x0000

    let objectTiles = UnsafeMutablePointer<UInt32>(bitPattern: 0x0601_0000)!
    objectTiles.update(from: tileData, count: tileData.count)

    let oam = UnsafeMutablePointer<ObjectAttribute>(bitPattern: 0x0700_0000)!
    oam.update(repeating: ObjectAttribute(attr0: 0x0200), count: 128)

    let displayControll = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x0400_0000)
    displayControll.store(1 << 12)

    var sprite = ObjectAttribute(x: 120 - 4, y: 80 - 4, charNo: 0, paletteNo: 0)

    while true {
      waitForVBlank()

      let key = Key.poll()
      if key.contains(.up) { sprite.y -= 1 }
      if key.contains(.down) { sprite.y += 1 }
      if key.contains(.left) { sprite.x -= 1 }
      if key.contains(.right) { sprite.x += 1 }
      if key.contains(.a) { sprite.charNo = 0 }
      if key.contains(.b) { sprite.charNo = 1 }
      if key.contains(.r) { sprite.paletteNo = 0 }
      if key.contains(.l) { sprite.paletteNo = 1 }

      oam[0] = sprite
    }
  }
}
