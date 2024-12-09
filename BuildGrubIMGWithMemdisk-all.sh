#!/bin/sh
platform=x86_64-efi
# 构建嵌入内存盘的grub efi镜像脚本（tar/squashfs双支持，自动获取/boot分区的信息，可搭配shim-signed使用,大致流程 esp/EFI/BOOT-id/grub.efi-->esp/EFI/BOOT-id/grub.cfg-->/boot/grub/grub.cfg--->Boot Operating System
# 感谢AzureZeng（https://space.bilibili.com/156006579）提供grub嵌入memdisk思路（https://www.bilibili.com/video/BV1PCzNYtE4G） 注：esp=EFI system partition（EFI系统分区）
# 参考资料：Debian的efi镜像构建脚本：https://sources.debian.org/src/grub2/2.12-5/debian/build-efi-images/
# Fedora的grub软件包构建日志来源：https://packages.fedoraproject.org/pkgs/grub2/grub2-efi-x64/
# 1a2s3d4f1(https://github.com/1a2s3d4f1)编写

l10n_en_us() {
_title='\033[1;36m ***GRUB Secure Boot Support with font loading creating scrips*** \n *See: https://bbs.archlinux.org/viewtopic.php?id=282076 \n https://sources.debian.org/src/grub2/2.06-2/debian/build-efi-images/\033[0m'
_gpg_directory_exist='\033[1;33m[Warn] exist dircetory grub-with-memdisk, skip creating folder\033[0m'
_dir4root='\033[1;36mPlease set the block device name of disk partition where the /boot directory is located（e.g sda1）:\033[0m/dev/'
_dir4efi='\033[1;36mSet the target directory of installing grub image (e.g. /boot/esp/EFI/BOOT) :\033[0m'
_dir4efi2='\033[1;36mSet the id of grub bootloader：\033[0m'
 _wrotedir="\033[1;32m[Info] grub.eif was written to \033[0m"
_keyfile='\033[1;36mSet .key file directory：\033[0m'
_crtfile='\033[1;36mSet .crt file directory：\033[0m'
_updatesc='\033[1;36mDo you need a grub-update config script？（y/N)。 \033[0m'
_defpos='[Info]The default grub config file dir is /boot/grub/grub.cfg. Use command grub-mkconfig -o /boot/grub/grub.cfg to update setting file.'
_selectip='Choose type of memdisk ( 1.Tar archive (default), 2. Squashfs(Read-only Filesystem lzo compress) ):'
_isok='\033[1;32m[info] Done! You can exit this script now. \033[0m'
_dir4grub='Set the location of /boot/grub folder, May use /boot directory if allocaleted boot partition. or /boot/grub with no /boot part:/'
_selectip2='Do you want to use auto detectiong /boot partation feature?\n( 1.Auto detect /boot partition information (default)、2.Set /boot partition by hand ):'
}

l10n_zh_cn() {
_title='\033[1;36m ***内存盘携带字体文件的的grub生成脚本*** \n *参考： https://bbs.archlinux.org/viewtopic.php?id=282076 \n https://sources.debian.org/src/grub2/2.06-2/debian/build-efi-images/ \033[0m'
_gpg_directory_exist='\033[1;33m[警告] grub-with-memdisk目录已存在，跳过创建目录过程\033[0m'
_dir4root='\033[1;36m请输入/boot目录所在硬盘分区的块设备名（例如sda1）:\033[0m/dev/'
_dir4efi='\033[1;36m输入GRUB镜像安装位置（例如/boot/EFI分区/EFI/BOOT：\033[0m'
_dir4efi2='\033[1;36m设置GRUB引导加载器ID：\033[0m'
_wrotedir="\033[1;32m[信息]写入grub.efi到 \033[0m"
_keyfile='\033[1;36m输入.key文件路径：\033[0m'
_crtfile='\033[1;36m输入.crt文件路径：\033[0m'
_updatesc='\033[1;36m是否需要生成grub配置更新脚本？（y/N)。 \033[0m'
_defpos='[信息]此grub的配置文件默认位置是默认位置是/boot/grub/grub.cfg，用命令grub-mkconfig -o /boot/grub/grub.cfg更新grub配置。'
_selectip='选择内存盘类型（ 1.Tar无压缩格式(默认)、2.Squashfs（只读文件系统 lzo压缩）:'
_isok='\033[1;32m[信息] GRUB引导安装已完成，现在你可以关闭这个脚本了。 \033[0m'
_dir4grub='输入/boot/grub文件夹位置，如果是单独的/boot则应为/grub ，无/boot分区则可能为/boot/grub：/'
_selectip2='是否自动探测/boot分区uuid（ 1.自动检测/boot分区信息(默认)、2.手动输入 ）:'
}

l10nSupport2(){
if [[ "$LANG" = zh_CN* ]];
then l10n_zh_cn;
else l10n_en_us
fi
}

