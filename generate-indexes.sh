#!/bin/bash

echo "Генерация index.html — светлая тема, без точек, с зелёно-фиолетовым стилем..."

# Светлый стиль с акцентами: зелёный (#4CAF50) и фиолетовый (#673AB7)
CSS_STYLE="
body {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background: #ffffff;
  color: #333333;
  margin: 30px;
  line-height: 1.8;
}
h1 {
  color: #673AB7; /* Фиолетовый заголовок */
  font-size: 1.6em;
  border-bottom: 2px solid #E0E0E0;
  padding-bottom: 8px;
  margin-bottom: 20px;
  font-weight: normal;
}
ul {
  list-style-type: none;        /* Убираем все маркеры */
  padding: 0;
}
li {
  margin: 0;
}
a {
  color: #4CAF50;               /* Зелёные ссылки */
  text-decoration: none;
  font-size: 1.1em;
  font-family: 'Consolas', monospace;
}
a:hover {
  color: #673AB7;               /* При наведении — фиолетовый */
  text-decoration: underline;
  transition: color 0.2s;
}
a:visited {
  color: #8E24AA;               /* Посещённые — глубже фиолетовый */
}
footer {
  margin-top: 30px;
  font-size: 0.9em;
  color: #777;
  text-align: center;
}
footer a {
  color: #673AB7;
  text-decoration: none;
}
footer a:hover {
  text-decoration: underline;
}
"

# Функция для создания index.html
create_index() {
  local dir="$1"
  local path_in_repo="${dir#./}"

  cat > "$dir/index.html" << EOF
<!DOCTYPE html>
<html lang="ru">
<head>
  <meta charset="UTF-8" />
  <title>/$path_in_repo</title>
  <style>$CSS_STYLE</style>
</head>
<body>
  <h1>/$path_in_repo</h1>
  <ul>
EOF

  # Читаем содержимое папки, фильтруем . .. и index.html
  ls -la "$dir" | tail -n +4 | while read perms links owner group size date time name; do
    [[ "$name" == "index.html" ]] && continue

    if [ -d "$dir/$name" ]; then
      icon="📁"
      link="$name/"
    else
      icon="📄"
      link="$name"
    fi

    echo "    <li>$icon <a href=\"$link\">$name</a></li>" >> "$dir/index.html"
  done

  # Подвал
  cat >> "$dir/index.html" << EOF
  </ul>
  <footer>
    APT repository for Astrasics• 
    <a href="https://github.com/SpacelessWay/astrasics">View source on GitHub</a>
  </footer>
</body>
</html>
EOF
}

# Генерируем для всех подпапок dists/ и pool/
for d in dists pool; do
  [ ! -d "$d" ] && continue
  find "$d" -type d | while read dir; do
    create_index "$dir"
  done
done

echo "✅ Готово! Светлая тема с зелёными и фиолетовыми акцентами — без маркеров списка."
