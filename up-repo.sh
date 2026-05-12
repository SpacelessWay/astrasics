#!/bin/bash
# Полное обновление репозитория Astrasics


# 1. Обновить метаданные пакетов
echo "=== 1. Обновление Packages.gz и Packages ==="
dpkg-scanpackages pool /dev/null | gzip -9c > dists/v1.1/main/binary-amd64/Packages.gz
zcat dists/v1.1/main/binary-amd64/Packages.gz > dists/v1.1/main/binary-amd64/Packages

# 2. Обновить Release файл
echo "=== 2. Обновление Release ==="
rm -f dists/v1.1/Release
apt-ftparchive release dists/v1.1/ > dists/v1.1/Release
cat dists/v1.1/Release | grep Date

# 3. Удалить старые GPG подписи
echo "=== 3. Удаление старых подписей ==="
rm -f dists/v1.1/Release.gpg
rm -f dists/v1.1/InRelease

# 4. Создать новые GPG подписи (если есть ключ)
# Если GPG-ключа нет — пропустить шаги 4-5, использовать trusted=yes
echo "=== 4. Создание GPG подписей ==="
gpg --clearsign -o dists/v1.1/InRelease dists/v1.1/Release
gpg -abs -o dists/v1.1/Release.gpg dists/v1.1/Release

# 5. Сгенерировать index.html для веб-интерфейса
echo "=== 5. Генерация index.html ==="
./generate-indexes.sh

# 6. Отправить изменения на GitHub
echo "=== 6. Push на GitHub ==="
git add .
git commit -m "Обновление репозитория: добавлены новые пакеты"
git push origin main

echo "=== Готово! ==="
