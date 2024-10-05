# APatch Auto Patch Tool

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

> [!NOTE]
> Because of some problems that may occur, support for all terminal software other than [Termux](https://github.com/Termux/termux-app) has been dropped.
> With other terminal softwares, you will get a warning and we are not responsible for problems that arise.

---

## Usage

- Open Termux(**Other terminal app in Android is not support!**)

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
