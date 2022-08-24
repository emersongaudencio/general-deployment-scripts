#!/bin/bash
#### set oom score for mysql in linux systems ####
echo "HOSTNAME: " `hostname`
echo "[`date +%d/%m/%Y" "%H:%M:%S`]"
echo "##############"
MYSQL_PID=$(pgrep mysqld | awk 'NR==1{print $1}')
if test -f /proc/${MYSQL_PID}/oom_score_adj; then
  CURRENT_SCORE=$(cat /proc/${MYSQL_PID}/oom_score_adj)
  if [ "$CURRENT_SCORE" == "0" ]; then
    echo -800 > /proc/${MYSQL_PID}/oom_score_adj
    echo "MySQL OOM Score was set to -800"
  else
    echo "MySQL OOM Score is already in place!"
  fi
fi
echo "##############"
