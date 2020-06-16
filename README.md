# DUOTONE

Apply [duotone](https://en.wikipedia.org/wiki/Duotone) effects to images using GPU acceleration. Thanks to the use of Metal it's on average 75 times faster than the original [Python version](https://github.com/carloe/duotone-py).

![Sample](sample.png)

## Install

```bash
git clone git@github.com:carloe/duotone-swift.git
cd duotone
swift package update
swift build -c release
cp -f .build/release/duotone /usr/local/bin/duotone
duotone --help
```

## Usage

```bash
duotone --input input.jpg --light-color '#FFCB00' --dark-color '#38046C' --output output.png
```

## License

MIT