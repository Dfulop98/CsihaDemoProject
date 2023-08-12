#!/bin/bash

# Konfigurációs és titkosítási kulcsfájlok másolása
cp /var/opt/gitlab/backups/gitlab.rb /etc/gitlab/
cp /var/opt/gitlab/backups/gitlab-secrets.json /etc/gitlab/ 
# Konfiguráció alkalmazása
gitlab-ctl reconfigure

# Backup visszaállítása
gitlab-backup restore BACKUP=1691831784_2023_08_12_16.2.3_gitlab_backup.tar

# Mivel változtattuk a konfigurációt és visszaállítottuk a backupot, érdemes lehet újra alkalmazni a konfigurációt
gitlab-ctl reconfigure

# Egyéb parancsok, ha szükségesek...
