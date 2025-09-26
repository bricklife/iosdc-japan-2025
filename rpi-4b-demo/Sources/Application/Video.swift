// Based on https://github.com/babbleberry/rpi4-osdev/blob/master/part5-framebuffer/fb.c

enum Video {
  static func getFramebuffer() -> Framebuffer? {
    var mail = InlineArray<36, UInt32>(repeating: 0)
    mail[0] = 35 * 4  // Length of message in bytes
    mail[1] = MBOX_REQUEST

    mail[2] = MBOX_TAG_SETPHYWH  // Tag identifier
    mail[3] = 8  // Value size in bytes
    mail[4] = 0
    mail[5] = 1920  // Value(width)
    mail[6] = 1080  // Value(height)

    mail[7] = MBOX_TAG_SETVIRTWH
    mail[8] = 8
    mail[9] = 0
    mail[10] = 1920
    mail[11] = 1080

    mail[12] = MBOX_TAG_SETVIRTOFF
    mail[13] = 8
    mail[14] = 0
    mail[15] = 0  // Value(x)
    mail[16] = 0  // Value(y)

    mail[17] = MBOX_TAG_SETDEPTH
    mail[18] = 4
    mail[19] = 0
    mail[20] = 32  // Bits per pixel

    mail[21] = MBOX_TAG_SETPXLORDR
    mail[22] = 4
    mail[23] = 0
    mail[24] = 1  // RGB

    mail[25] = MBOX_TAG_GETFB
    mail[26] = 8
    mail[27] = 0
    mail[28] = 4096  // FrameBufferInfo.pointer
    mail[29] = 0  // FrameBufferInfo.size

    mail[30] = MBOX_TAG_GETPITCH
    mail[31] = 4
    mail[32] = 0
    mail[33] = 0  // Bytes per line

    mail[34] = MBOX_TAG_LAST

    let res = Mailbox.request(mail, ch: MBOX_CH_PROP)

    // Check call is successful and we have a pointer with depth 32
    if res[1] == MBOX_RESPONSE, res[20] == 32, res[28] != 0 {
      return Framebuffer(
        width: res[10],  // Actual physical width
        height: res[11],  // Actual physical height
        pitch: res[33],  // Number of bytes per line
        address: UInt(res[28] & 0x3fff_ffff)  // Convert GPU address to ARM address
      )
    } else {
      return nil
    }
  }
}

struct Framebuffer {
  let width: UInt32
  let height: UInt32
  let pitch: UInt32
  let address: UInt

  func dot(x: Int, y: Int, color: UInt32) {
    let offset = (UInt(bitPattern: y) * UInt(pitch)) + (UInt(bitPattern: x) * 4)
    MMIO.write(address + offset, color)
  }
}
