import os
import stat
import requests
import shutil
import argparse
import random
import logging
import colorlog
from tqdm import tqdm

rnum = str(random.randint(1000000, 9999999))
skey = str(rnum)
wdir = "./TMP_" + rnum
os.mkdir(wdir)


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


logger = setup_logger()


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


def get_tool():
    kptool = "https://github.com/bmax121/KernelPatch/releases/latest/download/kptools-android"
    kpimg = (
        "https://github.com/bmax121/KernelPatch/releases/latest/download/kpimg-android"
    )
    mboot = "https://raw.githubusercontent.com/AkinaAcct/APatchTool/main/bin/magiskboot"
    logger.info("Downloading kptool...")
    download_file(kptool, wdir + "/kptool")
    logger.info("Fininshed")
    logger.info("Downloading kpimg...")
    download_file(kpimg, wdir + "/kpimg")
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
        f"./kptool --patch --kpimg kpimg --skey {skey} --image kernel {eargs} --out kernel"
    )
    logger.info("Patch fininshed.")
    logger.info("Start repack...")
    os.system(f"./magiskboot repack boot.img patched_boot.img")
    logger.info("Repack fininshed.")
    logger.info(f"Success. The patched boot is {wdir}/patched_boot.img")


def main():
    parser = argparse.ArgumentParser(description="APatch Tool.")

    # 添加参数
    parser.add_argument("imagepath", type=str, help="Boot image path")
    parser.add_argument(
        "--verbose", "-v", action="store_true", help="Enable verbose mode."
    )
    parser.add_argument(
        "-s",
        "--skey",
        type=str,
        help="Specify superkey. The default is a seven-digit number.",
    )
    parser.add_argument(
        "-E",
        "--extra",
        type=str,
        help="Extra args to kptool."
    )

    # 解析参数
    args = parser.parse_args()
    imagepath = args.imagepath
    skey = args.skey
    eargs = args.extra

    # 使用参数
    if args.verbose:
        print("Verbose mode is on.")
    if os.path.isfile(imagepath):
        print(f"Boot image path: {imagepath}")
    else:
        print(f"{imagepath}: No such file.")
        quit()
    get_tool()
    patch_boot(imagepath)


if __name__ == "__main__":
    main()
