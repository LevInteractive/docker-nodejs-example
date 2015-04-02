#
# Environment specific vars. Defaults set below.
#
include env_make

#
# Phony targets.
#
.PHONY: help build run-dev run-release save destroy

#
# Iterated after major releases.
#
VERSION ?= 1.0.0

#
# App image name: <user>/<appname>
#
APP_IMAGE_NAME ?= lev-interactive/myapp

#
# Set NODE_ENV for node/express.
#
NODE_ENV ?= development

#
# Main app container name.
#
APP_CONTAINER_NAME ?= myapp_container

#
# Container for database.
#
MONGO_CONTAINER_NAME ?= myapp_mongo_container

#
# Container for redis.
#
REDIS_CONTAINER_NAME ?= myapp_redis_container

#
# Container for nginx.
#
NGINX_CONTAINER_NAME ?= myapp_nginx_container

#
# Backup directory for db exports.
#
BACKUPS ?= backups

#
# Current directory.
#
CURDIR = $(shell pwd)

#
# Last backed up mongodb dump.
#
LAST_DUMP := $(shell ls -t $(CURDIR)/$(BACKUPS)/mongo | head -1)

help:
	@echo "\nApplication management. Please make sure you have the env_make file setup.\n"
	@echo "Usage: \n\
make build        This builds the $(APP_IMAGE_NAME) image. \n\
make run-dev      This will start the application mapping port 80 to 3030. All src \n\
                  files will be volumed as well for automatic restarts.\n\
                  be working in for instant changes. Runs on port 3000. \n\
make run-release  This will run a container without the volumes on port 80. Good \n\
                  for production. @TODO \n\
make save         This will save the database in the backups directory. \n\
make restore      This will restore from the last time you saved. \n\
make destroy      Stops and removes all running containers. \
"

build:
	@docker build -t $(APP_IMAGE_NAME):$(VERSION) --rm .

save:
	@if ! docker ps -a | grep -qF $(MONGO_CONTAINER_NAME); then \
		echo "No mongo container is running."; exit 1; \
	fi
	@mkdir -p $(BACKUPS) $(BACKUPS)/mongo
	@docker exec $(MONGO_CONTAINER_NAME) mongodump \
		--out /var/backups/mongo/dump-`date +%Y-%m-%d:%H:%M:%S`

restore:
	docker exec $(MONGO_CONTAINER_NAME) mongorestore --drop \
		/var/backups/mongo/$(LAST_DUMP)

run-dev:
	@echo "\n\033[0;33m=> Starting Redis --------------------------------------\033[0m"
	@docker run -d \
		--restart always \
		--name $(REDIS_CONTAINER_NAME) \
		redis:latest
	@echo "\n\033[0;33m=> Starting Mongo --------------------------------------\033[0m"
	@docker run -d \
		--restart always \
		--name $(MONGO_CONTAINER_NAME) \
		-v $(CURDIR)/server-config/mongo/mongo.conf:/etc/mongod.conf \
		-v $(CURDIR)/$(BACKUPS):/var/backups \
		mongo:3.0
	@echo "\n\033[0;33m=> Starting app instances (clustered) --------------------------------------\033[0m"
	@docker run -d \
		--name $(APP_CONTAINER_NAME)_1 \
		--link $(MONGO_CONTAINER_NAME):mongo \
		--link $(REDIS_CONTAINER_NAME):redis \
		--restart always \
		-e NODE_ENV=$(NODE_ENV) \
		-v $(CURDIR)/src:/app/src \
		$(APP_IMAGE_NAME):$(VERSION)
	@docker run -d \
		--name $(APP_CONTAINER_NAME)_2 \
		--link $(MONGO_CONTAINER_NAME):mongo \
		--link $(REDIS_CONTAINER_NAME):redis \
		--restart always \
		-e NODE_ENV=$(NODE_ENV) \
		-v $(CURDIR)/src:/app/src \
		$(APP_IMAGE_NAME):$(VERSION)
	@docker run -d \
		--name $(APP_CONTAINER_NAME)_3 \
		--link $(MONGO_CONTAINER_NAME):mongo \
		--link $(REDIS_CONTAINER_NAME):redis \
		--restart always \
		-e NODE_ENV=$(NODE_ENV) \
		-v $(CURDIR)/src:/app/src \
		$(APP_IMAGE_NAME):$(VERSION)
	@echo "\n\033[0;33m=> Starting NGINX --------------------------------------\033[0m"
	@docker run -d \
		--name $(NGINX_CONTAINER_NAME) \
		--link $(APP_CONTAINER_NAME)_1:nodeapp_1 \
		--link $(APP_CONTAINER_NAME)_2:nodeapp_2 \
		--link $(APP_CONTAINER_NAME)_3:nodeapp_3 \
		--restart always \
		-p "3030:80" \
		-v $(CURDIR)/server-config/nginx/sites-enabled:/etc/nginx/sites-enabled \
		-v $(CURDIR)/server-config/nginx/nginx.conf:/etc/nginx/nginx.conf \
		nginx:1.7.9
	@echo "\n\033[0;33m=> Tailing the nginx logs. --------------------------------------\033[0m"
	docker logs -f $(NGINX_CONTAINER_NAME)

destroy:
	@echo "\033[0mTearing down environment. \033[0m"
	@-docker rmi $(docker images -f "dangling=true" -q)
	@-docker stop $(APP_CONTAINER_NAME)_1
	@-docker rm -v $(APP_CONTAINER_NAME)_1
	@-docker stop $(APP_CONTAINER_NAME)_2
	@-docker rm -v $(APP_CONTAINER_NAME)_2
	@-docker stop $(APP_CONTAINER_NAME)_3
	@-docker rm -v $(APP_CONTAINER_NAME)_3
	@-docker stop $(MONGO_CONTAINER_NAME)
	@-docker rm -v $(MONGO_CONTAINER_NAME)
	@-docker stop $(REDIS_CONTAINER_NAME)
	@-docker rm -v $(REDIS_CONTAINER_NAME)
	@-docker stop $(NGINX_CONTAINER_NAME)
	@-docker rm -v $(NGINX_CONTAINER_NAME)
