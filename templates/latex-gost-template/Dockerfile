FROM debian:bookworm-slim

# Принимаем динамические UID и GID хост-пользователя, чтобы избежать проблем с правами на файлы
ARG USER_ID=1000
ARG GROUP_ID=1000

# Установка пакетов TeX Live, утилит сборки, Python/Pygments и свободных шрифтов
RUN apt-get update && apt-get install -y --no-install-recommends \
    texlive-latex-base \
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-xetex \
    texlive-lang-cyrillic \
    texlive-bibtex-extra \
    texlive-fonts-recommended \
    python3-pygments \
    fontconfig \
    make \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Создаем пользователя с тем же UID/GID, что и на хосте
RUN groupadd -g ${GROUP_ID} latexuser && \
    useradd -l -u ${USER_ID} -g latexuser -m -s /bin/bash latexuser

# Настраиваем рабочую директорию
WORKDIR /data

ENV OSFONTDIR=/data/fonts//

# Переключаемся на созданного пользователя
USER latexuser