import os, stat, requests, shutil, argparse, random, logging, colorlog, platform
from tqdm import tqdm


def setup_logger():
    # 创建logger对象
    logger = logging.getLogger("APTool")
    logger.setLevel(logging.DEBUG)  # 设置最低日志级别

    # 创建控制台处理器并设置日志级别
    ch = logging.StreamHandler()
    ch.setLevel(logging.DEBUG)

    # 创建格式化器
    formatter = colorlog.ColoredFormatter(
        "%(log_color)s[%(levelname)s] %(asctime)s: %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
        log_colors={
            "DEBUG": "cyan",
            "INFO": "blue",
            "WARNING": "yellow",
            "ERROR": "red",
            "CRITICAL": "bold_red",
        },
    )

    # 将格式化器添加到处理器
    ch.setFormatter(formatter)

    # 将处理器添加到logger
    logger.addHandler(ch)

    return logger


def download_file(url, local_filename):
    # 发送请求，获取文件大小
    response = requests.get(url, stream=True)
    total_size = int(response.headers.get("content-length", 0))

    # 创建一个进度条
    with tqdm(
        total=total_size, unit="B", unit_scale=True, desc=local_filename, ascii=True
    ) as pbar:
        with open(local_filename, "wb") as file:
            for data in response.iter_content(chunk_size=1024):
                file.write(data)
                pbar.update(len(data))


def copy_file(src, dst):
    try:
        shutil.copy2(src, dst)
        print(f"Success: from {src} to {dst}.")
    except IOError as e:
        print(f"Failed: from {src} to {dst}: {e}")


def detect_os():
    system = platform.system()
    if system == "Linux":
        # 进一步检查是否为Android
        if "ANDROID_ROOT" in os.environ:
            return "android"
        else:
            return "linux"
    elif system == "Darwin":
        return "mac"
    else:
        logger.fatal(
            f"Unable to confirm the current operating system or unsupported OS! Detected OS:{system}. Aborted."
        )
        quit()


def get_tool():
    # https://github.com/bmax121/KernelPatch/releases/download/0.11.0-dev/kptools-android
    # https://github.com/bmax121/KernelPatch/releases/latest/download/kptools-android
    if kpver is None:
        kptool = f"https://github.com/bmax121/KernelPatch/releases/latest/download/kptools-{operasys}"
        kpimg = "https://github.com/bmax121/KernelPatch/releases/latest/download/kpimg-android"
    else:
        kptool = f"https://github.com/bmax121/KernelPatch/releases/download/{kpver}/kptools-{operasys}"
        kpimg = f"https://github.com/bmax121/KernelPatch/releases/download/{kpver}/kpimg-android"
    mboot = "https://raw.githubusercontent.com/AkinaAcct/APatchTool/main/bin/magiskboot"
    logger.info(f"Downloading kptool-{operasys}...")
    download_file(kptool, wdir + f"/kptool-{operasys}")
    logger.info("Fininshed")
    logger.info("Downloading kpimg-android...")
    download_file(kpimg, wdir + "/kpimg-android")
    logger.info("Fininshed.")
    logger.info("Downloading magiskboot...")
    download_file(mboot, wdir + "/magiskboot")
    logger.info("Fininshed.")
    logger.info("Set perms...")
    for root, dirs, files in os.walk(wdir):
        for filename in files:
            filepath = os.path.join(root, filename)
            st = os.stat(filepath)
            os.chmod(filepath, st.st_mode | stat.S_IEXEC)
    logger.info("Done.")


def patch_boot(bootpath):
    copy_file(bootpath, wdir + "/boot.img")
    os.chdir(wdir)
    logger.info("Start unpack...")
    os.system(f"./magiskboot unpack boot.img")
    logger.info("Unpack fininshed")
    logger.info("Start patch...")
    os.system(
        f"./kptool-{operasys} --patch --kpimg kpimg-android --skey \"{skey}\" --image kernel \"{eargs}\" --out kernel"
    )
    logger.info("Patch fininshed.")
    logger.info("Start repack...")
    os.system(f"./magiskboot repack boot.img patched_boot.img")
    logger.info("Repack fininshed.")
    logger.info(
        f"Success. The patched boot is {wdir}/patched_boot.img, superkey is \"{skey}\""
    )


def main():
    parser = argparse.ArgumentParser(description="APatch Tool.")

    # 添加参数
    parser.add_argument(
        "--ota",
        action="store_true",
        help="Install patched image to another slot(for OTA). Require root.",
    )
    parser.add_argument("IMAGEPATH", type=str, help="Boot image path")
    parser.add_argument(
        "-k",
        "--kpver",
        type=str,
        help="Specify a KernelPatch version. Default is latest release. For example, `--kpver 0.11.0-dev`",
    )
    parser.add_argument(
        "-s",
        "--skey",
        type=str,
        help="Specify superkey. The default is a seven-digit number.",
    )
    parser.add_argument("-E", "--extra", type=str, help="Extra args to kptool.")
    # 解析参数
    global rnum, wdir, args, IMAGEPATH, skey, eargs, logger, operasys, kpver
    args = parser.parse_args()
    IMAGEPATH = args.IMAGEPATH
    rnum = str(random.randint(1000000, 9999999))
    wdir = "./TMP_" + rnum
    os.mkdir(wdir)
    skey = rnum
    if args.skey != None:
        skey = args.skey
    eargs = args.extra
    kpver = args.kpver
    logger = setup_logger()
    operasys = detect_os()

    # 判断参数内容
    if os.path.isfile(IMAGEPATH):
        logger.info(f"Boot image path: {IMAGEPATH}")
    else:
        logger.fatal(f"{IMAGEPATH}: No such file.")
        quit()
    if kpver is None:
        logger.info("No KP version is specified. Use latest release.")
    else:
        logger.info(f"Received KP version. Use version: {kpver}")
    if eargs is None:
        logger.info("No extra args.")
    else:
        logger.warning(f"Received extra args: {eargs}")
    if skey is rnum:
        logger.warning(
            f"No skey provided. Using the default random number as SuperKey is not a good idea. Current SuperKey:{skey}."
        )
    else:
        logger.info(f"Received skey: {skey}")
    if args.ota:
        logger.error(f"Received the arg --ota but this feature is not yet developed.")
        quit()
    get_tool()
    patch_boot(IMAGEPATH)


# 启动
if __name__ == "__main__":
    main()
