import _Volatile

func waitForVBlank() {
  let vcount = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x0400_0006)
  while vcount.load() >= 160 {}
  while vcount.load() < 160 {}
}

@main
struct GameMain {
  static func main() {
    let displayControll = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x0400_0000)
    displayControll.store(0x0403)

    let framebuffer = UnsafeMutablePointer<UInt16>(bitPattern: 0x0600_0000)!
    for y in 0..<160 {
      for x in 0..<240 {
        let color = UInt16(x ^ y)
        framebuffer[y * 240 + x] = color
      }
    }

    var x = 120
    var y = 80
    var dx = 1
    var dy = 1
    while true {
      waitForVBlank()
      framebuffer[y * 240 + x] = 0x7fff
      x += dx
      y += dy
      if x == 0 { dx = 1 }
      if x == 239 { dx = -1 }
      if y == 0 { dy = 1 }
      if y == 159 { dy = -1 }
    }
  }
}
