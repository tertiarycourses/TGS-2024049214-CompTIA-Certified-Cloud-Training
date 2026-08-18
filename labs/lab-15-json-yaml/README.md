# Lab 15 — JSON & YAML Scripting Logic

In this lab you will read and write JSON and YAML, parse with `jq` and `yq`, and exercise the scripting-logic primitives the exam lists: variables, conditionals, operators, data types, functions.

Run all commands on the Killercoda Ubuntu Playground:
https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Install parsers

```bash
apt update && apt install -y jq python3-pip
pip3 install yq
```

---

## Step 2 — Write JSON

```bash
mkdir -p /tmp/data && cd /tmp/data
cat > server.json <<'EOF'
{
  "name": "web-1",
  "cpu": 2,
  "ram_gb": 4,
  "tags": ["web", "prod"],
  "active": true
}
EOF

jq . server.json
jq '.name, .cpu' server.json
jq '.tags | length' server.json
```

Data types in play: string, number, boolean, array, object.

---

## Step 3 — Same data in YAML

```bash
cat > server.yaml <<'EOF'
name: web-1
cpu: 2
ram_gb: 4
tags:
  - web
  - prod
active: true
EOF

yq . server.yaml
yq -y '.tags' server.yaml
```

---

## Step 4 — Convert between formats

```bash
yq . server.yaml > /tmp/data/server-from-yaml.json
diff <(jq -S . server.json) <(jq -S . server-from-yaml.json) && echo "Same data, two formats"
```

---

## Step 5 — Variables, conditionals, operators

`jq` is itself a tiny scripting language — perfect to exercise the exam primitives.

```bash
# Variables
jq --arg env prod '. + {env:$env}' server.json

# Conditionals
jq 'if .ram_gb < 8 then "undersized" else "ok" end' server.json

# Operators
jq '.cpu * 2' server.json

# Functions
jq 'def double(x): x*2; double(.cpu)' server.json
```

---

## Step 6 — Validate at the boundary

Try a broken file:

```bash
echo '{ "broken": ' > bad.json
jq . bad.json || echo "Schema violation caught"
```

In production, fail builds early on invalid JSON/YAML — same idea as Terraform `validate` or `kubectl --dry-run`.

---

## Step 7 — Web validators (offline-friendly bookmarks)

- JSONLint — https://jsonlint.com
- YAML Lint — https://www.yamllint.com
- JSON Schema validator — https://www.jsonschemavalidator.net

These are useful when the exam shows you a malformed snippet.

---

## Step 8 — Cleanup

```bash
rm -rf /tmp/data
```

---

## What you learned
- Read, write, validate, and convert JSON ↔ YAML.
- Scripting logic primitives at the data-format level.
- When to choose JSON (machine-friendly) vs YAML (human-friendly).

## Free tools used
- jq — https://jqlang.github.io/jq
- yq — https://kislyuk.github.io/yq
- JSONLint — https://jsonlint.com
- YAML Lint — https://www.yamllint.com
