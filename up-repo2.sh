#!/bin/bash
# ============================================================
# Полное обновление репозитория Astrasics с поддержкой Git LFS
# ============================================================

set -e  # Остановка при любой ошибке

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Обновление репозитория Astrasics${NC}"
echo -e "${GREEN}========================================${NC}"

# 1. Проверка и установка Git LFS (ВАЖНО!)
echo -e "${YELLOW}[1/8] Проверка Git LFS...${NC}"
if ! command -v git-lfs &> /dev/null; then
    echo "  Установка Git LFS..."
    sudo apt update
    sudo apt install git-lfs -y
fi
git lfs install

# 2. Настройка Git LFS для отслеживания .deb файлов
echo -e "${YELLOW}[2/8] Настройка Git LFS...${NC}"
git lfs track "*.deb"
git lfs track "*.iso"
git lfs track "*.img"
git lfs track "*.bin"
git add .gitattributes 2>/dev/null || true
git commit -m "Update Git LFS tracking" 2>/dev/null || true

# 3. Обновить метаданные пакетов
echo -e "${YELLOW}[3/8] Обновление метаданных пакетов...${NC}"
if [ -d "pool" ]; then
    dpkg-scanpackages pool /dev/null | gzip -9c > dists/v1.1/main/binary-amd64/Packages.gz
    zcat dists/v1.1/main/binary-amd64/Packages.gz > dists/v1.1/main/binary-amd64/Packages
    echo "  Packages.gz и Packages обновлены"
else
    echo -e "${RED}  Ошибка: директория pool не найдена${NC}"
    exit 1
fi

# 4. Обновить Release файл
echo -e "${YELLOW}[4/8] Обновление Release...${NC}"
rm -f dists/v1.1/Release
apt-ftparchive release dists/v1.1/ > dists/v1.1/Release
echo "  Release обновлён"

# 5. GPG подписи
echo -e "${YELLOW}[5/8] GPG подписи...${NC}"
if command -v gpg &> /dev/null && gpg --list-keys 2>/dev/null | grep -q "Astrasics"; then
    rm -f dists/v1.1/Release.gpg dists/v1.1/InRelease
    gpg --clearsign -o dists/v1.1/InRelease dists/v1.1/Release
    gpg -abs -o dists/v1.1/Release.gpg dists/v1.1/Release
    echo "  GPG подписи созданы"
else
    echo -e "${YELLOW}  Предупреждение: GPG ключ не найден, подписи не созданы${NC}"
    echo "  Добавьте в sources.list: [trusted=yes]"
fi

# 6. Генерация index.html
echo -e "${YELLOW}[6/8] Генерация index.html...${NC}"
if [ -f "./generate-indexes.sh" ]; then
    ./generate-indexes.sh
else
    echo "  generate-indexes.sh не найден, пропускаем"
fi

# 7. Проверка, что большие файлы действительно в LFS
echo -e "${YELLOW}[7/8] Проверка файлов в LFS...${NC}"
find pool -name "*.deb" -size +50M -exec echo "  LFS: {}" \;

# 8. Отправка на GitHub
echo -e "${YELLOW}[8/8] Push на GitHub...${NC}"
git add .
git commit -m "Обновление репозитория: $(date +'%Y-%m-%d %H:%M:%S')" || echo "  Нет изменений для коммита"

# Push с использованием LFS
echo "  Отправка на GitHub..."
git push origin main

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Репозиторий успешно обновлён!${NC}"
echo -e "${GREEN}========================================${NC}"
