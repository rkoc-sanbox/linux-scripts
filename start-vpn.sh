#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")/start-vpn"

# --- KONFIGURACJA ---
# Plik konfiguracyjny OpenVPN (szablon) znajduje się w tym samym katalogu co skrypt
BASE_VPN_CONFIG="$SCRIPT_DIR/RadoslawKociubaWPM.o2VPN.ovpn.template"

# Wpisy z danymi logowania w `pass` (osobno login i hasło)
PASS_AUTH_USER_ENTRY="ad/user"
PASS_AUTH_PASS_ENTRY="ad/pass"
# Nazwa wpisu z hasłem do klucza prywatnego w `pass`
PASS_KEY_PASS_ENTRY="vpn/key-pass"
# Nazwy wpisów dla certyfikatów i klucza w `pass`
PASS_CA_CERT="vpn/ca-cert"
PASS_CLIENT_CERT="vpn/client-cert"
PASS_CLIENT_KEY="vpn/client-key"

# Utwórz bezpieczne pliki tymczasowe
TEMP_AUTH_FILE=$(mktemp)
TEMP_KEY_PASS_FILE=$(mktemp)
TEMP_OVPN_CONFIG=$(mktemp) # Tymczasowy plik .ovpn

# Ustaw pułapkę (trap), która usunie pliki tymczasowe po zakończeniu skryptu
trap 'rm -f "$TEMP_AUTH_FILE" "$TEMP_KEY_PASS_FILE" "$TEMP_OVPN_CONFIG"' EXIT

echo "Pobieranie danych logowania użytkownika z 'pass'..."
# OpenVPN oczekuje: login w pierwszej linii, hasło w drugiej
VPN_USER="$(pass show "$PASS_AUTH_USER_ENTRY" | head -n 1)"
VPN_PASS="$(pass show "$PASS_AUTH_PASS_ENTRY" | head -n 1)"

VPN_USER="sso"

if [ -z "$VPN_USER" ] || [ -z "$VPN_PASS" ]; then
    echo "Blad: nie udalo sie pobrac loginu ($PASS_AUTH_USER_ENTRY) lub hasla ($PASS_AUTH_PASS_ENTRY) z 'pass'." >&2
    exit 1
fi

printf '%s\n%s\n' "$VPN_USER" "$VPN_PASS" > "$TEMP_AUTH_FILE"
unset VPN_PASS

echo "Pobieranie hasła do klucza prywatnego z 'pass'..."
pass show "$PASS_KEY_PASS_ENTRY" > "$TEMP_KEY_PASS_FILE"

echo "Generowanie tymczasowego pliku konfiguracyjnego OpenVPN..."
# Kopiuj bazową konfigurację bez odwołań do plików ca/cert/key (openvpn3 ich nie
# wczyta - certyfikaty idą niżej inline) i bez skryptów up/down, których openvpn3
# nie uruchamia (DNS ustawia sam przez systemd-resolved)
grep -vE '^\s*(ca|cert|key|script-security|up|down|up-restart|down-pre)(\s|$)' \
    "$BASE_VPN_CONFIG" > "$TEMP_OVPN_CONFIG"

# Wstaw certyfikaty i klucz do tymczasowego pliku .ovpn
echo "<ca>" >> "$TEMP_OVPN_CONFIG"
pass show "$PASS_CA_CERT" >> "$TEMP_OVPN_CONFIG"
echo "</ca>" >> "$TEMP_OVPN_CONFIG"

echo "<cert>" >> "$TEMP_OVPN_CONFIG"
pass show "$PASS_CLIENT_CERT" >> "$TEMP_OVPN_CONFIG"
echo "</cert>" >> "$TEMP_OVPN_CONFIG"

echo "<key>" >> "$TEMP_OVPN_CONFIG"
pass show "$PASS_CLIENT_KEY" >> "$TEMP_OVPN_CONFIG"
echo "</key>" >> "$TEMP_OVPN_CONFIG"

echo "Uruchamianie OpenVPN 3 (Ctrl+C rozłącza)..."
# openvpn3 działa przez D-Bus, więc nie potrzebuje sudo; poprzednia wersja
# (sudo openvpn) jest w start-vpn.sh.openvpn2.bak
python3 "$SCRIPT_DIR/openvpn3-connect.py" \
    --config "$TEMP_OVPN_CONFIG" \
    --auth-user-pass "$TEMP_AUTH_FILE" \
    --askpass "$TEMP_KEY_PASS_FILE"

echo "Połączenie VPN zakończone."

