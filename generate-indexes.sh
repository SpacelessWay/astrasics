#!/bin/bash

echo "Генерация index.html в стиле http.kali.org — дата из Git, без index.html и ls-lR.gz"

CSS_STYLE="
body {
  background: #ffffff;
  color: #000;
  font-family: Arial, sans-serif;
  margin: 20px;
  line-height: 1.6;
}
h1 {
  margin: 0;
  font-size: 1.8em;
  color: #000;
}
table {
  width: 100%;
  border-collapse: collapse;
  margin: 20px 0;
}
th {
  background: #f5f5f5;
  padding: 8px 12px;
  text-align: left;
  font-weight: bold;
  color: #000;
  border-bottom: 1px solid #ddd;
}
td {
  padding: 8px 12px;
  border-bottom: 1px solid #eee;
}
tr:nth-child(even) {
  background: #f9f9f9;
}
a {
  color: #007a3d;
  text-decoration: underline;
}
a:hover {
  color: #2d9f00;
}
.footer {
  font-size: 0.9em;
  color: #666;
  margin-top: 15px;
}
"

# Получить дату последнего коммита для пути
get_git_date() {
  local path="$1"
  git log -1 --format="%at" -- "$path" 2>/dev/null || echo $(date +%s)
}

# Формат: Aug-24 12:00
format_datetime() {
  date -d "@$1" "+%Y-%b-%d %H:%M" | awk '{split($1,d,"-"); printf "%s-%s %s", d[2], substr(d[1],3,2), $2}'
}

# Формат: только дата, без времени → 2025-Jun-24
format_date_only() {
  date -d "@$1" "+%Y-%b-%d" | awk '{split($1,d,"-"); printf "%s-%s", d[2], substr(d[1],3,2)}'
}

# Создать index.html для папки
create_index() {
  local dir="$1"
  local path="${dir#./}"

  (
    echo "<!DOCTYPE html>"
    echo "<html lang=\"ru\">"
    echo "<head>"
    echo "  <meta charset=\"UTF-8\" />"
    echo "  <title>Index of /$path/</title>"
    echo "  <style>$CSS_STYLE</style>"
    echo "</head>"
    echo "<body>"
    echo "  <h1>Index of /$path/</h1>"
    echo "  <table>"
    echo "    <thead>"
    echo "      <tr>"
    echo "        <th>File Name ↓</th>"
    echo "        <th>File Size ↓</th>"
    echo "        <th>Date ↓</th>"
    echo "      </tr>"
    echo "    </thead>"
    echo "    <tbody>"

    ls -la "$dir" | tail -n +4 | sort -k9 | while read perms links owner group size month day time_or_year name; do
      [[ "$name" == "index.html" ]] && continue
      [[ "$name" == "ls-lR.gz" ]] && continue

      full_path="$dir/$name"
      git_timestamp=$(get_git_date "$full_path")

      if [ -d "$full_path" ]; then
        link_name="$name/"
        disp_size="-"
        disp_date=$(format_date_only "$git_timestamp")
      else
        link_name="$name"
        # Форматируем размер
        if [ "$size" -lt 1024 ]; then
          disp_size="${size} B"
        elif [ "$size" -lt 1048576 ]; then
          disp_size="$(($size / 1024)) KiB"
        else
          disp_size="$(printf "%.1f" $(echo "$size / 1048576" | bc -l)) MiB"
        fi
        disp_date=$(format_datetime "$git_timestamp")
      fi

      echo "      <tr>"
      echo "        <td><a href=\"$link_name\">$link_name</a></td>"
      echo "        <td>$disp_size</td>"
      echo "        <td>$disp_date</td>"
      echo "      </tr>"
    done

    echo "    </tbody>"
    echo "  </table>"
    echo "  <div class=\"footer\">This is Astrasics main package repository.</div>"
    echo "</body>"
    echo "</html>"
  ) > "$dir/index.html"
}

# Генерируем для dists/ и pool/
for d in dists pool; do
  [ ! -d "$d" ] && continue
  find "$d" -type d | while read dir; do
    create_index "$dir"
  done
done

echo "✅ Готово! Все index.html теперь в точном стиле http.kali.org"
