# APatch Auto Patch Tool

A script that provides custom patching options.

[中文](./README_CN.md)

---

This script has the following functions:

- User-specified image path or get from current Android device.  
- User-specified KernelPatch version. Or default, latest release.  
- User-specified SuperKey.[What is SuperKey?](https://apatch.top/faq.html#what-is-superkey) 
- Only patch but not install support.

---

## Usage

- Open Termux

- Prepare

```bash
cd ${HOME}
curl -LO https://raw.githubusercontent.com/nya-main/APatchAutoPatchTool/main/AAP.sh
chmod +x AAP.sh
```

*After this, You can directly run AAP.sh after command tsu is executed.*

- Run

Usage:
```text
APatch Auto Patch Tool
Written by Akina
Version: 1.0.1
Current DIR: $(pwd)

-h, -v,                 print the usage and version.

-i [BOOT IMAGE PATH],   specify a boot image path.
-n,                     do not install the patched boot image, save the image in /storage/emulated/0/patched_boot.img, or on Linux /home/atopes/patched_boot.img.
-k [RELEASE NAME],      specify a kernelpatch version [RELEASE NAME].
-s "STRING",            specify a superkey. Use STRING as superkey.
-S,                     Install to another slot (for OTA).
-E [ARGS],              Add args [ARGS] to kptools when patching.
-V,                     verbose mode.
```

---

## TODO

- [x] User-specified boot image path.  
- [x] User-specified Superkey.  
- [x] User-specified KernelPatch version.  
- [x] Other terminal software support(e.g. MT).  
- [x] Linux Support.  

---


If you encounter any issues, please submit a issue on github or provide feedback to me: [Telegram](https://t.me/RhineNya)

---

Credits:

- [Magisk](https://github.com/topjohnwu/magisk): For magiskboot

- [KernelPatch](https://github.com/bmax121/KernelPatch): For kptools and kpimg
