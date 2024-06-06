#!/bin/sh
#by Akina | LuoYan
#2024-06-03 Rewrite

# 特殊变量
RED="\033[1;31m"          # RED
YELLOW="\033[1;33m"       # YELLOW
BLUE="\033[40;34m"        # BLUE
RESET="\033[0m"           # RESET
RANDOMNUM="$(date "+%N")" # RANDOM NUMBER

# 格式化打印消息
msg_info() { # 打印消息 格式: "[INFO] TIME: MSG"(BLUE)
	printf "${BLUE}%s${RESET}" "[INFO]$(date "+%H:%M:%S"): $1"
}
msg_warn() { # 打印消息 格式: "[WARN] TIME: MSG"(YELLOW)
	printf "${YELLOW}%s${RESET}" "[WARN]$(date "+%H:%M:%S"): $1"
}
msg_err() { # 打印消息 格式: "[ERROR] TIME: MSG"(RED)
	printf "${RED}%s${RESET}" "[ERROR]$(date "+%H:%M:%S"): $1"
}
if (command -v getprop >/dev/null 2>&1); then
	OS="android"
	msg_info "OS: ${OS}"
else
	OS="linux"
	msg_warn "You are using ${OS}. Using this script on ${OS} is still under testing."
fi

print_help() {
	echo -e "${GREEN}"
	cat <<-EOF
		APatch Auto Patch Tool
		Written by Akina
		Version: 2.1.0
		Current DIR: $(pwd)

		-h, -v,                 print the usage and version.

		-i [BOOT IMAGE PATH],   specify a boot image path.
		-n,                     do not install the patched boot image, save the image in /storage/emulated/0/patched_boot.img, or on Linux ${HOME}/patched_boot.img.
		-k [RELEASE NAME],      specify a kernelpatch version [RELEASE NAME].
		-s "STRING",            specify a superkey. Use STRING as superkey.
		-S,                     Install to another slot (for OTA).
		-E [ARGS],              Add args [ARGS] to kptools when patching.
		-V,                     verbose mode.
	EOF
	echo -e "${RESET}"
	exit 0
}

# 参数解析
while getopts ":hvi:k:IVs:SE:" OPT; do
	case $OPT in
	i) # 处理选项i
		BOOTPATH="${OPTARG}"
		if [[ -e "${BOOTPATH}" ]]; then
			msg_info "Boot image path specified. Current image path: ${BOOTPATH}"
		else
			msg_err "SPECIFIED BOOT IMAGE PATH IS WRONG! NO SUCH FILE!"
			exit 1
		fi
		;;
	h | v)
		print_help
		;;
	S)
		SAVEROOT="true"
		msg_info "The -S parameter was received. The patched image will be flashed into another slot if this is a ab partition device."
		;;
	V)
		set -x
		msg_warn "DEBUG MODE IS ON."
		;;
	I)
		if [[ "${OS}" == "android" ]]; then
			INSTALL="true"
			msg_info "The -I parameter was received. Will install after patching."
		else
			msg_err "Do not use this arg without Android!"
			exit 1
		fi
		;;
	s)
		SUPERKEY="${OPTARG}"
		msg_info "The -s parameter was received. Currently specified SuperKey: ${SUPERKEY}."
		;;
	k)
		KPTOOLVER="${OPTARG}"
		msg_info "The -k parameter was received. Will use kptool ${KPTOOLVER}."
		;;
	E)
		EXTRAARGS="${OPTARG}"
		msg_info "The -E parameter was received. Current extra args: ${EXTRAARGS}"
		;;
	:)
		msg_err "Option -${OPTARG} requires an argument.." >&2 && exit 1
		;;

	?)
		msg_err "Invalid option: -${OPTARG}" >&2 && exit 1
		;;
	esac
done

# ROOT 检测
if [[ $(id -u) -ne 0 ]]; then
	msg_err "Run this script with root!"
	exit 127
fi
# 镜像路径检测(For Linux)
if [[ $"${OS}" == "linux" && -z "${BOOTPATH}" ]]; then
	msg_err "You are using ${OS}, but there is no image specified by you. Exited."
	exit 1
fi
# 设置工作文件夹
if [[ "${OS}" == "android" ]]; then
	WORKDIR="/data/local/tmp/LuoYanTmp_${RANDOMNUM}"
