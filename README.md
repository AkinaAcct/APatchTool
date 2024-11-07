# APatchTool

Aka. APatch Auto Patch Tool

A script that provides custom patching options.
> [!WARNING]
> Still under testing!

---

This script has the following functions:

- User-specified image path or get from current Android device.  
- User-specified KernelPatch version. Or default, latest release.  
- User-specified SuperKey. [What is SuperKey?](https://apatch.top/faq.html#what-is-superkey)
- Supports directly install.
- Supports OTA updates.
- Supports embedding KPMs.

---

## Usage

### Android

- Open Termux

- Prepare

```sh
cd ${HOME}
curl -LO https://raw.githubusercontent.com/AkinaAcct/APatchAutoPatchTool/main/AAP.sh
chmod +x AAP.sh
```

- Run

Usage:

```sh
./AAP.sh -h
```

### Linux

> [!NOTE]
> This should work. If you encounter any problems, please submit an issue with logs provided by debug mode.

- Just like in Termux:

```sh
cd ${HOME}
curl -LO https://raw.githubusercontent.com/AkinaAcct/APatchAutoPatchTool/main/AAP.sh
chmod +x AAP.sh
```

- Run

Usage:

```sh
./AAP.sh -h
```

---

If you have issues or need feedback, please run `AAP.sh` in debug mode. To enable debug mode, run:

```sh
APTOOLDEBUG=1 ./AAP.sh [ARGS]
```

---

If you encounter any issues, please submit an issue on github.

---

Credits:

- [Magisk](https://github.com/topjohnwu/magisk): For magiskboot

- [KernelPatch](https://github.com/bmax121/KernelPatch): For kptools and kpimg
