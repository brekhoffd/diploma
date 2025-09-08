#!/usr/bin/env bash
set -euo pipefail

# Обробка помилок
trap 'echo "Сталася помилка на рядку $LINENO"; exit 1' ERR

# Перевірка прав на виконання
if [ "$(id -u)" -ne 0 ]; then
  echo
  echo "ВІДМОВА! Недостатньо прав!"
  echo
  exit 1
fi

# Динамічне визначення IP-адреси (використовуємо першу не-loopback IP)
LOCAL_IP=$(hostname -I | awk '{print $1}')
if [ -z "$LOCAL_IP" ]; then
    echo "Помилка: Не вдалося визначити локальну IP-адресу."
    exit 1
fi
LOCAL_PORT="8080"

# Налаштування користувача Jenkins
JENKINS_URL="http://$LOCAL_IP:$LOCAL_PORT"
ADMIN_FULLNAME="Denys Brekhov"
ADMIN_USERNAME="denys"
ADMIN_PASSWORD="diploma"
ADMIN_EMAIL="denys.brekhov@example.com"

# Функція для перевірки команди
check_status() {
    if [ $? -ne 0 ]; then
        echo "Помилка: $1"
        exit 1
    fi
}

# Вивід початкового повідомлення
echo
echo "Встановлення Jenkins та Docker!"

# Встановлення Java та Jenkins
echo
echo "Встановлення Java..."
sudo apt -y update
sudo apt install -y openjdk-21-jre openjdk-21-jdk
check_status "Встановлення Java"

echo
echo "Встановлення Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt -y update
sudo apt install -y jenkins
check_status "Встановлення Jenkins"

echo
echo "Запуск Jenkins..."
sudo systemctl start jenkins
sudo systemctl enable jenkins
check_status "Запуск Jenkins"

# Таймаут для запуску усіх служб та сервісів
echo
echo "Запуск служб та сервісів..."
sleep 10

# Встановлення Docker
echo
echo "Встановлення Docker..."
sudo apt -y update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt -y update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
check_status "Встановлення Docker"

# Запуск Docker
echo
echo "Запуск Docker..."
sudo systemctl enable docker
sudo systemctl start docker
check_status "Запуск Docker"

# Додавання Jenkins до груп
echo
echo "Додавання Jenkins до груп..."
sudo usermod -aG docker jenkins
sudo usermod -aG adm jenkins
check_status "Додавання Jenkins до груп"

# Створення папки MSSQL без помилки, якщо така папка вже існує
echo
echo "Створення папки /opt/mssql..."
sudo mkdir /opt/mssql 2>/dev/null || true
sudo chmod 777 /opt/mssql

# Перезапуск Jenkins після налаштувань
echo
echo "Перезапуск Jenkins після налаштувань..."
sudo systemctl restart jenkins
check_status "Перезапуск Jenkins після налаштувань"

# Таймаут для запуску усіх служб та сервісів
echo
echo "Запуск служб та сервісів..."
sleep 10

