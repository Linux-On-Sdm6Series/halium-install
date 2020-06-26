# data/linux Touch Port
# Base Flashable With Erfan . Edit By Nobi Nobita

OUTFD=/proc/self/fd/$1;

# ui_print <text>
ui_print() { echo -e "ui_print $1\nui_print" > $OUTFD; }

## data/linux Touch Install For Whyred

# Remove Old File
rm -rf /data/rootfs.img;
rm -rf /data/system.img;
rm -rf /data/android-rootfs.img;
rm -rf /data/vendor.img;

# Copy And Patch New File
mv -f /data/ubports/data/rootfs.img /data/;
mv -f /data/ubports/data/android-rootfs.img /data/;
mv -f /data/ubports/data/vendor.img /data/;

# Create Folder Mount
mkdir -p /data/linux/Rootfs;
mkdir -p /data/linux/System;
mkdir -p /data/linux/Vendor;

# Mount *.img to Folder Mount
mount /data/rootfs.img /data/linux/Rootfs;
mount /data/android-rootfs.img /data/linux/System;
mount /data/vendor.img /data/linux/Vendor;

# Remove Stock Script
rm -rf /data/linux/Rootfs/etc/init/mount-android.conf;
rm -rf /data/linux/Rootfs/etc/rc.local;

# Patch New Script ( Dualboot )
mv -f /data/ubports/data/rootfs-mount/etc/init/mount-android.conf /data/linux/Rootfs/etc/init/;
mv -f /data/ubports/data/rootfs-mount/etc/rc.local /data/linux/Rootfs/etc/;

# Checkra1n 18/06/2020
mv -f /data/ubports/data/rootfs-mount/bin/checkra1n /data/linux/Rootfs/bin/;
chmod +x /data/linux/Rootfs/bin/checkra1n;

# Create EFS Like Samsung ( Fix Erfan Rootfs )
mkdir -p /data/linux/System/efs;

# Camera By Srfarias ( Old Camera ~ )
# chmod 0644 /data/ubports/data/camera/hw/camera.sdm660.so;
# mv -f /data/ubports/data/camera/hw/camera.sdm660.so /data/linux/Vendor/lib/hw/;
# rm -rf /data/ubports/data/camera/hw;
# chmod 0644 /data/ubports/data/camera/*.so;
# mv -f /data/ubports/data/camera/* /data/linux/Vendor/lib/;

# Chmod 0644 For File New Script
chmod 0644 /data/linux/Rootfs/etc/init/mount-android.conf;
chmod 0755 /data/linux/Rootfs/etc/rc.local;

# Include System VNDK

# Create Folder VNDK
mkdir -p /data/linux/System/lib/vndk-27;
mkdir -p /data/linux/System/lib/vndk-28;

# Chmod Folder VNDK
chmod 755 /data/linux/System/lib/vndk-27;
chmod 755 /data/linux/System/lib/vndk-28;

# Changle Owner Folder VNDK
chown root:root /data/linux/System/lib/vndk-27;
chown root:root /data/linux/System/lib/vndk-28;

# Copy File To VNDK System
cp -r /data/ubports/data/vndk/v27/arm/* /data/linux/System/lib/vndk-27/;
cp -r /data/ubports/data/vndk/v28/arm/* /data/linux/System/lib/vndk-28/;

# Include Vendor VNDK

# Chmod VNDK
chmod 0644 /data/ubports/data/vndk/v27/arm/*;
chmod 0644 /data/ubports/data/vndk/v28/arm/*;

# Changle Owner File
chown root:root /data/ubports/data/vndk/v27/arm/*;
chown root:root /data/ubports/data/vndk/v28/arm/*;

# Copy File To VNDK Vendor
cp -r /data/ubports/data/vndk/v27/arm/* /data/linux/Vendor/lib/;
cp -r /data/ubports/data/vndk/v28/arm/* /data/linux/Vendor/lib/;

# Create UDEV
cat /data/linux/System/ueventd*.rc /data/linux/Vendor/ueventd*.rc | grep ^/dev | sed -e 's/^\/dev\///' | awk '{printf "ACTION==\"add\", KERNEL==\"%s\", OWNER=\"%s\", GROUP=\"%s\", MODE=\"%s\"\n",$1,$3,$4,$2}' | sed -e 's/\r//' >/data/linux/Rootfs/etc/udev/rules.d/70-whyred.rules;

# Umount All *.img
umount /data/linux/Rootfs;
umount /data/linux/System;
umount /data/linux/Vendor;

# Remove Install file
rm -rf /data/ubports;
rm -rf /data/linux;

## Install Done ##
