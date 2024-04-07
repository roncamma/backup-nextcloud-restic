#!/bin/bash
export RESTIC_REPOSITORY="rclone:storj:nextcloud-restic" # Using rclone backend for Storj storage (rclone:<remote>:<bucket>)
export RESTIC_PASSWORD="<password>"
export RESTIC_PACK_SIZE="60" # recomanded size for Storj storage
# Mode maintenance Nextcloud ON
nextcloud.occ maintenance:mode --on
# backup data folder
restic backup /mnt/data/ -v --tag data
# conf and db export using occ tool
nextcloud.export -abc
# Mode maintenance Nextcloud OFF
nextcloud.occ maintenance:mode --off
# create tar archive of the export
cd /var/snap/nextcloud/common/backups/
current_export=$(ls -rt1 | tail -n1)
tar -czf ${current_export}.tar.gz ${current_export}
rm -rf ${current_export}
# clean +30d archives
find /var/snap/nextcloud/common/backups/ -maxdepth 1 -mindepth 1 -mtime +30 -exec rm -rf {} \;
# bckup archive
restic backup /var/snap/nextcloud/common/backups/ -v --tag db

### crontab exemple
# 0 4 * * * bash backup_restic.sh 2>&1 >> /var/log/restic.log
