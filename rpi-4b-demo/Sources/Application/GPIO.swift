// Based on https://github.com/babbleberry/rpi4-osdev/blob/master/part4-miniuart/io.c

let PERIPHERAL_BASE = UInt(0xfe000000)

let GPIO_BASE = PERIPHERAL_BASE + 0x200000
let GPFSEL0   = GPIO_BASE + 0x00
let GPFSEL4   = GPIO_BASE + 0x10
let GPSET0    = GPIO_BASE + 0x1c
let GPSET1    = GPIO_BASE + 0x20
let GPCLR0    = GPIO_BASE + 0x28
let GPCLR1    = GPIO_BASE + 0x2c
let GPLEV0    = GPIO_BASE + 0x34
let GPLEV1    = GPIO_BASE + 0x38
let GPIO_PUP_PDN_CNTRL_REG0 = GPIO_BASE + 0xe4

let GPIO_MAX_PIN = UInt(57)

enum GPIO {
  static func call(pin: UInt, value: UInt32, base: UInt, fieldSize: UInt) {
    guard pin <= GPIO_MAX_PIN else { return }

    let fieldMask = (1 << fieldSize) - 1
    guard value <= fieldMask else { return }

    let numFields = 32 / fieldSize
    let reg = base + ((pin / numFields) * 4)
    let shift = (pin % numFields) * fieldSize

    var curval = MMIO.read(reg)
    curval &= ~UInt32(fieldMask << shift)
    curval |= value << shift
    MMIO.write(reg, curval)
  }

  static func set(pin: UInt) {
    guard pin <= GPIO_MAX_PIN else { return }
    let reg = GPSET0 + ((pin / 32) * 4)
    let shift = pin % 32
    MMIO.write(reg, 1 << shift)
  }

  static func clear(pin: UInt) {
    guard pin <= GPIO_MAX_PIN else { return }
    let reg = GPCLR0 + ((pin / 32) * 4)
    let shift = pin % 32
    MMIO.write(reg, 1 << shift)
  }

  static func level(pin: UInt) -> Bool {
    guard pin <= GPIO_MAX_PIN else { return false }
    let reg = GPLEV0 + ((pin / 32) * 4)
    let shift = pin % 32
    let val = MMIO.read(reg)
    return val & UInt32(1 << shift) != 0
  }

  enum Function: UInt32 {
    case input  = 0b000
    case output = 0b001
    case alt0   = 0b100
    case alt1   = 0b101
    case alt2   = 0b110
    case alt3   = 0b111
    case alt4   = 0b011
    case alt5   = 0b010
  }

  static func selectFunction(pin: UInt, function: Function) {
    call(pin: pin, value: function.rawValue, base: GPFSEL0, fieldSize: 3)
  }

  enum Registor: UInt32 {
    case none     = 0b00
    case pullUp   = 0b01
    case pullDown = 0b10
  }

  static func selectRegistor(pin: UInt, registor: Registor) {
    call(
      pin: pin,
      value: registor.rawValue,
      base: GPIO_PUP_PDN_CNTRL_REG0,
      fieldSize: 2
    )
  }
}
