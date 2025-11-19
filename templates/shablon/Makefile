all: diagrams template/index.pdf
HOST_USER := $(shell whoami)
docx: template/index.docx

template/index.docx:
	-$(MAKE) template/index.pdf
	-pdf2docx convert template/index.pdf template/index.docx

.PHONY: all template/index.pdf cli clean clean-all double-build diagrams

# Правило для генерации диаграмм PlantUML
diagrams:
	@echo "Генерация диаграмм PlantUML..."
	@find template -name "*.puml" -type f -exec sh -c 'cd "$$(dirname "{}")" && plantuml -tpng "$$(basename "{}")"' \;
	@echo "Очистка лишних директорий с изображениями..."
	@find template/images -type d -name "template" -exec rm -rf {} \; 2>/dev/null || true
	@find template/images -type d -name "ochagaev-template-nntc" -exec rm -rf {} \; 2>/dev/null || true

template/index.pdf: template/index.tex template/header.tex template/eskdx.tex template/eskdlang.sty template/eskdsect.sty template/eskdstamp.sty
	docker run --rm -i --user="$(id -u):$(id -g)" -v `pwd`/template:/data -v `pwd`/fonts:/usr/share/fonts/truetype/gost nexi57/latex-builder:latest xelatex -interaction=nonstopmode index.tex
	docker run --rm -i --user="$(id -u):$(id -g)" -v `pwd`/template:/data -v `pwd`/fonts:/usr/share/fonts/truetype/gost nexi57/latex-builder:latest xelatex -interaction=nonstopmode index.tex

# Правило для автоматического двойного запуска make
double-build:
	@echo "Первый проход сборки..."
	@$(MAKE)
	@echo "Второй проход сборки..."
	@$(MAKE)

# Отслеживание изменений файлов и автоматический запуск
watch:
	@echo "Отслеживание изменений файлов. Для остановки нажмите Ctrl+C."
	@while true; do \
		find template -type f -name "*.tex" -o -name "*.sty" -o -name "*.puml" | inotifywait -e modify -q $$(cat); \
		echo "Обнаружены изменения файлов. Запуск double-build..."; \
		$(MAKE) double-build || echo "\n!!!!!!!!!!!!!!!!!!!!!!!!! LaTeX Compilation Failed !!!!!!!!!!!!!!!!!!!!!!!!!\n"; \
	done

cli:
	@echo "Запуск интерактивного контейнера LaTeX..."
	@echo 
	@docker run --rm -it \
		--user="$(id -u):$(id -g)" \
		-v $(shell pwd)/template:/data \
		-v $(shell pwd)/fonts:/usr/share/fonts/truetype/gost \
		-w /data \
		nexi57/latex-builder:latest \
		/bin/bash
	# docker run --rm -i -u root -v `pwd`/template:/data -v `pwd`/fonts:/usr/share/fonts/truetype/gost nexi57/latex-builder:latest /bin/bash

clean:
	rm -rf template/*.aux template/*.out template/*.toc template/*.log template/_minted-ex*

clean-all: clean
	rm -rf template/*.pdf
