#!/bin/bash
cwd=$PWD
if [ -z "$1" ];
then
echo "Usage: $0 <falcon|bullhead|sprout>"
exit 1;
fi
export device=$1
export files=${THUGDIR}/misc/$device.files
curl https://sourceforge.net/projects/thuglife/files/$device/ | grep "https://sourceforge.net/projects/thuglife/files/$device/thuglife-$device-" | awk '{print $2}' | cut -d'"' -f2 | cut -d'/' -f8 > $files
cd ${THUGDIR}/$device
export changelog=${THUGDIR}/misc/$device.changelog
echo "Changelog for past 60 days:" > $changelog
for i in $(seq 60); do
    export After_Date=$(date --date="$i days ago" +%m-%d-%Y);
    export Until_Date=$(date --date="$(expr $i - 1) days ago" +%m-%d-%Y);

    # Line with after --- until was too long for a small ListView
    echo ${ylw}"  Processing $Until_Date..."${txtrst};
    echo ' ======================' >> "$changelog";
    echo '  ChangeLog '$Until_Date >> "$changelog";
    echo ' ======================' >> "$changelog";

    # Handle the usage of repochangelog days_count project1_path,project2_path,...
          echo "" >> "$changelog";
          git log --oneline --pretty="tformat:    %h - %s <%an>" --after=${After_Date} --until=${Until_Date} >> "$changelog";

done
cd ${THUGDIR}/misc
echo "Update changelog and file for $device" > /tmp/thug
git add -A
git commit -a -s -S -F /tmp/thug
git push origin master
cd $cwd
rm /tmp/thug
