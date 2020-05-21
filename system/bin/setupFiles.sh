# ----------------------------------------
# Check Magisk support
# ----------------------------------------
checkMagisk() {
	#magisk=$(ls /data/adb/magisk/magisk || ls /sbin/magisk) 2>/dev/null;
	#magiskVersion=$($magisk -c | sed 's/-.*//')
	printMagiskVersion=$(magisk -c | cut -d':' -f1)
	magiskVersion=$(magisk -V)
	case "$magiskVersion" in
	    '15.'[1-9]*) # Version 15.1 - 15.9
	    hosts=/sbin/.core/img/.core/hosts
	    busyboxPath=/sbin/.core/img/busybox-ndk
	    return 1
	    ;;
	    '16.'[1-9]*) # Version 16.1 - 16.9
	    hosts=/sbin/.core/img/.core/hosts
	    busyboxPath=/sbin/.core/img/busybox-ndk
	    return 1
	    ;;
	    '17.'[1-3]*) # Version 17.1 - 17.3
	    hosts=/sbin/.core/img/.core/hosts
	    busyboxPath=/sbin/.core/img/busybox-ndk
	    return 1
	    ;;
	    '17.'[4-9]*) # Version 17.4 - 17.9
	    hosts=/sbin/.magisk/img/hosts/system/etc/hosts
	    busyboxPath=/sbin/.magisk/img/busybox-ndk
	    return 1
	    ;;
	    '18'[0-9]*) # Version 18.x
	    hosts=/sbin/.magisk/img/hosts/system/etc/hosts
	    busyboxPath=/sbin/.magisk/img/busybox-ndk
	    return 1
	    ;;
	    '19'[0-9a-zA-Z]*) # Version 19.x
	    hosts=/data/adb/modules/hosts/system/etc/hosts
	    busyboxPath=/data/adb/modules/busybox-ndk
	    return 1
	    ;;
	    '20'[0-9a-zA-Z]*) # Version 20.x
	    hosts=/data/adb/modules/hosts/system/etc/hosts
	    busyboxPath=/data/adb/modules/busybox-ndk
        return 1
	    ;;
	    *)
	    echo -e $R"Unknown Version: $printMagiskVersion"$N; sleep 5;
        return 0
	    ;;
    esac
}
# ----------------------------------------

# ----------------------------------------
# Check busybox 
# ----------------------------------------
checkBusybox() {
	busybox=$(ls "$busyboxPath/system/bin/busybox" || ls "$busyboxPath/system/xbin/busybox") 2>/dev/null
	busyboxAuto=$(ls /system/bin/busybox || ls /system/sbin/busybox || ls /system/xbin/busybox || ls /sbin/busybox) 2>/dev/null
	busyboxManualGzip=$(ls /system/bin/gzip || ls /system/sbin/gzip || ls /system/xbin/gzip || ls /sbin/gzip) 2>/dev/null
	busyboxManualWget=$(ls /system/bin/wget || ls /system/sbin/wget || ls /system/xbin/wget || ls /sbin/wget) 2>/dev/null
	busyboxManualAwk=$(ls /system/bin/awk || ls /system/sbin/awk || ls /system/xbin/awk || ls /sbin/awk) 2>/dev/null
	busyboxManualSort=$(ls /system/bin/sort || ls /system/sbin/sort || ls /system/xbin/sort || ls /sbin/sort) 2>/dev/null
	busyboxManualTruncate=$(ls /system/bin/truncate || ls /system/sbin/truncate || ls /system/xbin/truncate || ls /sbin/truncate) 2>/dev/null
	if [ -n "$busybox" ]; then
	   busyboxName=$("$busybox" | head -1 | cut -f 2 -d ' ')
	   return 1
    elif [ -n "$busyboxAuto" ]; then
       busyboxName=$(echo $("$busyboxAuto" | head -1 | cut -f 2 -d ' '))
       return 1
    elif [ -n "$busyboxManualGzip" ] && [ -n "$busyboxManualWget" ] && [ -n "$busyboxManualAwk" ] && [ -n "$busyboxManualSort" ] && [ -n "$busyboxManualTruncate" ]; then
       busyboxName=$(echo 'Busybox Applets')
       return 2
    elif [ -z "$busybox" ] || [ -z "$busyboxAuto" ] || [ -z "$busyboxManualGzip" ] || [ -z "$busyboxManualWget" ] || [ -z "$busyboxManualAwk" ] || [ -z "$busyboxManualSort" ] || [ -z "$busyboxManualTruncate" ]; then
	   busyboxName=$(echo $R'Not Found!'$N)
       return 0
    fi
}
# ----------------------------------------

