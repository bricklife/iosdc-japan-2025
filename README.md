# iosdc-japan-2025
iOSDC Japan 2025 day0「Embedded Swiftで解き明かすコンピューターの仕組み」のコード置き場

## トークと資料
- https://fortee.jp/iosdc-japan-2025/proposal/ddd3be00-7378-47f6-845c-b546b33f84e4
- https://www.docswell.com/s/bricklife/5QX77N-mmio-in-embedded-swift

## プロジェクト一覧

| プロジェクト | プラットフォーム | 概要 |
| --- | --- | --- |
| [gba-demo](gba-demo) | ゲームボーイアドバンス | 発表したデモ（キー入力に応じた画面描画） |
| [gba-vblank](gba-vblank) | ゲームボーイアドバンス | 1フレームごとの画面更新 |
| [gba-sprite](gba-sprite) | ゲームボーイアドバンス | タイルやカラーパレットを使ったスプライト描画 |
| [rpi-4b-blink-volatile](rpi-4b-blink-volatile) | Raspberry Pi 4B | [rpi-4b-blink](https://github.com/swiftlang/swift-embedded-examples/tree/main/rpi-4b-blink)の[swift-mmio](https://github.com/apple/swift-mmio)未使用版 |
| [rpi-4b-demo](rpi-4b-demo) | Raspberry Pi 4B | 発表したデモ（HDMI出力以外にGPIO入出力、UART、システムタイマー、PCIeを含む） |

## Embedded Swiftの準備

Xcodeに付属のSwiftではEmbedded Swiftを使うことができないので、開発版のSwift toolchainをインストールします。以下の手順のように[Swiftly](https://www.swift.org/swiftly/documentation/swiftlydocs)を使うと便利です。

1. [Getting Started with Swiftly](https://www.swift.org/swiftly/documentation/swiftly/getting-started) を参考にSwiftlyをインストールする
2. 本リポジトリをクローンしたローカルディレクトリの中で、以下のコマンドを実行する
```shell
% swiftly install
```
3. [.swift-version](.swift-version)に指定のSwift toolchain（現在は`main-snapshot-2025-09-12`）が使えるようになる
```shell
% swift --version
Apple Swift version 6.3-dev (LLVM f87967b246b2aeb, Swift 8ea97f31e555540)
Target: arm64-apple-macosx15.0
Build config: +assertions
```

## ゲームボーイアドバンス向けプロジェクトのビルドと実行

1. [gba-llvm-devkit](https://github.com/stuij/gba-llvm-devkit/releases/tag/release-v1)の`gba-llvm-devkit-1-Darwin-arm64.dmg`を任意にディレクトリに展開する
3. 以下のコマンドを実行して、環境変数`GBA_LLVM`にそのディレクトリへのパスを設定する
```shell
% export GBA_LLVM=<path to>/gba-llvm-devkit-1-Darwin-arm64
```
3. ビルドしたいプロジェクトのディレクトリで`make`すると`.build/release/Game.gba`にROMイメージが生成される
4. 生成された`Game.gba`を[mGBA](https://mgba.io)などのエミュレータで開く（実機実行のやり方は割愛）

## Raspberry Pi 4B向けプロジェクトのビルドと実行

1. [Raspberry Pi Imager](https://www.raspberrypi.com/software/)をインストールする
2. Raspberry Pi Imagerで`Raspberry Pi OS Lite (64-bit)`を選び、空のSDカードにインストールする
3. SDカードの`bootfs`ボリューム直下にある`config.txt`の最後に以下を追記する
```
[all]
core_freq_min=500
hdmi_group=1
hdmi_mode=16
```
4. ビルドしたいプロジェクトのディレクトリで`make`すると`.build/release/Application.bin`にカーネルイメージが生成される
5. 生成された`Application.bin`を`bootfs`ボリューム直下にある`kernel8.img`に上書きする
6. SDカードをRaspberry Pi 4Bに入れて電源を入れる