else
	WORKDIR="/tmp/LuoYanTmp_${RANDOMNUM}"
fi
# 判断用户设备是否为ab分区，是则设置$BOOTSUFFIX
BYNAMEPATH="$(getprop ro.frp.pst | sed 's/\/frp//g')"
if [[ "${OS}" == "android" ]]; then
	if [[ ! -e ${BYNAMEPATH}/boot ]]; then
		BOOTSUFFIX=$(getprop ro.boot.slot_suffix)
	fi
else
	msg_warn "Current OS is: ${OS}. Skip boot slot check."
fi
if [[ -n "${SAVEROOT}" && -n "${BOOTSUFFIX}" && "${OS}" == "android" ]]; then
	if [[ "${BOOTSUFFIX}" == "_a" ]]; then
		TBOOTSUFFIX="_b"
	else
		TBOOTSUFFIX="_a"
	fi
	msg_warn "You have specified the installation to another slot. Current slot:${BOOTSUFFIX}. Slot to be flashed into:${TBOOTSUFFIX}."
fi
if [[ -z "${SUPERKEY}" ]]; then
	SUPERKEY=${LUOYANRANDOM}
fi
# 检测可能存在的APatch app, 并输出相关信息
if [[ "${OS}" == "android" ]]; then
	if (pm path me.bmax.apatch >/dev/null 2>&1); then
		msg_info "Detected that APatch is installed."
		APKPATH="$(command echo "$(pm path me.bmax.apatch)" | sed 's/base.apk//g' | sed 's/package://g')"
		APKLIBPATH="${APKPATH}lib/arm64"
		APDVER="$(${APKLIBPATH}/libapd.so -V)"
		LKPVER="$(${APKLIBPATH}/libkpatch.so -v)"
		cat <<-EOF
			Installed manager(apd) version: $(echo -e "${BLUE}${APDVER}${RESET}")
			APatch app built-in KernelPatch version: $(echo -e "${BLUE}${LKPVER}${RESET}")
		EOF
	fi
fi

# 清理可能存在的上次运行文件
rm -rf /tmp/LuoYanTmp_*
rm -rf ./LuoYanTmp_*
mkdir -p "${WORKDIR}"

msg_info "Downloading function file from GitHub..."
curl -L --progress-bar "https://raw.githubusercontent.com/nya-main/APatchAutoPatchTool/main/new/AAPFunction" -o ${WORKDIR}/AAPFunction
EXITSTATUS=$?
if [[ $EXITSTATUS != 0 ]]; then
	msg_err "SOMETHING WENT WRONG! CHECK YOUR INTERNET CONNECTION!"
	exit 1
fi

# 备份boot
if [[ "${OS}" == "android" ]]; then
	msg_info "Backing up boot image..."
	dd if=${BYNAMEPATH}/boot${BOOTSUFFIX} of=/storage/emulated/0/stock_boot${BOOTSUFFIX}.img
	EXITSTATUS=$?
	if [[ "${EXITSTATUS}" != "0" ]]; then
		msg_err "BOOT IMAGE BACKUP FAILED!"
		msg_warn "Now skiping backingup boot image..."
	else
		msg_info "Done. Boot image path: /storage/emulated/0/stock_boot${BOOTSUFFIX}.img"
	fi
else
	msg_info "Current OS: ${OS}. Skiping backup..."
fi

# 加载操作文件
source ${WORKDIR}/AAPFunction

get_device_boot
get_tools
patch_boot
if [[ -n ${INSTALL} ]]; then
	msg_warn "The -I parameter was received. Will install patched image."
	flash_boot
else
	if [[ "${OS}" == "android" ]]; then
		msg_info "Now copying patched image to /storage/emulated/0/patched_boot.img..."
		mv ${WORKDIR}/new-boot.img /storage/emulated/0/patched_boot.img
	else
		msg_info "Now copying patched image to ${HOME}/patched_boot.img..."
		mv ${WORKDIR}/new-boot.img ${HOME}/patched_boot.img
	fi
	msg_info "Done. Now deleting tmp files..."
	rm -rf ${WORKDIR}
	msg_info "Done."
fi
print_superkey
