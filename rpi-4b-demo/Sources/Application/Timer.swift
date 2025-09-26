enum SystemTimer {
  static func now() -> UInt32 {
    return MMIO.read(0xfe00_3000 + 4)
  }

  static func sleep(microseconds: UInt32) {
    let start = now()
    while now() &- start < microseconds {}
  }
}
