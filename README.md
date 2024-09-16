# APatch Auto Patch Tool

A script that provides custom patching options.
> [!WARNING]
> Still under testing!

---

This script has the following functions:

- User-specified image path or get from current Android device.  
- User-specified KernelPatch version. Or default, latest release.  
- User-specified SuperKey.[What is SuperKey?](https://apatch.top/faq.html#what-is-superkey) 
- Supports only patch but not install.
- Supports embedding KPMs.

> [!NOTE]
> Because of some problems that may occur, support for all terminal software other than Termux has been dropped.

---

## Usage

- Open Termux(**Other terminal app in Android is not support!**)

- Prepare

```bash
cd ${HOME}
curl -LO https://raw.githubusercontent.com/AkinaAcct/APatchAutoPatchTool/main/AAP.sh
chmod +x AAP.sh
```

*After this, You can directly run AAP.sh after command `tsu` is executed.*

- Run

Usage:

```shell
./AAP.sh -h
```

To enable debug mode, run:

```
APTOOLDEBUG=1 ./AAP.sh [ARGS]
```

---

If you encounter any issues, please submit an issue on github.

---

Credits:

- [Magisk](https://github.com/topjohnwu/magisk): For magiskboot

- [KernelPatch](https://github.com/bmax121/KernelPatch): For kptools and kpimg
