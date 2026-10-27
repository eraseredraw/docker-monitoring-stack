# Docker Monitoring Lab

[![CI](https://github.com/eraseredraw/docker-monitoring-stack/actions/workflows/ci.yml/badge.svg)](https://github.com/eraseredraw/docker-monitoring-stack/actions/workflows/ci.yml)

Публичный стенд по observability: Prometheus + Grafana + cAdvisor + node-exporter, разворачивается одним `make up`.

## Статус репозитория

Это **лаборатория, а не боевой мониторинг**. Задача стенда — держать под рукой воспроизводимый контур, на котором можно проверить конфиг, правило алертинга или поведение scraper'а за минуту, не трогая рабочие системы.

Продакшн-конфигурации (Alertmanager, Long-Term Storage, реальные дашборды и адреса инвентаря) лежат в закрытых репозиториях и не публикуются. Пароль `admin/admin` здесь — не забывчивость, а признак того, что контур поднят в изолированном контуре и наружу не смотрит.

## Что здесь проверяется

- Развёртывание контура мониторинга через Docker Compose с изолированной bridge-сетью.
- Сбор метрик хоста (`node-exporter`) и контейнеров (`cAdvisor` — мониторинг самого Docker).
- Валидация конфигурации до запуска: `make lint` гоняет `promtool check config` и `check rules`.
- Alert-правила как код: пороги памяти/диска/доступности в `rules/alerts.yml`, проверяются тем же promtool.
- Post-deploy проверка: `make check-targets` спрашивает у Prometheus API состояние целей, а не верит на слово, что «контейнер вверх».

## Структура

```
docker-compose.yml     prometheus, grafana, cadvisor, node-exporter
prometheus.yml         scrape-конфиг + подключение rule_files
rules/alerts.yml       alert-правила (host, memory, disk, containers)
Makefile               lint / up / ps / logs / check-targets / reset
.github/workflows/ci.yml   promtool-валидация + подъём стенда в CI
```

## Быстрый старт

```bash
make lint     # promtool проверяет prometheus.yml и правила (Docker уже нужен)
make up       # проверить и поднять
make ps       # состояние контейнеров
```

Порты:

| Сервис | Адрес |
|---|---|
| Prometheus | http://localhost:9090 |
| Grafana | http://localhost:3000 (`admin` / `admin`) |
| cAdvisor | http://localhost:8080 |
| node-exporter | http://localhost:9100 |

Проверить, что scrape-конвейер живой, можно не открывая браузер:

```bash
curl -s "http://localhost:9090/api/v1/query?query=up" | grep -o '"job":"[a-z-]*"' | sort -u
make check-targets
```

Гашение: `make down` сохраняет данные Grafana в volume, `make reset` сносит всё.

## Метрики и правила

- `up`, `node_memory_MemAvailable_bytes`, `node_filesystem_avail_bytes` — узел.
- `container_start_time_seconds`, `container_cpu_usage_seconds_total` — контейнеры.
- `HostDown`, `HighMemoryPressure`, `DiskSpaceLow`, `ContainerRestartedRecently` — см. `rules/alerts.yml`.

Правила написаны как данные в репозитории, а не кликами в UI: promtool их валидирует до применения, и их можно сравнить в diff.

## Не сделано осознанно

- **Alertmanager** — логичное продолжение, но роутинг алертов в мессенджер требует реальных адресов получателей.
- **Долгосрочное хранение** (Thanos/VictoriaMetrics) — на стенде с двумя хостами избыточно.
- **Экспортируемые дашборды Grafana как JSON** — стоит добавить, чтобы дашборды тоже жили в репозитории, а не в браузере.
- **Приватные пароли/секреты** — в публичном стенде их быть не должно.

## Стек

Docker Compose · Prometheus · PromQL · Alert rules · Grafana · cAdvisor · node-exporter