#!/bin/sh
echo 使用smartctl和fdisk需要管理员权限
lsblk -o NAME,MODEL,SIZE,PARTLABEL,LABEL
echo
echo 查看“Disk”后面的路径，例如输入“/dev/sda”选择这个硬盘，“nvmn*n*p*”是指NVME协议的固体硬盘
echo -n "选择你的设备：/dev/"
read targetdisc
echo Done $targetdisc is ok
clear
SMARTCTL_DIR=$(mktemp -d)
sudo smartctl /dev/$targetdisc -a >$SMARTCTL_DIR/Smartbuff
SmartCache=$SMARTCTL_DIR/Smartbuff
sed -i 's/START OF INFORMATION SECTION/磁盘信息/g' $SmartCache
sed -i 's/Model Number/型号/g' $SmartCache
sed -i 's/Serial Number/序列号/g' $SmartCache
sed -i 's/Firmware Version/固件版本/g' $SmartCache
sed -i "s/PCI Vendor\/Subsystem ID/PCI供应商\/子系统ID/g" $SmartCache
sed -i 's/IEEE OUI Identifier/IEEE OUI标识符/g' $SmartCache
sed -i 's/Total NVM Capacity/总NVM硬盘容量/g' $SmartCache
sed -i 's/Unallocated NVM Capacity/微分配的NVM硬盘容量/g' $SmartCache
sed -i 's/Controller ID/控制器ID/g' $SmartCache
sed -i 's/NVMe Version/NVME协议版本/g' $SmartCache
sed -i 's/Number of Namespaces/命名空间数量/g' $SmartCache
sed -i 's/Namespace/命名空间/g' $SmartCache
sed -i "s/Size\/Capacity/大小\/容量/g" $SmartCache
sed -i 's/Formatted LBA Size/格式化的LBA大小/g' $SmartCache
sed -i 's/Local Time is/当地时间是/g' $SmartCache
sed -i 's/Firmware Updates/固件更新/g' $SmartCache
sed -i 's/Optional Admin Commands/可选管理指令/g' $SmartCache
sed -i 's/Optional NVM Commands/可选NVM指令/g' $SmartCache
sed -i 's/Log Page Attributes/日志页属性/g' $SmartCache
sed -i 's/Maximum Data Transfer Size/最大数据传输大小/g' $SmartCache
sed -i 's/Warning  Comp. Temp. Threshold/警告级温度阈值/g' $SmartCache
sed -i 's/Critical Comp. Temp. Threshold/严重级温度阈值/g' $SmartCache
sed -i 's/Supported Power States/支持的电源状态/g' $SmartCache
sed -i 's/Supported LBA Sizes/支持的LBA大小/g' $SmartCache
sed -i 's/START OF SMART DATA SECTION/起始SMART自检数据/g' $SmartCache

sed -i 's/SMART overall-health self-assessment test result/SMART自检测试结果/g' $SmartCache
sed -i 's/PASSED/已通过/g' $SmartCache
sed -i 's/FAILLE/已失败/g' $SmartCache
sed -i "s/SMART\/Health Information/SMART\/健康信息/g" $SmartCache
sed -i 's/Critical Warning/严重警告标志/g' $SmartCache
sed -i 's/Temperature/温度/g' $SmartCache
sed -i 's/Celsius/摄氏度/g' $SmartCache
sed -i 's/Available Spare/可用备用空间/g' $SmartCache
sed -i 's/Threshold/阈值/g' $SmartCache
sed -i 's/Percentage Used/已用寿命百分比/g' $SmartCache
sed -i 's/Data Units Read/读取单位计数/g' $SmartCache
sed -i 's/Data Units Written/写入单位计数/g' $SmartCache
sed -i 's/Host Read Commands/主机读命令计数/g' $SmartCache
sed -i 's/Host Write Commands/主机写命令计数/g' $SmartCache
sed -i 's/Controller Busy Time/控制器忙状态时间/g' $SmartCache
sed -i 's/Power Cycles/启动-关闭循环计数/g' $SmartCache
sed -i 's/Power On Hours/通电时间（小时）/g' $SmartCache
sed -i 's/Unsafe Shutdowns/不安全关机计数/g' $SmartCache
sed -i 's/Media and Data Integrity Errors/介质与数据完整性错误计数/g' $SmartCache
sed -i 's/Error Information Log Entries/错误日志项数/g' $SmartCache
sed -i 's/Warning  Comp. /警告级/g' $SmartCache
sed -i 's/Critical Comp. /严重级/g' $SmartCache
sed -i 's/ Time:/计数:/g' $SmartCache
sed -i 's/ Sensor /传感器/g' $SmartCache
sed -i 's/Number of Namespaces/命名空间数量/g' $SmartCache

while read smartinfo
do
    echo $smartinfo
done < $SmartCache
