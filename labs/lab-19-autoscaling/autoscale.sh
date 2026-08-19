#!/bin/bash
cd /tmp/scale
MIN=2; MAX=6
while true; do
  CPU=$(awk -v cores=$(nproc) '/cpu / {usage=($2+$4)*100/($2+$4+$5)} END{print usage}' /proc/stat)
  CUR=$(docker compose ps -q app | wc -l)
  TARGET=$CUR
  awk -v c="$CPU" 'BEGIN{exit !(c+0 > 70)}' && [ $CUR -lt $MAX ] && TARGET=$((CUR+1))
  awk -v c="$CPU" 'BEGIN{exit !(c+0 < 20)}' && [ $CUR -gt $MIN ] && TARGET=$((CUR-1))
  if [ "$TARGET" != "$CUR" ]; then
    echo "$(date +%T) CPU=${CPU}%  scaling $CUR -> $TARGET"
    docker compose up -d --scale app=$TARGET --no-recreate
  fi
  sleep 5
done
