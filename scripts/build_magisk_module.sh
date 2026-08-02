#!/bin/bash
# 生成 Magisk 模块骨架并打包 zip
# 用法: build_magisk_module.sh <module-id> [模块名] [作者] [输出目录]
set -u

ID="${1:-}"
[ -n "$ID" ] || { echo "用法: $0 <module-id> [模块名] [作者] [输出目录]"; exit 1; }
NAME="${2:-$ID}"
AUTHOR="${3:-user}"
OUT="${4:-./build}"
TEMPLATE="$(cd "$(dirname "$0")/.." && pwd)/assets/module-template"

[ -d "$TEMPLATE" ] || { echo "错误: 模板目录不存在: $TEMPLATE" >&2; exit 1; }

DIR="$OUT/$ID"
mkdir -p "$DIR/META-INF/com/google/android"
cp -R "$TEMPLATE/." "$DIR/"

if [ "$(uname -s)" = "Darwin" ]; then
  sed -i '' "s/^id=.*/id=$ID/; s/^name=.*/name=$NAME/; s/^author=.*/author=$AUTHOR/" "$DIR/module.prop"
else
  sed -i "s/^id=.*/id=$ID/; s/^name=.*/name=$NAME/; s/^author=.*/author=$AUTHOR/" "$DIR/module.prop"
fi

if command -v zip >/dev/null 2>&1; then
  (cd "$DIR" && zip -qr "../${ID}.zip" .)
else
  python3 -c "import shutil,sys; shutil.make_archive(sys.argv[1], 'zip', sys.argv[2])" "$OUT/$ID" "$DIR"
fi

echo "模块目录: $DIR"
echo "模块包: $OUT/$ID.zip"
