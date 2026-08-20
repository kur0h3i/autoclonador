# autoclonador
Script en Bash que clona un repositorio de GitHub, instala sus dependencias en un entorno virtual y crea un comando global para poder ejecutarlo desde cualquier sitio.
 
Pensado sobre todo para herramientas OSINT, pentesting o utilidades CLI en Python que uno instala desde GitHub y siempre acaba con carpetas dispersas y venvs olvidados.
 
## Requisitos
 
- `git`
- `python3` y `python3-venv`
## Instalación
 
```bash
curl -O https://raw.githubusercontent.com/kur0h3i/autoclonador/refs/heads/main/autoclonador.sh
chmod +x autoclonador.sh
mv autoclonador.sh ~/.local/bin/autoclonador
```
 
Asegúrate de que `~/.local/bin` está en tu `PATH`. Si no, añade a tu `~/.bashrc`:
 
```bash
export PATH="$HOME/.local/bin:$PATH"
```
 
## Uso
 
```bash
install-tool <url-repo> [nombre-comando] [entry-point]
```
 
Ejemplo:
 
```bash
autoclonador https://github.com/N0rz3/Phunter.git
phunter -u +34600000000
```
 
Si vuelves a lanzar el script sobre un repo ya instalado, hace `git pull` y reinstala las dependencias.
 
## Qué hace
 
1. Clona el repo en `~/opt/<nombre>/`
2. Si detecta Python (`requirements.txt`, `setup.py` o `pyproject.toml`), crea un venv e instala las dependencias
3. Crea un launcher en `~/.local/bin/` con el nombre del repo
4. Ya puedes llamar a la herramienta desde cualquier sitio
## Desinstalar
 
```bash
rm ~/.local/bin/phunter
rm -rf ~/opt/Phunter
```
 
## Licencia
 
MIT
