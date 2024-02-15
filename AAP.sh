#!/system/bin/sh
#by nya
#2024-02-06

RED="\E[1;31m"
YELLOW="\E[1;33m"
BLUE="\E[1;34m"
GREEN="\E[1;32m"
RESET="\E[0m"

alias echo="echo -e"

# 参数解析
while getopts ":hvi:k:ns:" OPT; do
	case $OPT in
	i) # 处理选项i
		BOOTPATH="${OPTARG}"
		;;
	h | v)
		echo "${GREEN}"
		cat <<-EOF
			APatch Auto Patch Tool
			Written by nya
			Version: 1.0.0
			Current WORKDIR: ${WORKDIR}

			-h, -v,                 print the usage and version.

			-i [BOOT IMAGE PATH],   specify a boot image path.
			-n,                     do not install the patched boot image, save the image in /storage/emulated/0/patched_boot.img.
			-s "STRING",            specify a superkey. Use STRING as superkey.
		EOF
		echo "${RESET}"
		exit 0
		;;
	n)
		NOINSTALL=true
		echo "${BLUE}I: The -n parameter was received. Won't install after patch.${RESET}"
		;;
	s)
		SUPERKEY="${OPTARG}"
		echo "${BLUE}I: The -s parameter was received. Currently specified SuperKey: ${SUPERKEY}.${RESET}"
		;;
	k)
		KPTOOLVER="${OPTARG}"
		echo "${BLUE}I: The -k parameter was received. Will use kptool ${KPTOOLVER}.${RESET}"
		;;
	:)
		echo "${YELLOW}W: Option -$OPTARG requires an argument..${RESET}" >&2 && exit 1
		;;

	?)
		echo "${RED}E: Invalid option: -$OPTARG${RESET}" >&2 && exit 1
		;;
	esac
done

# ROOT 检测
if [[ "$(id -u)" != "0" ]]; then
	echo "${RED}E: RUN THIS SCRIPT WITH ROOT PERMISSION!${RESET}"
	exit 2
fi
# Android 检测
if ! (command -v getprop >/dev/null 2>&1); then
	echo "${RED}E: RUN THIS SCRIPT IN ANDROID/TERMUX!!${RESET}"
	exit 1
fi
# 判断用户输入的boot镜像路径是否正确
if [[ -n "${BOOTPATH}" ]]; then
	if [[ -e "${BOOTPATH}" ]]; then
		echo "${BLUE}I: Boot image path specified. Current boot path: ${BOOTPATH}${RESET}"
	else
		echo "${RED}E: SPECIFIED BOOT IMAGE PATH IS WRONG! NO SUCH FILE!${RESET}"
		exit 1
	fi
fi
# 判断用户设备是否为ab分区，是则设置$BOOTSUFFIX
if [[ ! -e /dev/block/by-name/boot ]]; then
	BOOTSUFFIX=$(getprop ro.boot.slot_suffix)
fi
if [[ -z "${SUPERKEY}" ]]; then
	SUPERKEY=${RANDOM}
fi

WORKDIR=/data/adb/nyatmp

# 清理可能存在的上次运行文件
rm -rf ${WORKDIR}

mkdir -p ${WORKDIR}
echo "${BLUE}I: Downloading files from GitHub...${RESET}"
curl -L --progress-bar "https://raw.githubusercontent.com/nya-main/APatchAutoPatchTool/main/AAPFunction" -o ${WORKDIR}/AAPFunction
EXITSTATUS=$?
if [[ $EXITSTATUS != 0 ]]; then
	echo "${RED}E: SOMETHING WENT WRONG! CHECK YOUR INTERNET CONNECTION!${RESET}"
	exit 1
fi
echo "${BLUE}I: Backing up boot image...${RESET}"
dd if=/dev/block/by-name/boot${BOOTSUFFIX} of=/storage/emulated/0/stock_boot.img
EXITSTATUS=$?
if [[ "${EXITSTATUS}" != "0" ]]; then
	echo "${RED}E: BOOT IMAGE BACKUP FAILED!${RESET}"
	echo "${YELLOW}W: Now skiping backingup boot image...${RESET}"
else
	echo "${GREEN}I: Done. Boot image path: /storage/emulated/0/stock_boot.img${RESET}"
fi

# 加载操作文件
source ${WORKDIR}/AAPFunction

get_device_boot
get_tools
patch_boot
if ${NOINSTALL}; then
	echo "${YELLOW}W: The -n parameter was received. Won't flash the boot partition.${RESET}"
	echo "${BLUE}I: Now copying patched image to /storage/emulated/0/patched_boot.img...${RESET}"
	mv ${WORKDIR}/new-boot.img /storage/emulated/0/patched_boot.img
	rm -rf ${WORKDIR}
	echo "${GREEN}I: Done.${RESET}"
	exit 0
else
	flash_boot
fi
print_superkey
