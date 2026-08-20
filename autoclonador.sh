#!/bin/bash
# ==================================================
# install-tool.sh — Clona un repo, detecta tipo,
# instala dependencias y crea un comando global.
# ==================================================
set -e

INSTALL_DIR="${INSTALL_DIR:-$HOME/opt}"      # cámbialo a /opt si insistes
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

REPO_URL="$1"
CUSTOM_NAME="$2"     # opcional: nombre del comando
CUSTOM_ENTRY="$3"    # opcional: archivo de entrada

if [ -z "$REPO_URL" ]; then
    echo "Uso: $0 <url-repo> [nombre-comando] [entrada.py]"
    echo "Ej:  $0 https://github.com/N0rz3/Phunter.git phunter phunter.py"
    exit 1
fi

REPO_NAME=$(basename "$REPO_URL" .git)
CMD_NAME="${CUSTOM_NAME:-$(echo "$REPO_NAME" | tr '[:upper:]' '[:lower:]')}"
TOOL_DIR="$INSTALL_DIR/$REPO_NAME"

mkdir -p "$INSTALL_DIR" "$BIN_DIR"

# --- Clonar o actualizar ---
if [ -d "$TOOL_DIR/.git" ]; then
    echo "[i] Repo ya existe, actualizando..."
    git -C "$TOOL_DIR" pull
else
    echo "[+] Clonando $REPO_URL en $TOOL_DIR..."
    git clone "$REPO_URL" "$TOOL_DIR"
fi

cd "$TOOL_DIR"

# --- Detectar si es Python ---
IS_PYTHON=false
if [ -f requirements.txt ] || [ -f setup.py ] || [ -f pyproject.toml ]; then
    IS_PYTHON=true
    echo "[i] Detectado proyecto Python"
fi

# --- Detectar entry point ---
if [ -n "$CUSTOM_ENTRY" ]; then
    ENTRY="$CUSTOM_ENTRY"
elif $IS_PYTHON; then
    LOWER=$(echo "$REPO_NAME" | tr '[:upper:]' '[:lower:]')
    if   [ -f "$LOWER.py" ];       then ENTRY="$LOWER.py"
    elif [ -f "$REPO_NAME.py" ];   then ENTRY="$REPO_NAME.py"
    elif [ -f main.py ];           then ENTRY="main.py"
    elif [ -f __main__.py ];       then ENTRY="__main__.py"
    else
        CANDIDATE=$(ls -- *.py 2>/dev/null | head -1)
        echo "[?] No detecté entry point. ¿Usar '$CANDIDATE'? [s/N]"
        read -r RESP
        [[ "$RESP" =~ ^[sS] ]] && ENTRY="$CANDIDATE" || { echo "Aborta."; exit 1; }
    fi
fi

# --- Instalar dependencias en venv ---
if $IS_PYTHON; then
    if [ ! -d venv ]; then
        echo "[+] Creando venv..."
        python3 -m venv venv
    fi
    echo "[+] Instalando dependencias..."
    ./venv/bin/pip install --upgrade pip --quiet
    [ -f requirements.txt ] && ./venv/bin/pip install -r requirements.txt
    if [ -f setup.py ] || [ -f pyproject.toml ]; then
        ./venv/bin/pip install -e .
    fi
fi

# --- Crear launcher global ---
LAUNCHER="$BIN_DIR/$CMD_NAME"
if $IS_PYTHON; then
    cat > "$LAUNCHER" <<EOF
#!/bin/bash
cd "$TOOL_DIR"
exec "$TOOL_DIR/venv/bin/python" "$TOOL_DIR/$ENTRY" "\$@"
EOF
else
    cat > "$LAUNCHER" <<EOF
#!/bin/bash
cd "$TOOL_DIR"
exec "$TOOL_DIR/$ENTRY" "\$@"
EOF
fi
chmod +x "$LAUNCHER"

# --- Comprobar PATH ---
if ! echo ":$PATH:" | grep -q ":$BIN_DIR:"; then
    echo ""
    echo "[!] $BIN_DIR NO está en tu PATH. Añade esto a ~/.bashrc o ~/.zshrc:"
    echo '    export PATH="$HOME/.local/bin:$PATH"'
fi

echo ""
echo "==================================================="
echo "[✓] Instalado en: $TOOL_DIR"
echo "[✓] Launcher:     $LAUNCHER"
echo "[✓] Ejecuta:      $CMD_NAME <args>"
echo "==================================================="
