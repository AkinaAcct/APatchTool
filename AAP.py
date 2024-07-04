import os
import sys
import requests
from tqdm import tqdm
import random

WDIR = "./TMP_" + str(random.randint(1000000, 9999999))
os.mkdir(WDIR)


def get_tool():
    kptool = "https://github.com/bmax121/KernelPatch/releases/latest/download/kptools-android"
    kpimg = (
        "https://github.com/bmax121/KernelPatch/releases/latest/download/kpimg-android"
    )
    mboot = "https://raw.githubusercontent.com/AkinaAcct/APatchTool/main/bin/magiskboot"
    for url in [kptool, kpimg, mboot]:
        response = requests.get(url, stream=True)
        total_size = int(response.headers.get("content_length", 0))
        block_size = 1024
        progress_bar = tqdm(total=total_size, unit="iB", unit_scale=True)
        with open(save_path, "wb") as file:
            for chunk in response.iter_content(block_size):
                if not chunk:
                    break
                file.write(chunk)
                progress_bar.update(len(chunk))
        # 关闭进度条
        progress_bar.close()
        for target in [WDIR + "/kptools-android", WDIR + "/magiskboot"]:
            os.chmod(target, 0o755)


get_tool()
