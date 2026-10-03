IMAGE_NAME = shogunsun/latex-builder:latest
BUILD_DIR  = build
SRC_DIR    = src
TARGET     = main

.PHONY: all pull image-build image-push pdf clean

all: pdf

# Локальная пересборка с новым Dockerfile
image-build:
	docker build \
		--build-arg USER_ID=$$(id -u) \
		--build-arg GROUP_ID=$$(id -g) \
		-t $(IMAGE_NAME) .

# Пуш обновленного образа в Docker Hub
image-push:
	docker push $(IMAGE_NAME)

pdf:
	mkdir -p $(BUILD_DIR)
	docker run --rm \
		-v $(CURDIR):/data \
		-e TEXINPUTS="./src//:" \
		-e OSFONTDIR="/data/fonts//" \
		$(IMAGE_NAME) \
		sh -c "fc-cache -f && xelatex -shell-escape -output-directory=build src/main.tex && xelatex -shell-escape -output-directory=build src/main.tex"

clean:
	rm -rf $(BUILD_DIR)