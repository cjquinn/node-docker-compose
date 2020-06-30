.PHONY: bash down install up

PROJECT=node-docker-compose

bash:
	docker run -it --rm \
		-v $(PWD):/opt \
		-w /opt \
		--network=$(PROJECT)_network \
		node-docker-compose_node \
		bash

down:
	docker-compose down

install:
	docker run -it --rm \
		-v $(PWD):/opt \
		-w /opt \
		--network=$(PROJECT)_network \
		node-docker-compose_node \
		npm i

up:
	docker-compose up -d
