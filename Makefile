# Docker команди
# ----------------------------------------

.PHONY: build
build:  ## Зібрати Docker-контейнери
	docker-compose build

.PHONY: up
up:  ## Запустити Docker-контейнери з логами в реальному часі
	docker-compose up

.PHONY: start
start:  ## Запустити Docker-контейнери у фоновому режимі
	docker-compose up -d

.PHONY: stop
stop:  ## Зупинити Docker-контейнери
	docker-compose stop

.PHONY: down
down:  ## Зупинити Docker-контейнери та видалити їх
	docker-compose down

# Команди для бази даних Django
# ----------------------------------------

.PHONY: makemigrations
makemigrations:  ## Створити нові міграції для бази даних
	docker-compose run --rm web python manage.py makemigrations

.PHONY: migrate
migrate:  ## Застосувати міграції для бази даних
	docker-compose run --rm web python manage.py migrate

.PHONY: migrate-all
migrate-all: makemigrations migrate  ## Створити та застосувати міграції

.PHONY: db-dump
db-dump:  ## Створити дамп бази даних у папці database
	mkdir -p database
	docker-compose exec db pg_dump -U winst db01 > database/db_dump.sql

.PHONY: db-restore
db-restore:  ## Відновити базу даних із дампу у папці database
	docker-compose exec -T db psql -U winst db01 < database/db_dump.sql

.PHONY: db-clear
db-clear:  ## Очистити всі дані з бази даних
	docker-compose exec db psql -U winst -d db01 -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

# Створення суперкористувача
createsuperuser:
	@docker-compose exec web python manage.py createsuperuser
	
# Django команди
# ----------------------------------------

.PHONY: django-shell
django-shell:  ## Відкрити Django shell
	docker-compose run --rm web python manage.py shell

.PHONY: db-shell
db-shell:  ## Відкрити shell PostgreSQL
	docker-compose exec db psql -U winst db01

.PHONY: test
test:  ## Запустити всі Django тести
	docker-compose run --rm web python manage.py test

# Команди для перевірки якості коду
# ----------------------------------------

.PHONY: lint
lint:  ## Перевірити якість коду за допомогою Flake8
	docker-compose run --rm web flake8 .

.PHONY: format
format:  ## Відформатувати код за допомогою Black
	docker-compose run --rm web black .


##-------------------------PROD--DEV--------------------------

# Визначення змінних для середовищ
DEV_ENV_FILE = environment/dev.env
PROD_ENV_FILE = environment/prod.env
DOCKER_COMPOSE = docker-compose

# Визначення цілей
.PHONY: up-dev up-prod migrate-all-dev migrate-all-prod createsuperuser-dev createsuperuser-prod switch-dev switch-prod down-env

down-dev:
	$(DOCKER_COMPOSE) -f docker-compose.dev.yml down

down-prod:
	$(DOCKER_COMPOSE) -f docker-compose.prod.yml down

# Запуск Docker Compose в середовищі для розробки
up-dev:
	$(DOCKER_COMPOSE) -f docker-compose.dev.yml --env-file $(DEV_ENV_FILE) up -d --build

# Запуск Docker Compose в продакшн середовищі
up-prod:
	$(DOCKER_COMPOSE) -f docker-compose.prod.yml --env-file $(PROD_ENV_FILE) up -d --build

switch-dev:
	$(DOCKER_COMPOSE) -f docker-compose.dev.yml down
	$(DOCKER_COMPOSE) -f docker-compose.dev.yml --env-file $(DEV_ENV_FILE) up -d --build

switch-prod:
	$(DOCKER_COMPOSE) -f docker-compose.prod.yml down
	$(DOCKER_COMPOSE) -f docker-compose.prod.yml --env-file $(PROD_ENV_FILE) up -d --build

migrate-all-dev:
	$(DOCKER_COMPOSE) -f docker-compose.dev.yml --env-file $(DEV_ENV_FILE) exec web python manage.py makemigrations
	$(DOCKER_COMPOSE) -f docker-compose.dev.yml --env-file $(DEV_ENV_FILE) exec web python manage.py migrate

migrate-all-prod:
	$(DOCKER_COMPOSE) -f docker-compose.prod.yml --env-file $(PROD_ENV_FILE) exec web python manage.py makemigrations
	$(DOCKER_COMPOSE) -f docker-compose.prod.yml --env-file $(PROD_ENV_FILE) exec web python manage.py migrate

createsuperuser-dev:
	$(DOCKER_COMPOSE) -f docker-compose.dev.yml --env-file $(DEV_ENV_FILE) exec web python manage.py createsuperuser

createsuperuser-prod:
	$(DOCKER_COMPOSE) -f docker-compose.prod.yml --env-file $(PROD_ENV_FILE) exec web python manage.py createsuperuser