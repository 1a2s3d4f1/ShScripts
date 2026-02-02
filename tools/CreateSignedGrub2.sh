#!/bin/sh
l10n_en_us() {
_title='\033[1;36m ***GRUB Secure Boot Support with font loading creating scrips*** \n *See: https://bbs.archlinux.org/viewtopic.php?id=282076 \033[0m'
_gpg_directory_exist='\033[1;33m[Warn] dircetory GrubMake or key file already existed, skip creating folder\033[0m'
_gen_gpg_signature='Creating GPG Signature...'
_dir4root='\033[1;36mPlease input the block device name of disk partition where the /boot directory is located（e.g sda1）:\033[0m/dev/'
_dir4efi='\033[1;36mInput the target directory of installing grub image (e.g. /boot/esp/EFI/BOOT) :\033[0m'
_wrotedir="\033[1;32m[Info] grub.eif was written to \033[0m"
_keyfile='\033[1;36mInput .key file directory：\033[0m'
_crtfile='\033[1;36mInput .crt file directory：\033[0m'
_updatesc='\033[1;36mDo you need a grub-update config script？（y/N)。 \033[0m'
_defpos='[Info]The default grub config file dir is /boot/grub/grub.cfg. Use command grub-mkconfig -o /boot/grub/grub.cfg to update setting file.'
_selectip='Choose installing mode ( 1.Install with all modules (default), 2.Install with less module(part_msdos part_gpt), 3.Select required modules by hand ):'
_isok='\033[1;32m[info] Done! You can exit this script now. \033[0m'
_dir4grubconf='Input the location of /grub directory, e.g /boot/grub or /grub :/'
_selectip2='Do you want to use auto detectiong /boot partation feature?\n( 1.Auto detect /boot partition information (default)、2.Set /boot partition by hand ):'
}

l10n_zh_cn() {
_title='\033[1;36m ***带签名+GPG签名可加载字体grub创建脚本*** \n *参考： https://bbs.archlinux.org/viewtopic.php?id=282076 \033[0m'
_gpg_directory_exist='\033[1;33m[警告] GrubMake目录或Key文件已存在，跳过创建目录过程\033[0m'
_gen_gpg_signature='创建GPG签名中...'
_dir4root='\033[1;36m请输入/boot目录所在硬盘分区的块设备名（例如sda1）:\033[0m/dev/'
_dir4efi='\033[1;36m输入GRUB镜像安装位置（例如/boot/EFI分区/EFI/BOOT：\033[0m'
_wrotedir="\033[1;32m[信息]写入grub.efi到 \033[0m"
_keyfile='\033[1;36m输入.key文件路径：\033[0m'
_crtfile='\033[1;36m输入.crt文件路径：\033[0m'
_updatesc='\033[1;36m是否需要生成grub配置更新脚本？（y/N)。 \033[0m'
_defpos='[信息]此grub的配置文件默认位置是默认位置是/boot/grub/grub.cfg，用命令grub-mkconfig -o /boot/grub/grub.cfg更新grub配置。'
_selectip='选择安装方式（ 1.所有模块安装(默认)、2.最小模块安装，只有mbr与gpt分区表识别模块、3.手动输入需要的模块 ）:'
_isok='\033[1;32m[信息] GRUB引导安装已完成，现在你可以关闭这个脚本了。 \033[0m'
_dir4grubconf='输入配置文件grub文件夹所在位置，例如/boot/grub或者/grub：/'
_selectip2='是否自动探测/boot分区uuid（ 1.自动检测/boot分区信息(默认)、2.手动输入 ）:'
}

l10nSupport2(){
if [[ "$LANG" = zh_CN* ]];
then l10n_zh_cn;
else l10n_en_us
fi
}

l10nSupport(){
if [ -z "$LANGUAGE" ];
then l10nSupport2
elif [ "$LANGUAGE" = zh_CN ];
then l10n_zh_cn;
else l10n_en_us
fi
}

l10nSupport
printf '%b' "${_title}\n"
if [ ! -e ./GrubMake ]
then
mkdir GrubMake
else
printf '%b' "${_gpg_directory_exist}\n"
fi
cd GrubMake || exit
if [ ! -e ./keys ]
then
printf '%b' "${_gen_gpg_signature}\n"
mkdir --mode 0700 keys
gpg --homedir keys --full-gen-key
gpg --homedir keys --> boot.key

printf '%b' "${_gpg_directory_exist}\n"
fi

printf '%b' "$_selectip2"
read -r select2

if [ -z "$select2" ]
then select2=1
fi

