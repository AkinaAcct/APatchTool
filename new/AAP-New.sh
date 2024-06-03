#!/bin/sh
#by Akina | LuoYan
#2024-06-03 Rewrite

RED="\E[1;31m"
YELLOW="\E[1;33m"
BLUE="\E[1;34m"
GREEN="\E[1;32m"
RESET="\E[0m"
LUOYANRANDOM="$(date "+%N")"
log_info() {
	echo -e "${BLUE}[INFO] $(date "+%H:%M:%S"): $1${RESET}"
}
log_err() {
	echo -e "${RED}[ERROR] $(date "+%H:%M:%S"): $1${RESET}"
}
log_warn() {
	echo -e "${YELLOW}[WARN] $(date "+%H:%M:%S"): $1${RESET}"
}

print_help() {
	echo -e "${GREEN}"
	cat <<-EOF
		APatch Auto Patch Tool
		Written by Akina
		Version: 2.0.0
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
while getopts ":hvi:k:nVs:SE:" OPT; do
	case $OPT in
	i) # 处理选项i
		BOOTPATH="${OPTARG}"
		if [[ -e "${BOOTPATH}" ]]; then
			log_info "Boot image path specified. Current image path: ${BOOTPATH}"
		else
			log_err "SPECIFIED BOOT IMAGE PATH IS WRONG! NO SUCH FILE!"
			exit 1
		fi
		;;
	h | v)
		print_help
		;;
	S)
		SAVEROOT="true"
		log_info "The -S parameter was received. The patched image will be flashed into another slot if this is a ab partition device."
		;;
	V)
		set -x
		log_warn "DEBUG MODE IS ON."
		;;
	n)
		NOINSTALL="true"
		log_info "The -n parameter was received. Won't install after patch."
		;;
	s)
		SUPERKEY="${OPTARG}"
		log_info "The -s parameter was received. Currently specified SuperKey: ${SUPERKEY}."
		;;
	k)
		KPTOOLVER="${OPTARG}"
		log_info "The -k parameter was received. Will use kptool ${KPTOOLVER}."
		;;
	E)
		EXTRAARGS="${OPTARG}"
		log_info "The -E parameter was received. Current extra args: ${EXTRAARGS}"
		;;
	:)
		log_err "Option -${OPTARG} requires an argument.." >&2 && exit 1
		;;

	?)
		log_err "Invalid option: -${OPTARG}" >&2 && exit 1
		;;
	esac
done

# OS 检测
if (command -v getprop >/dev/null 2>&1); then
	OS="android"
	log_info "OS: ${OS}"
else
	OS="linux"
	log_warn "You are using ${OS}.Using this script on ${OS} is still under testing."
	if [[ -z "${BOOTPATH}" ]]; then
		log_err "You are using ${OS}, but there is no image specified by you. Exited."
		exit 1
	fi
fi
# 设置工作文件夹
if [[ "${OS}" == "android" ]]; then
	WORKDIR="./LuoYanTmp_${LUOYANRANDOM}"
else
	WORKDIR="/tmp/LuoYanTmp_${LUOYANRANDOM}"
fi
# 判断用户设备是否为ab分区，是则设置$BOOTSUFFIX
BYNAMEPATH="$(getprop ro.frp.pst | sed 's/\/frp//g')"
if [[ "${OS}" == "android" ]]; then
	if [[ ! -e ${BYNAMEPATH}/boot ]]; then
		BOOTSUFFIX=$(getprop ro.boot.slot_suffix)
	fi
else
	log_warn "Current OS is: ${OS}. Skip boot slot check."
fi
if [[ -n "${SAVEROOT}" && -n "${BOOTSUFFIX}" && "${OS}" == "android" ]]; then
	if [[ "${BOOTSUFFIX}" == "_a" ]]; then
		TBOOTSUFFIX="_b"
	else
		TBOOTSUFFIX="_a"
	fi
	log_warn "You have specified the installation to another slot. Current slot:${BOOTSUFFIX}. Slot to be flashed into:${TBOOTSUFFIX}."
fi
if [[ -z "${SUPERKEY}" ]]; then
	SUPERKEY=${LUOYANRANDOM}
fi
# 检测可能存在的APatch app, 并输出相关信息
if [[ "${OS}" == "android" ]]; then
	if (pm path me.bmax.apatch >/dev/null 2>&1); then
		log_info "Detected that APatch is installed."
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

log_info "Downloading function file from GitHub..."
curl -L --progress-bar "https://raw.githubusercontent.com/nya-main/APatchAutoPatchTool/main/new/AAPFunction" -o ${WORKDIR}/AAPFunction
EXITSTATUS=$?
if [[ $EXITSTATUS != 0 ]]; then
	log_err "SOMETHING WENT WRONG! CHECK YOUR INTERNET CONNECTION!"
	exit 1
fi

# 备份boot
if [[ "${OS}" == "android" ]]; then
	log_info "Backing up boot image..."
	dd if=${BYNAMEPATH}/boot${BOOTSUFFIX} of=/storage/emulated/0/stock_boot${BOOTSUFFIX}.img
	EXITSTATUS=$?
	if [[ "${EXITSTATUS}" != "0" ]]; then
		log_err "BOOT IMAGE BACKUP FAILED!"
		log_warn "Now skiping backingup boot image..."
	else
		log_info "Done. Boot image path: /storage/emulated/0/stock_boot${BOOTSUFFIX}.img"
	fi
else
	log_info "Current OS: ${OS}. Skiping backup..."
fi

# 加载操作文件
source ${WORKDIR}/AAPFunction

get_device_boot
get_tools
patch_boot
if [[ -n ${NOINSTALL} ]]; then
	log_warn "The -n parameter was received. Won't install patched image."
	if [[ "${OS}" == "android" ]]; then
		log_info "Now copying patched image to /storage/emulated/0/patched_boot.img..."
		mv ${WORKDIR}/new-boot.img /storage/emulated/0/patched_boot.img
	else
		log_info "Now copying patched image to ${HOME}/patched_boot.img..."
		mv ${WORKDIR}/new-boot.img ${HOME}/patched_boot.img
	fi
	log_info "Done. Now deleting tmp files..."
	rm -rf ${WORKDIR}
	log_info "Done."
elif [[ "${OS}" != "android" ]]; then
	log_info "Current OS is: ${OS}. Won't install patched image."
else
	flash_boot
fi
print_superkey
