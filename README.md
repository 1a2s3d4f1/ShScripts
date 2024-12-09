# ShScripts
简易sh脚本，提供更方便的操作，下面是脚本说明：
=========================================

 **用于GRUB安全启动**
====================

        * [CreateSignedGrub2.sh](#createsignedgrub2sh) —— gpg签名法+生成单独的grub efi镜像(在ArchLinux上配合shim-signed测试成功）
        * [BuildGrubIMGWithMemdisk-all.sh](#buildgrubimgwithmemdisk-allsh) —— 生成带含有字体文件的内存盘的grub镜像，解决grub在安全启动下字体异常问题（例如Arch Linux)
  
## CreateSignedGrub2.sh
简易sh脚本，用于创建带gpg签名的grub efi镜像，可解决grub在安全启动模式下不加载字体导致异常问题
![屏幕截图_20241122_175253](https://github.com/user-attachments/assets/23a81ac7-39a3-4404-8a72-eb3e3de9f28b)

## BuildGrubIMGWithMemdisk-all.sh
用另一种方式解决Grub在启用安全启动的情况下无法加载字体问题，通过生成带Mendisk的efi镜像实现字体加载，感谢[AzureZeng](https://space.bilibili.com/156006579)提供的[解决思路](https://www.bilibili.com/video/BV1PCzNYtE4G),生成的efi镜像小于第一个脚本生成的
![屏幕截图_20241209_215954](https://github.com/user-attachments/assets/fc80352b-9da7-40c0-b941-458ab955aa1c)

## TranslatesSMARTinfo.sh
用于把smartctl输出的信息转为中文
![屏幕截图_20241209_223444](https://github.com/user-attachments/assets/5c1fbb56-4b7f-47ce-b18d-defc76facd97)
