// Based on https://github.com/swiftlang/swift-embedded-examples/blob/main/rpi-4b-blink/Sources/Application/Application.swift

import Support
import _Volatile

func setLedOutput() {
  let GPFSEL4 = VolatileMappedRegister<UInt32>(
    unsafeBitPattern: 0xFE00_0000 + 0x200010
  )
  var value = GPFSEL4.load()
  value |= (1 << 6)
  GPFSEL4.store(value)
}

func ledOn() {
  let GPSET1 = VolatileMappedRegister<UInt32>(
    unsafeBitPattern: 0xFE00_0000 + 0x200020
  )
  GPSET1.store(1 << 10)
}

func ledOff() {
  let GPCLR1 = VolatileMappedRegister<UInt32>(
    unsafeBitPattern: 0xFE00_0000 + 0x20002c
  )
  GPCLR1.store(1 << 10)
}

func delay() {
  for _ in 1..<1_000_000 { nop() }
}

@main
struct Application {
  static func main() {
    setLedOutput()
    while true {
      ledOn()
      delay()
      ledOff()
      delay()
    }
  }
}
