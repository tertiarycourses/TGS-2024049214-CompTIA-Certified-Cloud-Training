#!/bin/bash
NAME=$1
echo "=== State ==="; docker inspect $NAME --format='{{.State.Status}} OOM={{.State.OOMKilled}} Exit={{.State.ExitCode}}'
echo "=== Logs (last 30) ==="; docker logs --tail 30 $NAME 2>&1
echo "=== Stats ==="; docker stats --no-stream $NAME 2>/dev/null
echo "=== Mounts ==="; docker inspect $NAME --format='{{range .Mounts}}{{.Source}} -> {{.Destination}} ({{.Mode}}){{println}}{{end}}'
echo "=== Network ==="; docker inspect $NAME --format='{{range $k,$v := .NetworkSettings.Networks}}{{$k}}={{$v.IPAddress}}{{end}}'
