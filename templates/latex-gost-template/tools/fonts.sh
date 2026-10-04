#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# Настройка шрифта
# ============================================================

# ------------------------------------------------------------
# Пути
# ------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

FONTS_DIR="${PROJECT_ROOT}/fonts"
CONFIG_FILE="${PROJECT_ROOT}/src/config/fonts.tex"

# ------------------------------------------------------------
# Вспомогательные функции
# ------------------------------------------------------------

print_usage() {
    echo "Использование:"
    echo
    echo "  $0"
    echo "      Показать доступные шрифты."
    echo
    echo "  $0 <название>"
    echo "      Выбрать шрифт и создать src/config/fonts.tex."
    echo
}

error() {
    echo "Ошибка: $*" >&2
    exit 1
}

# ------------------------------------------------------------
# Проверка каталогов
# ------------------------------------------------------------

[[ -d "${FONTS_DIR}" ]] || \
    error "каталог fonts не найден: ${FONTS_DIR}"

# ------------------------------------------------------------
# Поиск шрифтов
# ------------------------------------------------------------

mapfile -t FONT_DIRS < <(
    find "${FONTS_DIR}" \
        -type f \
        -iname '*.ttf' \
        -printf '%h\n' |
    sort -u
)

if [[ ${#FONT_DIRS[@]} -eq 0 ]]; then
    error "в каталоге ${FONTS_DIR} не найдено ни одного .ttf файла"
fi

# ------------------------------------------------------------
# Вывод списка доступных шрифтов
# ------------------------------------------------------------

if [[ $# -eq 0 ]]; then
    echo "Доступные шрифты:"
    echo

    for font_dir in "${FONT_DIRS[@]}"; do
        font_name="$(basename "${font_dir}")"
        echo "  ${font_name}"
    done

    echo
    echo "Чтобы выбрать шрифт, запустите:"
    echo
    echo "  $0 <название>"
    echo
    echo "Например:"
    echo
    echo "  $0 IBMPlexSans"

    exit 0
fi

# ------------------------------------------------------------
# Проверка аргументов
# ------------------------------------------------------------

if [[ $# -gt 1 ]]; then
    print_usage
    exit 1
fi

# ------------------------------------------------------------
# Выбор шрифта
# ------------------------------------------------------------

FONT_NAME="$1"
SELECTED_DIR=""

for font_dir in "${FONT_DIRS[@]}"; do
    if [[ "$(basename "${font_dir}")" == "${FONT_NAME}" ]]; then
        SELECTED_DIR="${font_dir}"
        break
    fi
done

[[ -n "${SELECTED_DIR}" ]] || \
    error "шрифт '${FONT_NAME}' не найден"

# ------------------------------------------------------------
# Поиск файлов начертаний
# ------------------------------------------------------------

mapfile -t FONT_FILES < <(
    find "${SELECTED_DIR}" \
        -maxdepth 1 \
        -type f \
        -iname '*.ttf' \
        ! -iname '*variablefont*' |
    sort
)

if [[ ${#FONT_FILES[@]} -eq 0 ]]; then
    error "в каталоге шрифта '${FONT_NAME}' нет .ttf файлов"
fi

# ------------------------------------------------------------
# Определение начертаний
# ------------------------------------------------------------

REGULAR_FILES=()
BOLD_FILES=()
ITALIC_FILES=()
BOLD_ITALIC_FILES=()
BASE_FONT_NAME="${FONT_NAME,,}"
BASE_FONT_NAME="${BASE_FONT_NAME//[^a-z0-9]/}"

for font_file in "${FONT_FILES[@]}"; do
    file_name="$(basename "${font_file}")"
    lower_name="${file_name,,}"

    normalized_name="${lower_name%.ttf}"
    normalized_name="${normalized_name//[^a-z0-9]/}"

    # Bold Italic
    if [[ "${lower_name}" =~ (^|[-_])bold[-_]?italic([._-]|$) ]]; then
        BOLD_ITALIC_FILES+=("${font_file}")

    # Bold
    elif [[ "${lower_name}" =~ (^|[-_])bold([._-]|$) ]]; then
        BOLD_FILES+=("${font_file}")

    # Italic
    elif [[ "${lower_name}" =~ (^|[-_])italic([._-]|$) ]]; then
        ITALIC_FILES+=("${font_file}")

    # Regular с явным названием
    elif [[ "${lower_name}" =~ (^|[-_])regular([._-]|$) ]]; then
        REGULAR_FILES+=("${font_file}")

    # Regular без суффикса
    elif [[ "${normalized_name}" == "${BASE_FONT_NAME}" ]]; then
        REGULAR_FILES+=("${font_file}")
    fi
done

# ------------------------------------------------------------
# Проверка количества файлов
# ------------------------------------------------------------

# Если в каталоге только один TTF-файл,
# используем его для всех начертаний.
if [[ ${#FONT_FILES[@]} -eq 1 ]]; then
    SINGLE_FONT_FILE="${FONT_FILES[0]}"

    REGULAR_FILES=("${SINGLE_FONT_FILE}")
    BOLD_FILES=("${SINGLE_FONT_FILE}")
    ITALIC_FILES=("${SINGLE_FONT_FILE}")
    BOLD_ITALIC_FILES=("${SINGLE_FONT_FILE}")

else
    check_single_style() {
        local style="$1"
        shift

        local files=("$@")

        if [[ ${#files[@]} -eq 0 ]]; then
            MISSING+=("${style}")
            return
        fi

        if [[ ${#files[@]} -gt 1 ]]; then
            echo "Ошибка: найдено несколько файлов для начертания '${style}':"
            echo

            for file in "${files[@]}"; do
                echo "  $(basename "${file}")"
            done

            echo
            error "невозможно однозначно определить начертание '${style}'"
        fi
    }

    MISSING=()

    check_single_style "Regular" "${REGULAR_FILES[@]}"
    check_single_style "Bold" "${BOLD_FILES[@]}"
    check_single_style "Italic" "${ITALIC_FILES[@]}"
    check_single_style "BoldItalic" "${BOLD_ITALIC_FILES[@]}"

    # --------------------------------------------------------
    # Проверка отсутствующих начертаний
    # --------------------------------------------------------

    if [[ ${#MISSING[@]} -gt 0 ]]; then
        echo "Предупреждение: у шрифта '${FONT_NAME}' отсутствуют начертания:"
        echo

        for style in "${MISSING[@]}"; do
            echo "  - ${style}"
        done

        echo
        error "конфигурация шрифта не создана"
    fi
fi

# ------------------------------------------------------------
# Получение имён файлов
# ------------------------------------------------------------

REGULAR_FILE="$(basename "${REGULAR_FILES[0]}")"
BOLD_FILE="$(basename "${BOLD_FILES[0]}")"
ITALIC_FILE="$(basename "${ITALIC_FILES[0]}")"
BOLD_ITALIC_FILE="$(basename "${BOLD_ITALIC_FILES[0]}")"

# ------------------------------------------------------------
# Относительный путь
# ------------------------------------------------------------

RELATIVE_PATH="${SELECTED_DIR#"${PROJECT_ROOT}"/}"
FONT_PATH="${RELATIVE_PATH}/"

# ------------------------------------------------------------
# Создание конфигурации
# ------------------------------------------------------------

mkdir -p "$(dirname "${CONFIG_FILE}")"

cat > "${CONFIG_FILE}" <<EOF
% ============================================================
% Пользовательская настройка шрифта
% ============================================================

% ------------------------------------------------------------
% Семейство
% ------------------------------------------------------------

\\newcommand{\\ConfigFontPath}{${FONT_PATH}}

% ------------------------------------------------------------
% Начертания
% ------------------------------------------------------------

\\newcommand{\\ConfigFontRegular}{${REGULAR_FILE}}
\\newcommand{\\ConfigFontBold}{${BOLD_FILE}}
\\newcommand{\\ConfigFontItalic}{${ITALIC_FILE}}
\\newcommand{\\ConfigFontBoldItalic}{${BOLD_ITALIC_FILE}}
EOF

# Удаление последнего переноса строки
truncate -s -1 "${CONFIG_FILE}"

# ------------------------------------------------------------
# Результат
# ------------------------------------------------------------

echo "Шрифт '${FONT_NAME}' выбран."
echo
if [[ ${#FONT_FILES[@]} -eq 1 ]]; then
    echo "Используется один файл для всех начертаний:"
    echo "  $(basename "${FONT_FILES[0]}")"
fi
echo
echo "Конфигурация создана:"
echo "  ${CONFIG_FILE}"