# ----------------------------------------
# Check systemless hosts
# ----------------------------------------
checkSystemlessHosts() {
	if [ ! -f $hosts ]; then
	   checkSystemlessHostsPrint=$R" × "$N$W"Systemless Hosts is disabled."$N$R"\n   - Enable in 'Magisk Manager>Settings'.\n   - Reboot and re-run the script.\n   - Quitting Script..."$N
	   sleep 3
	   exit 0
    else
       checkSystemlessHostsPrint=$G" ✓ "$N$W"Systemless Hosts is enabled."$N
    fi
}
# ----------------------------------------

# ----------------------------------------
# Check shell format
# ----------------------------------------
checkShell() {
	currentShell=$(ps $$ | tail -1 | awk '{print $NF}')
	if [ $(echo "$currentShell" | grep 'NAME') ]; then
	   currentShell=$(ps $$ | tail -1 | awk '{print $NF}' | sed 's/NAME //' | sed ':a;N;$!ba;s/\n//' | sed 's/NAME//') 2>/dev/null;
	fi
	
	case $currentShell in
	/system/bin/bash|bash)
	    currentShell=$(echo "$currentShell" | sed 's/\/system\/bin\///' | sed 's/\/system\/sbin\///' | sed 's/\/bin\///' | sed 's/\/system\/xbin\///') 2>/dev/null;
	    shellType=$(echo -e $R" × "$N$W"Not compatible with $currentShell mode."$N$R"\n   - Only compatible with sh."$N)
	    # Not in bash
	    return 0
	;;
	/system/bin/ksh|ksh)
		currentShell=$(echo "$currentShell" | sed 's/\/system\/bin\///' | sed 's/\/system\/sbin\///' | sed 's/\/bin\///' | sed 's/\/system\/xbin\///') 2>/dev/null;
		shellType=$(echo -e $R" × "$N$W"Not compatible with $currentShell mode."$N$R"\n   - Only compatible with sh."$N)
		# Not in ksh
		return 0
	;;
	/system/bin/csh|csh)
		currentShell=$(echo "$currentShell" | sed 's/\/system\/bin\///' | sed 's/\/system\/sbin\///' | sed 's/\/bin\///' | sed 's/\/system\/xbin\///') 2>/dev/null;
		shellType=$(echo -e $R" × "$N$W"Not compatible with $currentShell mode."$N$R"\n   - Only compatible with sh."$N)
		# Not in csh
		return 0
	;;
	/system/bin/zsh|zsh)
		currentShell=$(echo "$currentShell" | sed 's/\/system\/bin\///' | sed 's/\/system\/sbin\///' | sed 's/\/bin\///' | sed 's/\/system\/xbin\///') 2>/dev/null;
		shellType=$(echo -e $R" × "$N$W"Not compatible with $currentShell mode."$N$R"\n   - Only compatible with sh."$N)
		# Not in zsh
		return 0
	;;
	/system/bin/ash|ash)
		currentShell=$(echo "$currentShell" | sed 's/\/system\/bin\///' | sed 's/\/system\/sbin\///' | sed 's/\/bin\///' | sed 's/\/system\/xbin\///') 2>/dev/null;
		shellType=$(echo -e $R" × "$N$W"Not compatible with $currentShell mode."$N$R"\n   - Only compatible with sh."$N)
		# Not in ash
		return 0
	;;
	/system/bin/sh|sh)
		currentShell=$(echo "$currentShell" | sed 's/\/system\/bin\///' | sed 's/\/system\/sbin\///' | sed 's/\/bin\///' | sed 's/\/system\/xbin\///') 2>/dev/null;
		shellType=$(echo -e $G" ✓ "$N$W"Script running in $currentShell mode. Great!"$N)
		#Success
		return 1
	;;
	*)
		currentShell=$(echo "$currentShell" | sed 's/\/system\/bin\///' | sed 's/\/system\/sbin\///' | sed 's/\/bin\///' | sed 's/\/system\/xbin\///') 2>/dev/null;
		shellType=$(echo -e $R" × "$N$W"Not compatible with $currentShell mode."$N$R"\n   - Only compatible with sh."$N)
		# not in zsh or another..
		return 0
	;;
    esac
}    
# ----------------------------------------

checkMagisk;
checkBusybox;
checkSystemlessHosts;
checkShell;