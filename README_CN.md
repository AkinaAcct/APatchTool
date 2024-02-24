# APatch 自动补丁工具

一个提供自定义 APatch 修补功能的脚本.

[English](./README.md)

---

这个脚本有以下功能:

- 用户自定义boot镜像路径或从当前手机获取.  
- 用户自定义KernelPatch版本. 或，默认最新.  
- 用户自定义SuperKey.[什么是SuperKey](https://github.com/bmax121/APatch/blob/main/docs/en/faq.md#what-is-superkey)  
- 支持仅修补不安装

---

## 食用方法

- 打开Termux

- 一些准备

```bash
cd ${HOME}
curl -LO https://raw.githubusercontent.com/nya-main/APatchAutoPatchTool/main/AAP.sh
chmod +x AAP.sh
```

*在此之后，您可以在执行命令 tsu 后直接运行 AAP.sh。*

- 运行

使用方法:

```
APatch Auto Patch Tool
Written by nya
Version: 1.0.0

-h, -v,                 print the usage and version.

-i [BOOT IMAGE PATH],   specify a boot image path.
-n,                     do not install the patched boot image, save the image in /storage/emulated/0/patched_boot.img, or on Linux, ${HOME}/patched_boot.img.
-k [RELEASE NAME],      specify a kernelpatch version [RELEASE NAME].
-s "STRING",            specify a superkey. Use STRING as superkey.
-V,                     verbose mode.
```

## 待办事项

- [x] 用户指定的启动映像路径。  
- [x] 用户指定的超级密钥。 
- [x] 用户指定的 KernelPatch 版本。 
- [x] 其他终端软件支持（如MT）。
- [x] Linux 支持。

---

如果您遇到任何问题，请在 GitHub 上提交问题或向我提供反馈： [Telegram](https://t.me/RhineNya)

---

特别鸣谢:

- [Magisk](https://github.com/topjohnwu/magisk): 由 magiskboot 提供支持。  
- [KernelPatch](https://github.com/bmax121/KernelPatch): 由 kptools 和 kpimg 提供支持。
