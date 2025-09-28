import _Volatile

@main
struct Game {
  static func main() {
    let displayControll = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x0400_0000)
    displayControll.store(0x0403)

    let framebuffer = UnsafeMutablePointer<UInt16>(bitPattern: 0x0600_0000)!

    let keyinput = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x0400_0130)

    while true {
      let color: UInt16 = keyinput.load()
      for y in 0..<20 {
        for x in 0..<20 {
          framebuffer[(y + 70) * 240 + x + 110] = color
        }
      }
    }
  }
}