if [ "$select2" = 1 ]
then
bootdir_uuid="$(df --output=source /boot | grep '/dev/')"
rootdir_uuid="$(df --output=source / | grep '/dev/')"
if [ "$bootdir_uuid" = "$rootdir_uuid" ]; then
_grubdir=boot/grub
else
_grubdir=grub
fi
else
lsblk -o NAME,PATH,SIZE,PARTLABEL,LABEL
printf '%b' "${_dir4root}"
read -r BlockDevName
printf '%b' "${_dir4grubconf}"
read -r _grubdir
bootdir_uuid="/dev/$BlockDevName"
fi
BOOTDIRUUID="$(lsblk -dno UUID $bootdir_uuid)"

{
echo "set check_signatures=enforce";
echo "export check_signatures";
echo "search --no-floppy --fs-uuid --set=root '$BOOTDIRUUID'";
echo "configfile '/$_grubdir/grub.cfg' # Change to your grub.cfg file location e.g. /@boot/boot/grub/grub.cfg with a btrfs setup";
echo "echo /grub.cfg did not boot the system, rebooting in 10 seconds.";
echo "sleep 10";
echo "reboot"; } > grub.init.cfg
gpg --homedir keys --detach-sign grub.init.cfg
cp /usr/share/grub/unicode.pf2 .
gpg --homedir keys --detach-sign unicode.pf2
printf '%b' "${_dir4efi}"
read -r INSTALLEFIDIR
# See https://bbs.archlinux.org/viewtopic.php?id=282076  https://projectacrn.github.io/latest/tutorials/acrn-secure-boot-with-grub.html http://www.fit-pc.com/wiki/index.php?title=Linux:_Secure_Boot
TARGET_EFI="${INSTALLEFIDIR}/grubx64.efi"

printf '%b' "$_selectip"
read -r CHOSE1
if [ -z "$CHOSE1" ]
then CHOSE1=1
fi
# GRUB doesn't allow loading new modules from disk when secure boot is in
# effect, therefore pre-load the required modules.

## I wasn't using the modules in the article I was using modules I found on UEFI Secureboot archwiki, I included them all for testing will be removing what im not using eventually, modules I used are listed below

MODULES="all_video boot btrfs cat chain configfile echo efifwsetup efinet ext2 fat font gettext gfxmenu gfxterm gfxterm_background gzio halt help hfsplus iso9660 jpeg keystatus loadenv loopback linux ls lsefi lsefimmap lsefisystab lssal memdisk minicmd normal ntfs part_apple part_msdos part_gpt password_pbkdf2 png probe reboot regexp search search_fs_uuid search_fs_file search_label sleep smbios squash4 test true video xfs zfs zfscrypt zfsinfo play cpuid tpm cryptodisk luks lvm mdraid09 mdraid1x raid5rec raid6rec"

if [ "$CHOSE1" = 1 ];
then
grub-mkstandalone --directory /usr/lib/grub/x86_64-efi --format x86_64-efi --modules "${MODULES}" --pubkey ./boot.key --sbat /usr/share/grub/sbat.csv --output ./grubx64.efi "boot/grub/grub.cfg=./grub.init.cfg" "boot/grub/grub.cfg.sig=./grub.init.cfg.sig"
elif [ "$CHOSE1" = 2 ] ;
then grub-mkstandalone --directory /usr/lib/grub/x86_64-efi --format x86_64-efi --modules "part_msdos part_gpt" --pubkey ./boot.key --sbat /usr/share/grub/sbat.csv --output ./grubx64.efi "boot/grub/grub.cfg=./grub.init.cfg" "boot/grub/grub.cfg.sig=./grub.init.cfg.sig"
elif [ "$CHOSE1" = 3 ];
then
printf '%b\n' "Modules:"
read -r HANDMODULES
grub-mkstandalone --directory /usr/lib/grub/x86_64-efi --format x86_64-efi --modules "${HANDMODULES}" --pubkey ./boot.key --sbat /usr/share/grub/sbat.csv --output ./grubx64.efi "boot/grub/grub.cfg=./grub.init.cfg" "boot/grub/grub.cfg.sig=./grub.init.cfg.sig"
fi

printf '%b' "${_wrotedir} ${TARGET_EFI}\n"
sudo cp ./grubx64.efi "$TARGET_EFI"
printf '%b' "${_keyfile}"
read -r KEYFILE
printf '%b' "${_crtfile}"
read -r CRTFILE
sudo sbsign --key "$KEYFILE" --cert "$CRTFILE" --output "$TARGET_EFI" "$TARGET_EFI"
if [ ! -e /boot/grub/fonts/ ];then
sudo mkdir /boot/grub/fonts/
fi
sudo cp unicode.pf2 unicode.pf2.sig /boot/grub/fonts/
printf '%b' "$_defpos\n"
printf '%b' "${_updatesc}"
read -r choose
if [ "$choose" = y ]
then
{
echo '#!/bin/sh';
echo "grub-mkconfig -o '/boot/grub/grub.cfg'" ;
} > ../update-grub-signed.sh
chmod +x ../update-grub-signed.sh
fi
printf '%b\n' "${_isok}"
