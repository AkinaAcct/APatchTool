# APatch Auto Patch Tool

A script that provides custom patching options.
> [!WARNING]
> Still under testing!

---

This script has the following functions:

- User-specified image path or get from current Android device.  
- User-specified KernelPatch version. Or default, latest release.  
- User-specified SuperKey.[What is SuperKey?](https://apatch.top/faq.html#what-is-superkey) 
- Only patch but not install support.

---

## Usage

- Open Termux(or MT terminal,etc.)

- Prepare

```bash
cd ${HOME}
curl -LO https://raw.githubusercontent.com/AkinaAcct/APatchAutoPatchTool/main/AAP.sh
chmod +x AAP-New.sh
```

*After this, You can directly run AAP.sh after command tsu is executed.*

- Run

Usage:

```shell
./AAP.sh -h
```

---

## TODO

- [x] User-specified boot image path.  
- [x] User-specified Superkey.  
- [x] User-specified KernelPatch version.  
- [x] Other terminal software support(e.g. MT).  
- [x] Linux Support.  

---

If you encounter any issues, please submit a issue on github.

---

Credits:

- [Magisk](https://github.com/topjohnwu/magisk): For magiskboot

- [KernelPatch](https://github.com/bmax121/KernelPatch): For kptools and kpimg
