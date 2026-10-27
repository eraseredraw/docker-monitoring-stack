# Стенд: проверка конфигов до запуска и быстрое поднятие/сброс.
# promtool берётся из образа Prometheus — локально ничего ставить не нужно.
# --entrypoint обязателен: у prom/prometheus:latest entrypoint уже /bin/prometheus.

PROM_IMAGE  := prom/prometheus:latest
GRAFANA_URL := http://localhost:3000

.PHONY: help lint up down ps logs check-targets reset

help:
	@grep -E '^[a-z-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-12s %s\n", $$1, $$2}'

lint: ## Проверить prometheus.yml и alert-правила через promtool
	@docker run --rm --entrypoint promtool -v "$(PWD):/cfg:ro" $(PROM_IMAGE) \
		check config /cfg/prometheus.yml
	@docker run --rm --entrypoint promtool -v "$(PWD):/cfg:ro" $(PROM_IMAGE) \
		check rules /cfg/rules/alerts.yml

up: lint ## Проверить конфиги и поднять стек
	@docker compose up -d
	@echo "Prometheus: http://localhost:9090 | Grafana: $(GRAFANA_URL) | cAdvisor: http://localhost:8080"

down: ## Остановить стек (данные Grafana сохраняются в volume)
	@docker compose down

ps: ## Показать состояние контейнеров стенда
	@docker compose ps

logs: ## Логи Prometheus
	@docker compose logs --tail=50 prometheus

check-targets: ## Убедиться, что все цели в состоянии UP
	@for t in prometheus cadvisor node-exporter; do \
		s=$$(curl -s "http://localhost:9090/api/v1/targets" | grep -o "\"labels\":{\"job\":\"$$t\"[^}]*\"health\":\"[a-z]*\"" | grep -o 'health":"[a-z]*' | cut -d'"' -f3); \
		echo "  $$t -> $${s:-не найдено}"; \
	done

reset: ## Полный сброс стенда вместе с данными Grafana
	@docker compose down -v