# data/linux Touch Port
# Base Flashable With Erfan . Edit By Nobi Nobita

OUTFD=/proc/self/fd/$1;

# ui_print <text>
ui_print() { echo -e "ui_print $1\nui_print" > $OUTFD; }

## data/linux Touch Install For Whyred

#-----------------------
rm -rf /data/rootfs.img;
rm -rf /data/android-rootfs.img;
rm -rf /data/vendor.img;
#-----------------------
mv -f /data/ubports/data/rootfs.img /data/;
mv -f /data/ubports/data/android-rootfs.img /data/;
mv -f /data/ubports/data/vendor.img /data/;
#------------------------------------------
mkdir -p /data/linux/Rootfs;
mkdir -p /data/linux/System;
mkdir -p /data/linux/Vendor;
#---------------------------
mount /data/rootfs.img /data/linux/Rootfs;
mount /data/android-rootfs.img /data/linux/System;
mount /data/vendor.img /data/linux/Vendor;
#-----------------------------------------
rm -rf /data/linux/Rootfs/etc/init/mount-android.conf;
rm -rf /data/linux/Rootfs/etc/rc.local;
#----------------------------------------------------------------------------------------------
mv -f /data/ubports/data/rootfs-mount/etc/init/mount-android.conf /data/linux/Rootfs/etc/init/;
mv -f /data/ubports/data/rootfs-mount/etc/rc.local /data/linux/Rootfs/etc/;
#--------------------------------------------------------------------------
chmod 0644 /data/linux/Rootfs/etc/init/mount-android.conf;
chmod 0755 /data/linux/Rootfs/etc/rc.local;
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
cat /data/linux/System/ueventd*.rc /data/linux/Vendor/ueventd*.rc | grep ^/dev | sed -e 's/^\/dev\///' | awk '{printf "ACTION==\"add\", KERNEL==\"%s\", OWNER=\"%s\", GROUP=\"%s\", MODE=\"%s\"\n",$1,$3,$4,$2}' | sed -e 's/\r//' >/data/linux/Rootfs/etc/udev/rules.d/70-whyred.rules;
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
umount /data/linux/Rootfs;
umount /data/linux/System;
umount /data/linux/Vendor;
#------------------------
rm -rf /data/ubports;
rm -rf /data/linux;
#------------------
## Install Done
