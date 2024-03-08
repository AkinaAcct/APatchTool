#!/bin/sh
#by nya
#2024-02-06

RED="\E[1;31m"
YELLOW="\E[1;33m"
BLUE="\E[1;34m"
GREEN="\E[1;32m"
RESET="\E[0m"

alias echo="echo -e"

print_help() {
	echo "${GREEN}"
	cat <<-EOF
		APatch Auto Patch Tool
		Written by nya
		Version: 1.0.0
		Current DIR: $(pwd)

		-h, -v,                 print the usage and version.

		-i [BOOT IMAGE PATH],   specify a boot image path.
		-n,                     do not install the patched boot image, save the image in /storage/emulated/0/patched_boot.img, or on Linux ${HOME}/patched_boot.img.
		-k [RELEASE NAME],      specify a kernelpatch version [RELEASE NAME].
		-s "STRING",            specify a superkey. Use STRING as superkey.
		-S,                     Install to another slot (for OTA).
		-V,                     verbose mode.
	EOF
	echo "${RESET}"
	exit 0
}

# 参数解析
while getopts ":hvi:k:nVs:S" OPT; do
	case $OPT in
	i) # 处理选项i
		BOOTPATH="${OPTARG}"
		if [[ -e "${BOOTPATH}" ]]; then
			echo "${BLUE}I: Boot image path specified. Current image path: ${BOOTPATH}${RESET}"
		else
			echo "${RED}E: SPECIFIED BOOT IMAGE PATH IS WRONG! NO SUCH FILE!${RESET}"
			exit 1
		fi
		;;
	h | v)
		print_help
		;;
	S)
		SAVEROOT="true"
		echo "${BLUE}I: The -S parameter was received. The patched image will be flashed into another slot if this is a ab partition device."
		;;
	V)
		set -x
		echo "${YELLOW}W: DEBUG MODE IS ON.${RESET}"
		;;
	n)
		NOINSTALL="true"
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

# 设置工作文件夹
WORKDIR="$(pwd)/nyatmp_${RANDOM}"
# ROOT 检测
if [[ "$(id -u)" != "0" ]]; then
	echo "${RED}E: RUN THIS SCRIPT WITH ROOT PERMISSION!${RESET}"
	exit 2
fi
# OS 检测
if (command -v getprop >/dev/null 2>&1); then
	OS="android"
	echo "${BLUE}I: OS: ${OS}${RESET}"
else
	OS="linux"
	echo "${YELLOW}W: You are using ${OS}.Using this script on ${OS} is still under testing.${RESET}"
	if [[ -z "${BOOTPATH}" ]]; then
		echo "${RED}E: You are using ${OS}, but there is no image specified by you. Exited.${RESET}"
		exit 1
	fi
fi
# 判断用户设备是否为ab分区，是则设置$BOOTSUFFIX
BYNAMEPATH="$(getprop ro.frp.pst | sed 's/\/frp//g')"
if [[ ! -e ${BYNAMEPATH}/boot && "${OS}" == "android" ]]; then
	BOOTSUFFIX=$(getprop ro.boot.slot_suffix)
else
	echo "${BLUE}I: Current OS is: ${OS}. Skip boot slot check.${RESET}"
fi
if [[ -n "${SAVEROOT}" && -n "${BOOTSUFFIX}" && "${OS}" == "android" ]]; then
	if [[ "${BOOTSUFFIX}" == "_a" ]]; then
		TBOOTSUFFIX="_b"
	else
		TBOOTSUFFIX="_a"
	fi
	echo "${BLUE}I: You have specified the installation to another slot. Current slot:${BOOTSUFFIX}. Slot to be flashed into:${TBOOTSUFFIX}."
fi
if [[ -z "${SUPERKEY}" ]]; then
	SUPERKEY=${RANDOM}
fi
# 检测可能存在的APatch app, 并输出相关信息
if [[ "${OS}" == "android" ]]; then
	if (pm path me.bmax.apatch >/dev/null 2>&1); then
		echo "${BLUE}I: Detected that APatch is installed.${RESET}"
		APKPATH="$(command echo "$(pm path me.bmax.apatch)" | sed 's/base.apk//g' | sed 's/package://g')"
		APKLIBPATH="${APKPATH}lib/arm64"
		APDVER="$(${APKLIBPATH}/libapd.so -V)"
		LKPVER="$(${APKLIBPATH}/libkpatch.so -v)"
		cat <<-EOF
			Installed manager(apd) version: $(echo "${BLUE}${APDVER}${RESET}")
			APatch app built-in KernelPatch version: $(echo "${BLUE}${LKPVER}${RESET}")
		EOF
	fi
fi

# 清理可能存在的上次运行文件
rm -rf ./nyatmp_*

mkdir -p ${WORKDIR}

echo "${BLUE}I: Downloading function file from GitHub...${RESET}"
curl -L --progress-bar "https://raw.githubusercontent.com/nya-main/APatchAutoPatchTool/main/AAPFunction" -o ${WORKDIR}/AAPFunction
EXITSTATUS=$?
if [[ $EXITSTATUS != 0 ]]; then
	echo "${RED}E: SOMETHING WENT WRONG! CHECK YOUR INTERNET CONNECTION!${RESET}"
	exit 1
fi

# 备份boot
if [[ "${OS}" == "android" ]]; then
	echo "${BLUE}I: Backing up boot image...${RESET}"
	dd if=${BYNAMEPATH}/boot${BOOTSUFFIX} of=/storage/emulated/0/stock_boot${BOOTSUFFIX}.img
	EXITSTATUS=$?
	if [[ "${EXITSTATUS}" != "0" ]]; then
		echo "${RED}E: BOOT IMAGE BACKUP FAILED!${RESET}"
		echo "${YELLOW}W: Now skiping backingup boot image...${RESET}"
	else
		echo "${GREEN}I: Done. Boot image path: /storage/emulated/0/stock_boot${BOOTSUFFIX}.img${RESET}"
	fi
else
	echo "${BLUE}I: Current OS: ${OS}. Skiping backup...${RESET}"
fi

# 加载操作文件
source ${WORKDIR}/AAPFunction

get_device_boot
get_tools
patch_boot
if [[ -n ${NOINSTALL} ]]; then
	echo "${YELLOW}W: The -n parameter was received. Won't install patched image.${RESET}"
	if [[ "${OS}" == "android" ]]; then
		echo "${BLUE}I: Now copying patched image to /storage/emulated/0/patched_boot.img...${RESET}"
		mv ${WORKDIR}/new-boot.img /storage/emulated/0/patched_boot.img
	else
		echo "${BLUE}I: Now copying patched image to ${HOME}/patched_boot.img...${RESET}"
		mv ${WORKDIR}/new-boot.img ${HOME}/patched_boot.img
	fi
	echo "${BLUE}I: Done. Now deleting tmp files...${RESET}"
	rm -rf ${WORKDIR}
	echo "${GREEN}I: Done.${RESET}"
elif [[ "${OS}" != "android" ]]; then
	echo "${BLUE}I: Current OS is: ${OS}. Won't install patched image.${RESET}"
else
	flash_boot
fi
print_superkey
