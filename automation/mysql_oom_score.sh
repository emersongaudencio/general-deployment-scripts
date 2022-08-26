# set oom score for mysql in linux systems
echo '#!/bin/bash
#### set oom score for mysql in linux systems ####
MYSQL_PID=$(pgrep mysqld | awk "NR==1{print $1}")
if test -f /proc/${MYSQL_PID}/oom_score_adj; then
  CURRENT_SCORE=$(cat /proc/${MYSQL_PID}/oom_score_adj)
  if [ "$CURRENT_SCORE" == "0" ]; then
    echo -800 > /proc/${MYSQL_PID}/oom_score_adj
    echo "MySQL OOM Score was set to -800"
  else
    echo "MySQL OOM Score is already in place!"
  fi
fi' > /root/mysql_oom_score.sh
# set cron job to update the mysql oom score every 5 minutes
(crontab -l; echo "*/5 * * * * root bash /root/mysql_oom_score.sh >/dev/null 2>&1")|awk '!x[$0]++'|crontab -
