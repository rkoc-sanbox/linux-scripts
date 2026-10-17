#!/bin/bash

# Sprawdzenie, czy zainstalowane jest narzędzie do konwersji
if command -v heif-convert &> /dev/null; then
    CMD="heif"
elif command -v convert &> /dev/null; then
    CMD="imagemagick"
else
    echo "Błąd: Brak narzędzia do konwersji. Zainstaluj libheif-examples lub imagemagick:"
    echo "  sudo apt install libheif-examples"
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Użycie: $0 plik1.heic [plik2.heic ...]"
    exit 1
fi

# Pętla przetwarzająca podane pliki
for file in "$@"; do
    if [ ! -f "$file" ]; then
        echo "Pomijam: '$file' (plik nie istnieje)"
        continue
    fi

    # Pobranie nazwy pliku bez rozszerzenia
    output="${file%.*}.jpg"

    echo -n "Konwersja '$file' -> '$output'... "

    if [ "$CMD" = "heif" ]; then
        err=$(heif-convert -q 95 "$file" "$output" 2>&1)
    else
        err=$(convert "$file" -quality 95 "$output" 2>&1)
    fi
    status=$?

    if [ $status -eq 0 ]; then
        echo "OK"
    else
        echo "BŁĄD (kod $status)"
        if [ -n "$err" ]; then
            echo "$err" | sed 's/^/    /'
        fi
        if [[ "$err" == *"Unsupported codec"* ]]; then
            echo "    Wskazówka: brak dekodera HEVC. Zainstaluj: sudo apt install libheif-plugin-libde265"
        fi
    fi
done
