# APatch Auto Patch Tool

A script that provides custom patching options.

---

This script will:

- Obtain the current boot image of your phone.
- Download the latest KernelPatch and magiskboot from GitHub Release.
- Patch the extracted boot image.
- Flash the patched image.

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
```
APatch Auto Patch Tool
Written by nya
Version: 1.0.0
Current WORKDIR: /data/local/tmp/nyatmp_1994

-h, -v,                 print the usage and version.

-i [BOOT IMAGE PATH],   specify a boot image path.
-n,                     do not install the patched boot image, save the image in /storage/emulated/0/patched_boot.img.
-k [RELEASE NAME],      specify a kernelpatch version [RELEASE NAME].
-s "STRING",            specify a superkey. Use STRING as superkey.
-V,                     verbose mode.
```

---

## TODO

- [x] User-specified boot image path.  
- [x] User-specified Superkey.  
- [x] Specify KernelPatch version.  
- [ ] Other terminal software support(e.g. MT).  
- [ ] Linux Support.  

---


If you encounter any issues, please submit a issue on github or provide feedback to me: [Telegram](https://t.me/RhineNya)

---

Credits:

- [Magisk](https://github.com/topjohnwu/magisk): For magiskboot

- [KernelPatch](https://github.com/bmax121/KernelPatch): For kptools and kpimg