l10nSupport2
printf '%b' "${_title}\n"
if [ ! -e ./grub-with-memdisk ]
then
mkdir grub-with-memdisk
else
printf '%b' "${_gpg_directory_exist}\n"
fi
workdir=grub-with-memdisk
if [ ! -e "$workdir/memdisk/" ]
then
mkdir "$workdir/memdisk/"
mkdir "$workdir/memdisk/fonts"
cp /usr/share/grub/unicode.pf2 "$workdir/memdisk/fonts"
fi
printf '%b' "$_selectip"
read -r select1

if [ -z "$select1" ]
then select1=1
fi

if [ -e "$workdir/memdisk.tar" ]
then rm "$workdir/memdisk.tar"
fi
if [ -e "$workdir/memdisk.squashfs" ]
then rm "$workdir/memdisk.squashfs"
fi

if [ "$select1" = 1 ]
then
cd "$workdir/memdisk" || exit
tar -cf "../memdisk.tar" ./
cd ../..
else
mksquashfs "$workdir/memdisk/" "$workdir/memdisk.squashfs" -comp lzo
fi

printf '%b' "$_selectip2"
read -r select2

if [ -z "$select2" ]
then select2=1
fi
if [ "$select2" = 1 ]
then
#如果/boot目录与根目录来源于同一个设备，那么说明未分/boot分区，否则说明有划分单独的/boot分区
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
printf '%b' "${_dir4grub}"
read -r _grubdir
bootdir_uuid="/dev/$BlockDevName"
fi
BOOTDIRUUID="$(lsblk -dno UUID $bootdir_uuid)"

#printf '%b' "${_dir4grubconf}"
#read -r _grubconf

# Load config file as fedora https://discussion.fedoraproject.org/t/how-to-restore-grub-cfg-in-silverblue/105895/3
echo 'configfile ${cmdpath}/grub.cfg' > "$workdir/grub-bootstrap.cfg"
# grub引导配置文件，有需要可以自己按格式修改 例如 echo 'insmod xfs'，这就向引导配置文件里写入了一条配置
{
echo "search --no-floppy --fs-uuid --set=dev $BOOTDIRUUID";
echo 'set prefix=($dev)/@GRUBDIR1@';
echo 'export $prefix';
echo 'configfile $prefix/grub.cfg';
} > "$workdir/grub.cfg"

sed -e "s#@GRUBDIR1@#${_grubdir}#g" \
    -i "$workdir/grub.cfg"

printf '%b' "${_dir4efi}"
read -r INSTALLEFIDIR
TARGET_EFI="${INSTALLEFIDIR}"

printf '%b' "${_dir4efi2}"
read -r boot_id

#模块，可自行添加
MODULES="all_video boot btrfs cat chain configfile echo efifwsetup efinet ext2 fat font gettext gfxmenu gfxterm gfxterm_background gzio halt help hfsplus iso9660 jpeg keystatus loadenv loopback linux ls lsefi lsefimmap lsefisystab lssal memdisk minicmd normal ntfs part_apple part_msdos part_gpt password_pbkdf2 png probe reboot regexp search search_fs_uuid search_fs_file search_label sleep smbios squash4 test true video xfs zfs zfscrypt zfsinfo play cpuid tpm cryptodisk luks lvm mdraid09 mdraid1x raid5rec raid6rec"

#没有tar模块的话，grub就不能加载tar内存盘了，所以追加tar模块
if [ "$select1" = 1 ]
then
MODULES="$MODULES tar"
fi

if [ "$select1" = 1 ]
then
grub-mkimage \
-O "$platform" \
-o "$workdir/grubx64.efi" \
-p "/EFI/$boot_id" \
-m "$workdir/memdisk.tar" \
-c "$workdir/grub-bootstrap.cfg" \
--sbat '/usr/share/grub/sbat.csv' \
$MODULES
else
grub-mkimage \
-O "$platform" \
-o "$workdir/grubx64.efi" \
-p "/EFI/$boot_id" \
-m "$workdir/memdisk.squashfs" \
-c "$workdir/grub-bootstrap.cfg" \
--sbat '/usr/share/grub/sbat.csv' \
$MODULES
fi

printf '%b' "${_wrotedir} ${TARGET_EFI}\n"
sudo cp "$workdir/grubx64.efi" "$TARGET_EFI"
sudo cp "$workdir/grub.cfg" "$TARGET_EFI"
printf '%b' "${_keyfile}"
read -r KEYFILE
printf '%b' "${_crtfile}"
read -r CRTFILE
sudo sbsign --key "$KEYFILE" --cert "$CRTFILE" --output "$TARGET_EFI/grubx64.efi" "$TARGET_EFI/grubx64.efi"
printf '%b' "$_defpos\n"
printf '%b' "${_updatesc}"
read -r choose
if [ "$choose" = y ]
then
{
echo '#!/bin/sh';
echo "grub-mkconfig -o '/boot/grub/grub.cfg'" ;
} > ./update-grub-signed.sh
chmod +x ./update-grub-signed.sh
fi
printf '%b\n' "${_isok}"
