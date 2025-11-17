CURRENT_DIR = $(shell pwd)
MAIN_FILE = index.tex
SRC_DIR = src/doc
BUILD_DIR = $(CURRENT_DIR)/build
LIVE_DIR = $(BUILD_DIR)/live

all: doc

# -------------------------------------
# Стандартная сборка PDF
# -------------------------------------
doc: $(SRC_DIR)
	docker run --rm -i --user="$(shell id -u):$(shell id -g)" \
		-v $(CURRENT_DIR)/src/doc:/data \
		-v $(CURRENT_DIR)/fonts:/root/.fonts \
		mingc/latex \
		sh -c "xelatex -interaction=nonstopmode /data/$(MAIN_FILE) && xelatex -interaction=nonstopmode /data/$(MAIN_FILE)"
	mkdir -p $(BUILD_DIR)
	mv $(SRC_DIR)/$(MAIN_FILE:.tex=.pdf) $(BUILD_DIR)/doc.pdf

# -------------------------------------
# CLI в контейнере
# -------------------------------------
cli:
	docker run --rm -i -u root \
		-v $(CURRENT_DIR)/src/doc:/data \
		-v $(CURRENT_DIR)/fonts:/root/.fonts \
		-v $(CURRENT_DIR)/eskdx:/usr/local/texlive/2021/texmf-dist/tex/latex/eskdx \
		mingc/latex /bin/bash

# -------------------------------------
# Очистка
# -------------------------------------
clean: clean_doc

clean_doc:
	rm -rf $(BUILD_DIR)

# -------------------------------------
# Watch: пересборка в реальном времени
# -------------------------------------
watch:
	@mkdir -p $(LIVE_DIR)
	@echo "Watching .tex files for changes with latexmk -pvc..."
	docker run --rm -i \
		-v $(CURRENT_DIR)/src/doc:/data \
		-v $(CURRENT_DIR)/fonts:/root/.fonts \
		-v $(BUILD_DIR):/data_build \
		-e TEXMFVAR=/data_build/.texlive2021 \
		mingc/latex \
		latexmk -pdf -xelatex -pvc -interaction=nonstopmode -outdir=/data_build /data/$(MAIN_FILE)
