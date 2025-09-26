// Based on https://github.com/babbleberry/rpi4-osdev/blob/master/part5-framebuffer/mb.c

let VIDEOCORE_MBOX = PERIPHERAL_BASE + 0x0000B880
let MBOX_READ      = VIDEOCORE_MBOX + 0x00
let MBOX_POLL      = VIDEOCORE_MBOX + 0x10
let MBOX_SENDER    = VIDEOCORE_MBOX + 0x14
let MBOX_STATUS    = VIDEOCORE_MBOX + 0x18
let MBOX_CONFIG    = VIDEOCORE_MBOX + 0x1C
let MBOX_WRITE     = VIDEOCORE_MBOX + 0x20

let MBOX_RESPONSE  = UInt32(0x80000000)
let MBOX_FULL      = UInt32(0x80000000)
let MBOX_EMPTY     = UInt32(0x40000000)

let MBOX_REQUEST  = UInt32(0)

let MBOX_CH_POWER = UInt8(0)
let MBOX_CH_FB    = UInt8(1)
let MBOX_CH_VUART = UInt8(2)
let MBOX_CH_VCHIQ = UInt8(3)
let MBOX_CH_LEDS  = UInt8(4)
let MBOX_CH_BTNS  = UInt8(5)
let MBOX_CH_TOUCH = UInt8(6)
let MBOX_CH_COUNT = UInt8(7)
let MBOX_CH_PROP  = UInt8(8) // Request from ARM for response by VideoCore

let MBOX_TAG_SETPOWER   = UInt32(0x28001)
let MBOX_TAG_SETCLKRATE = UInt32(0x38002)

let MBOX_TAG_SETPHYWH   = UInt32(0x48003)
let MBOX_TAG_SETVIRTWH  = UInt32(0x48004)
let MBOX_TAG_SETVIRTOFF = UInt32(0x48009)
let MBOX_TAG_SETDEPTH   = UInt32(0x48005)
let MBOX_TAG_SETPXLORDR = UInt32(0x48006)
let MBOX_TAG_GETFB      = UInt32(0x40001)
let MBOX_TAG_GETPITCH   = UInt32(0x40008)

let MBOX_TAG_LAST       = UInt32(0)

enum Mailbox {
  static func request<let count: Int>(_ mail: InlineArray<count, UInt32>, ch: UInt8) -> InlineArray<count, UInt32> {
    let bufferAddress: UInt = 0x10000
    for i in 0..<count {
      MMIO.write(bufferAddress + UInt(i * 4), mail[i])
    }

    // 28-bit address (MSB) and 4-bit value (LSB)
    let r = UInt32(bufferAddress & ~0xf) | UInt32(ch & 0xf)

    // Wait until we can write
    while MMIO.read(MBOX_STATUS) & MBOX_FULL != 0 {}

    // Write the address of our buffer to the mailbox with the channel appended
    MMIO.write(MBOX_WRITE, r)

    while true {
      // Is there a reply?
      while MMIO.read(MBOX_STATUS) & MBOX_EMPTY != 0 {}

      // Is it a reply to our message?
      if r == MMIO.read(MBOX_READ) {
        var res = InlineArray<count, UInt32>(repeating: 0)
        for i in 0..<count {
          res[i] = MMIO.read(bufferAddress + UInt(i * 4))
        }
        return res
      }
    }
  }
}
