import sys, json
event = json.loads(sys.stdin.read())
print(json.dumps({"hello": event.get("name", "cloud")}))
