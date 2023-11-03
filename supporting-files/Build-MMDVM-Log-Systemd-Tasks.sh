#!/bin/bash
# Add MMDVM log backup/restore services/timers to SYSTEMD
#

cd /lib/systemd/system
# ---------------------------------------------------------------------------------------------
echo '[Unit]'                                                   >  mmdvm-log-backup.service
echo 'Description=Backup MMDVM log files'                       >> mmdvm-log-backup.service
echo ' '                                                        >> mmdvm-log-backup.service
echo '[Service]'                                                >> mmdvm-log-backup.service
echo 'Type=simple'                                              >> mmdvm-log-backup.service
echo 'ExecStart=/usr/local/sbin/pistar-mmdvm-log-backups'       >> mmdvm-log-backup.service
echo ' '                                                        >> mmdvm-log-backup.service
echo '[Install]'                                                >> mmdvm-log-backup.service
echo 'WantedBy=multi-user.target'                               >> mmdvm-log-backup.service
echo ' '                                                        >> mmdvm-log-backup.service
# ---------------------------------------------------------------------------------------------
echo '[Unit]'                                                   >  mmdvm-log-backup.timer
echo 'Description=Backup MMDVM log files every 10 mins'         >> mmdvm-log-backup.timer
echo ' '                                                        >> mmdvm-log-backup.timer
echo '[Timer]'                                                  >> mmdvm-log-backup.timer
echo 'OnCalendar=*-*-* *:00/10'                                 >> mmdvm-log-backup.timer
echo 'Persistent=true'                                          >> mmdvm-log-backup.timer
echo ' '                                                        >> mmdvm-log-backup.timer
echo '[Install]'                                                >> mmdvm-log-backup.timer
echo 'WantedBy=timers.target'                                   >> mmdvm-log-backup.timer
echo ' '                                                        >> mmdvm-log-backup.timer
# ---------------------------------------------------------------------------------------------
echo '[Unit]'                                                   >  mmdvm-log-restore.service
echo 'Description=Restore MMDVM log files at startup'           >> mmdvm-log-restore.service
echo 'After=default.target'                                     >> mmdvm-log-restore.service
echo 'Before=mmdvmhost.service'                                 >> mmdvm-log-restore.service
echo ' '                                                        >> mmdvm-log-restore.service
echo '[Service]'                                                >> mmdvm-log-restore.service
echo 'Type=simple'                                              >> mmdvm-log-restore.service
echo 'ExecStart=/usr/local/sbin/pistar-mmdvm-log-restores -r'   >> mmdvm-log-restore.service
echo 'TimeoutStartSec=0'                                        >> mmdvm-log-restore.service
echo ' '                                                        >> mmdvm-log-restore.service
echo '[Install]'                                                >> mmdvm-log-restore.service
echo 'WantedBy=default.target'                                  >> mmdvm-log-restore.service
echo ' '                                                        >> mmdvm-log-restore.service
# ---------------------------------------------------------------------------------------------
echo '[Unit]'                                                   >  mmdvm-log-shutdown.service
echo 'Description=Backup MMDVM log files at Shutdown/Reboot'    >> mmdvm-log-shutdown.service
echo 'DefaultDependencies=no'                                   >> mmdvm-log-shutdown.service
echo 'Before=shutdown.target'                                   >> mmdvm-log-shutdown.service
echo ' '                                                        >> mmdvm-log-shutdown.service
echo '[Service]'                                                >> mmdvm-log-shutdown.service
echo 'Type=simple'                                              >> mmdvm-log-shutdown.service
echo 'ExecStart=/usr/local/sbin/pistar-mmdvm-log-backups -r'    >> mmdvm-log-shutdown.service
echo 'TimeoutStartSec=3'                                        >> mmdvm-log-shutdown.service
echo ' '                                                        >> mmdvm-log-shutdown.service
echo '[Install]'                                                >> mmdvm-log-shutdown.service
echo 'WantedBy=shutdown.target'                                 >> mmdvm-log-shutdown.service
echo ' '                                                        >> mmdvm-log-shutdown.service
# ---------------------------------------------------------------------------------------------
sudo chown root:root mmdvm-log-backup.service
sudo chown root:root mmdvm-log-backup.timer
sudo chown root:root mmdvm-log-restore.service
sudo chown root:root mmdvm-log-shutdown.service

sudo systemctl enable mmdvm-log-backup.service
sudo systemctl enable mmdvm-log-backup.timer
sudo systemctl enable mmdvm-log-restore.service
sudo systemctl enable mmdvm-log-shutdown.service

sudo systemctl start  mmdvm-log-backup.timer

sudo systemctl daemon-reload

