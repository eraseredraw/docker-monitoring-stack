# Docker Monitoring Stack

Простой production-ready стек мониторинга на базе **Prometheus** и **Grafana**, разворачиваемый через Docker Compose. Этот проект демонстрирует навыки работы с контейнеризацией и настройкой систем мониторинга.

## 🚀 Возможности
- Разворачивание стека мониторинга одной командой.
- Сбор метрик с Docker-хоста через **cAdvisor**.
- Визуализация метрик в **Grafana**.
- Изолированная Docker-сеть для компонентов мониторинга.

## 📂 Структура проекта
```text
.
├── docker-compose.yml   # Описание сервисов стека
├── prometheus.yml       # Конфигурация сбора метрик
├── .gitignore
└── README.md
```

## 🛠️ Как использовать

### 1. Подготовка
Убедитесь, что у вас установлены **Docker** и **Docker Compose**:
```bash
docker --version
docker-compose --version
```

### 2. Запуск стека
```bash
docker-compose up -d
```

### 3. Проверка
После запуска откройте в браузере:
- **Prometheus**: http://localhost:9090 — сбор метрик.
- **Grafana**: http://localhost:3000 — визуализация (логин: `admin`, пароль: `admin`).
- **cAdvisor**: http://localhost:8080 — метрики контейнеров.

### 4. Добавление дашборда Grafana
1. Зайдите в Grafana.
2. Добавьте источник данных **Prometheus** (`http://prometheus:9090`).
3. Импортируйте дашборд, например ID **193** (Diplina monitoring) или **3124** (Node exporter).

### 5. Остановка стека
```bash
docker-compose down
```

## 🧩 Архитектура
```text
Docker Host
├── cAdvisor (8080) ──┐
├── Prometheus (9090) ── Grafana (3000)
└── monitoring network (bridge)
```

## 📚 Стек технологий
- **Docker / Docker Compose**: Контейнеризация и оркестрация.
- **Prometheus**: Сбор и хранение метрик.
- **Grafana**: Визуализация метрик.
- **cAdvisor**: Метрики Docker-контейнеров.