# Розблокування Jenkins
echo
echo "Розблокування Jenkins..."
INITIAL_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
echo "Initial admin password: $INITIAL_PASSWORD"
COOKIE_JAR=$(mktemp)
FULL_CRUMB=$(curl -u "admin:$INITIAL_PASSWORD" --cookie-jar "$COOKIE_JAR" $JENKINS_URL/crumbIssuer/api/xml?xpath=concat\(//crumbRequestField,%22:%22,//crumb\))
ARR_CRUMB=(${FULL_CRUMB//:/ })
ONLY_CRUMB=${ARR_CRUMB[1]}

# Створення користувача
echo
echo "Створення користувача..."
curl -X POST -u "admin:$INITIAL_PASSWORD" $JENKINS_URL/setupWizard/createAdminUser \
    -H "Connection: keep-alive" \
    -H "Accept: application/json, text/javascript" \
    -H "X-Requested-With: XMLHttpRequest" \
    -H "$FULL_CRUMB" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    --cookie $COOKIE_JAR \
    --data-raw "username=$ADMIN_USERNAME&password1=$ADMIN_PASSWORD&password2=$ADMIN_PASSWORD&fullname=$ADMIN_FULLNAME&email=$ADMIN_EMAIL&Jenkins-Crumb=$ONLY_CRUMB"
check_status "Створення користувача"

# Перезапуск Jenkins після розблокування
echo
echo
echo "Перезапуск Jenkins після розблокування..."
sudo systemctl restart jenkins
check_status "Перезапуск Jenkins після розблокування"

# Таймаут для запуску усіх служб та сервісів
echo
echo "Запуск служб та сервісів..."
sleep 10

# Встановлення плагінів
echo
echo "Встановлення плагінів..."
FULL_CRUMB=$(curl -u "$ADMIN_USERNAME:$ADMIN_PASSWORD" --cookie-jar "$COOKIE_JAR" $JENKINS_URL/crumbIssuer/api/xml?xpath=concat\(//crumbRequestField,%22:%22,//crumb\))
ARR_CRUMB=(${FULL_CRUMB//:/ })
ONLY_CRUMB=${ARR_CRUMB[1]}

# Список плагінів (з @latest для актуальності)
PLUGINS=("cloudbees-folder@latest" "antisamy-markup-formatter@latest" "build-timeout@latest" "credentials-binding@latest" "timestamper@latest" "ws-cleanup@latest" "ant@latest" "gradle@latest" "workflow-aggregator@latest" "github-branch-source@latest" "pipeline-github-lib@latest" "pipeline-stage-view@latest" "git@latest" "ssh-slaves@latest" "matrix-auth@latest" "pam-auth@latest" "ldap@latest" "email-ext@latest" "mailer@latest" "configuration-as-code@latest")

# Формування XML пейлоаду
XML_PAYLOAD="<jenkins>"
for PLUGIN in "${PLUGINS[@]}"; do
    XML_PAYLOAD+="<install plugin=\"$PLUGIN\" />"
done
XML_PAYLOAD+="</jenkins>"

# Запит з XML
curl -X POST -u "$ADMIN_USERNAME:$ADMIN_PASSWORD" $JENKINS_URL/pluginManager/installNecessaryPlugins \
    -H "Connection: keep-alive" \
    -H "Accept: application/json, text/javascript, */*; q=0.01" \
    -H "X-Requested-With: XMLHttpRequest" \
    -H "$FULL_CRUMB" \
    -H "Content-Type: text/xml" \
    --cookie $COOKIE_JAR \
    --data "$XML_PAYLOAD"
check_status "Встановлення плагінів"

# Таймаут для встановлення плагінів
echo
echo "Запуск плагінів..."
sleep 60  # Асинхронне встановлення — додайте більше, якщо потрібно

# Перезапуск Jenkins після встановлення плагінів
echo
echo "Перезапуск Jenkins після встановлення плагінів..."
sudo systemctl restart jenkins
check_status "Перезапуск Jenkins після встановлення плагінів"

# Таймаут для запуску усіх служб та сервісів
echo
echo "Запуск служб та сервісів..."
sleep 10

# Підтвердження URL (URL-енкодинг для Python 3)
echo
echo "Підтвердження URL..."
URL_ENCODED=$(python3 -c "from urllib.parse import quote; print(quote(input(), safe=''))" <<< "$JENKINS_URL")
FULL_CRUMB=$(curl -u "$ADMIN_USERNAME:$ADMIN_PASSWORD" --cookie-jar "$COOKIE_JAR" $JENKINS_URL/crumbIssuer/api/xml?xpath=concat\(//crumbRequestField,%22:%22,//crumb\))
ARR_CRUMB=(${FULL_CRUMB//:/ })
ONLY_CRUMB=${ARR_CRUMB[1]}
curl -X POST -u "$ADMIN_USERNAME:$ADMIN_PASSWORD" $JENKINS_URL/setupWizard/configureInstance \
    -H "Connection: keep-alive" \
    -H "Accept: application/json, text/javascript, */*; q=0.01" \
    -H "X-Requested-With: XMLHttpRequest" \
    -H "$FULL_CRUMB" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -H "Accept-Language: en,en-US;q=0.9,it;q=0.8" \
    --cookie $COOKIE_JAR \
    --data-raw "rootUrl=$URL_ENCODED%2F&Jenkins-Crumb=$ONLY_CRUMB"
check_status "Підтвердження URL"

# Перезапуск Jenkins після підтвердження URL
echo
echo
echo "Перезапуск Jenkins після підтвердження URL..."
sudo systemctl restart jenkins
check_status "Перезапуск Jenkins після підтвердження URL..."

# Таймаут для запуску усіх служб та сервісів
echo
echo "Запуск служб та сервісів..."
sleep 10

# Вивід кінцевого повідомлення
echo
echo "Встановлення Jenkins та Docker завершено!"
echo "Jenkins доступний на $JENKINS_URL"
echo "Дані для входу: $ADMIN_USERNAME / $ADMIN_PASSWORD"
echo
