#!/bin/bash

echo "Генерация index.html для всех папок..."

# Функция для создания index.html
create_index() {
  local dir="$1"
  cat > "$dir/index.html" << EOF
<!DOCTYPE html>
<html>
<head><title>$dir</title></head>
<body>
<h1>$dir/</h1>
<ul>
EOF

  # Добавляем ссылки на подпапки и файлы
  ls -la "$dir" | tail -n +4 | while read line; do
    name=$(echo "$line" | awk '{print $9}')
    [ -z "$name" ] && continue
    echo "<li><a href='$name'>$name</a></li>" >> "$dir/index.html"
  done

  cat >> "$dir/index.html" << EOF
</ul>
</body>
</html>
EOF
}

# Генерируем для dists/, pool/ и всех подпапок
for d in dists pool; do
  [ ! -d "$d" ] && continue
  find "$d" -type d | while read dir; do
    create_index "$dir"
  done
done

echo "✅ Готово! Теперь можно коммитить."
