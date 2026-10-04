# LaTeX GOST Template

![LaTeX](https://img.shields.io/badge/docs-LaTeX-blue?logo=latex&logoColor=white)
![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)

Шаблон для оформления документов по стандартам ЕСКД / ГОСТ. Проект оптимизирован под современный компилятор **XeLaTeX** и не требует ручной установки тяжелых TeX-окружений благодаря сборке через Docker.

---

## Как собрать?

1. Склонируйте репозиторий и перейдите в папку шаблона:
```bash
git clone https://github.com/Shogun-Sun/LaTeXperiments.git && cd LaTeXperiments/templates/latex-gost-template/
```
2. Запустите сборку с помощью Make:
```bash
make
```
> Примечание: для сборки используется докер контейнер [shogunsun/latex-builder](https://hub.docker.com/r/shogunsun/latex-builder). При выполнении make он подтянется автоматически, но вы также можете собрать его локально из Dockerfile с помощью команды ```make image-build```.

---
## Очистка
Для удаления результатов сборки (временных файлов TeX и скомпилированного PDF) выполните:
```bash
make clean
```

## Лицензия и авторские права

В данном репозитории используется гибридная схема лицензирования:

* Структура шаблона, инфраструктура, Makefile, Dockerfile и вспомогательные скрипты распространяются под лицензией **Creative Commons Attribution 4.0 (CC BY 4.0)**.
* Файлы стилей и макросы пакета `eskdx**` находятся под оригинальной лицензией **LaTeX Project Public License (LPPL v1.3)** с сохранением авторских прав разработчика:
> *Copyright 2006 Konstantin Korikov <lostclus@ua.fm>