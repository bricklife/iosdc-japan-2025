let AUX_BASE        = PERIPHERAL_BASE + 0x215000
let AUX_ENABLES     = AUX_BASE + 0x04
let AUX_MU_IO_REG   = AUX_BASE + 0x40
let AUX_MU_IER_REG  = AUX_BASE + 0x44
let AUX_MU_IIR_REG  = AUX_BASE + 0x48
let AUX_MU_LCR_REG  = AUX_BASE + 0x4c
let AUX_MU_MCR_REG  = AUX_BASE + 0x50
let AUX_MU_LSR_REG  = AUX_BASE + 0x54
let AUX_MU_CNTL_REG = AUX_BASE + 0x60
let AUX_MU_BAUD_REG = AUX_BASE + 0x68

let AUX_UART_CLOCK = UInt(500_000_000)
let UART_MAX_QUEUE = 16 * 1024

enum UART {
  static func AUX_MU_BAUD(_ baud: UInt) -> UInt32 {
    return UInt32(AUX_UART_CLOCK / (baud * 8)) - 1
  }

  static func setup() {
    MMIO.write(AUX_ENABLES, 1)  //enable UART1
    MMIO.write(AUX_MU_IER_REG, 0)
    MMIO.write(AUX_MU_CNTL_REG, 0)
    MMIO.write(AUX_MU_LCR_REG, 3)  //8 bits
    MMIO.write(AUX_MU_MCR_REG, 0)
    MMIO.write(AUX_MU_IER_REG, 0)
    MMIO.write(AUX_MU_IIR_REG, 0xc6)  //disable interrupts
    MMIO.write(AUX_MU_BAUD_REG, AUX_MU_BAUD(115200))

    GPIO.selectFunction(pin: 14, function: .alt5)
    GPIO.selectRegistor(pin: 14, registor: .none)
    GPIO.selectFunction(pin: 15, function: .alt5)
    GPIO.selectRegistor(pin: 15, registor: .none)

    MMIO.write(AUX_MU_CNTL_REG, 3)  //enable RX/TX
  }

  static var isWriteByteReady: Bool {
    return (MMIO.read(AUX_MU_LSR_REG) & 0x20) != 0
  }

  static func writeByteBlockingActual(_ char: UInt8) {
    while !isWriteByteReady {}
    MMIO.write(AUX_MU_IO_REG, UInt32(char))
  }

  static func write(_ text: StaticString) {
    text.withUTF8Buffer { utf8 in
      for i in 0..<utf8.count {
        let c = utf8[i]
        if c == 0x0a {  // '\n'
          writeByteBlockingActual(0x0d)  // '\r'
        }
        writeByteBlockingActual(c)
      }
    }
  }

  static func writeln(_ text: StaticString) {
    write(text)
    write("\n")
  }

  static func write<Number: BinaryInteger>(hex number: Number) {
    writeByteBlockingActual(0x30)  // '0'
    writeByteBlockingActual(0x78)  // 'x'
    for i in stride(from: number.bitWidth - 4, through: 0, by: -4) {
      let n = UInt8((number >> i) & 0x0f)
      if n > 9 {
        writeByteBlockingActual(n - 10 + 0x41)
      } else {
        writeByteBlockingActual(n + 0x30)
      }
    }
  }

  static func writeln<Number: BinaryInteger>(hex number: Number) {
    write(hex: number)
    write("\n")
  }
}
