#!/bin/bash -e

jenkins_home=/var/lib/jenkins
jenkins_backup_archive=/tmp/$(date +%Y-%m-%d-%H-%M)-jenkins-backup.tgz
s3_bucket=s3://s3-bucket-for-jenkins-backups

#how many days to keep backup
#remove backups older than 14 days
retention_policy=14
remove_backups_older_than=$(date -d "$retention_policy days ago" +%Y-%m-%d-%H-%M)

tar --exclude='/var/lib/jenkins/workspace' \
    --exclude='/var/lib/jenkins/.gradle' \
    --exclude='/var/lib/jenkins/caches' \
    -czvf $jenkins_backup_archive $jenkins_home

echo "Copy $jenkins_backup_archive to $s3_bucket."
aws s3 cp $jenkins_backup_archive $s3_bucket

aws s3 ls $s3_bucket| awk '{print $4}' | sort -n > ./jenkins_backups

#retention policy
while read backup ; do
  #get timestamp and remove triling slash
  time_stamp=$(echo $backup| awk -F '[a-z]' '{print $1}'| sed 's:-$::')
  if [[ $remove_backups_older_than > $time_stamp ]]; then
    echo "Backup $backup will be deleted. It's older than $retention_policy days"
    aws s3 rm $s3_bucket/$backup
  fi
done < ./jenkins_backups

#cleanup
echo "Remove $jenkins_backup_archive."
rm -f $jenkins_backup_archive ./jenkins_backups
