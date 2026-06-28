<div align="center">

[![Web](https://img.shields.io/badge/Web-astefanov.com-10b981?style=flat-square&logo=vercel)](https://astefanov.com)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Alan_Stefanov-blue?style=flat-square&logo=linkedin)](https://www.linkedin.com/in/alanstefanov/)
[![GitHub](https://img.shields.io/badge/GitHub-AlanStefanov-black?style=flat-square&logo=github)](https://github.com/AlanStefanov)

**Alan Stefanov** — Engineering Manager · DevOps Engineer · Software Developer · _La Plata, Argentina_

---

</div>

# SimplePlex

> Stack de servidor multimedia auto-gestionado basado en Docker Compose.

**Idioma del README: Español** — Este proyecto está claramente orientado a un usuario hispanohablante (zona horaria Buenos Aires, contenido en español, comentarios en español). No tiene sentido documentarlo en inglés.

---

## 1. Propósito

SimplePlex despliega un ecosistema completo de servicios para la descarga, organización y streaming automatizado de contenido multimedia: series de TV y películas. Todo corre sobre Docker Compose en un único host Linux.

### Servicios incluidos

| Servicio | Función | Puerto |
|----------|---------|--------|
| **Plex** | Servidor de streaming multimedia | 32400 (host) |
| **Transmission** | Cliente BitTorrent | 9091 / 51413 |
| **Sonarr** | Gestión automatizada de series | 8989 |
| **Radarr** | Gestión automatizada de películas | 7878 |
| **Prowlarr** | Gestión de indexers (torrent sites) | 9696 |
| **Bazarr** | Descarga automatizada de subtítulos | 6767 |
| **Flaresolverr** | Bypass de Cloudflare para indexers | 8191 |

---

## 2. Requisitos del sistema

- **Docker** (≥ 20.x)
- **Docker Compose** (plugin `compose`, no el binario legacy)
- **Linux** (cualquier distro moderna; probado en entorno tipo Ubuntu/Debian)
- **Permisos**: El usuario ejecutor debe tener permisos para correr Docker.
- **Almacenamiento**: Espacio suficiente para medios, descargas y metadatos. Sin límites definidos en este stack.

---

## 3. Estructura del repositorio

```
SimplePlex/
├── .env                          # Variables de entorno (secretos incluidos)
├── docker-compose.yml            # Definición de servicios
├── config/                       # Configuración persistente de servicios
│   ├── plex/                     # Base de datos, metadatos, logs de Plex
│   ├── transmission/             # Settings de Transmission
│   ├── sonarr/                   # Config XML de Sonarr
│   ├── radarr/                   # Config XML de Radarr
│   ├── prowlarr/                 # Config XML de Prowlarr
│   └── bazarr/                   # Config YAML de Bazarr (API keys, providers, etc.)
├── data/                         # Datos multimedia
│   ├── tv/                       # Librería de series
│   ├── movies/                   # Librería de películas
│   ├── downloads/                # Descargas (complete/ e incomplete/)
│   └── torrents/                 # Archivos torrent
├── transcode/                    # Caché de transcodificación de Plex
├── setup.sh                      # Script de inicialización
├── start-all.sh                  # Arrancar stack completo
├── start-plex-only.sh            # Arrancar solo Plex
├── start-services.sh             # Arrancar servicios de descarga
├── stop-services.sh              # Detener servicios de descarga
├── watch-downloads.sh            # Monitorear descargas en tiempo real
├── docker-compose.yml            # Orquestación de contenedores
└── log.txt                       # ⚠ INTRUSO: log de Ventoy, no pertenece aquí
```

---

## 4. Flujo de datos (arquitectura)

```
[Indexers externos] ←→ [Prowlarr] ←→ [Flaresolverr]
                          |
              [Sonarr / Radarr]  ←→  [Bazarr]
                    |                    |
                    v                    v
            [Transmission]         [Subtítulos]
                    |
                    v
           [/downloads/]
                    |
                    v
      [Sonarr/Radarr importan a /data/tv, /data/movies]
                    |
                    v
              [Plex indexa y streamea]
```

1. **Prowlarr** agrega indexers de torrents y los expone a Sonarr/Radarr.
2. **Flaresolverr** resuelve challenges de Cloudflare que algunos indexers imponen.
3. **Sonarr/Radarr** buscan contenido faltante o monitorean lanzamientos.
4. Cuando encuentran un match, envían la descarga a **Transmission**.
5. Transmission descarga en `/downloads/incomplete` y mueve a `/downloads/complete`.
6. Sonarr/Radarr importan el archivo a la biblioteca organizada.
7. **Bazarr** descarga subtítulos para el contenido importado.
8. **Plex** escanea las bibliotecas y las sirve a los clientes.

---

## 5. Uso

### 5.1 Configuración inicial

```bash
# 1. Clonar (si aplica) o simplemente estar en el directorio
# 2. Obtener un PLEX_CLAIM válido desde https://plex.tv/claim
#    - Abrir el enlace en un navegador (sesión iniciada en Plex)
#    - El sitio genera un token tipo "claim-xxxxxxxx"
#    - Copiarlo al .env:  PLEX_CLAIM=claim-xxxxxxxx
#    - El token expira a los 4 minutos; si vence, generar uno nuevo
# 3. Editar .env con tu PLEX_CLAIM válido
# 4. Ejecutar setup (crea directorios y asigna permisos)
./setup.sh

# 5. Iniciar todo el stack
./start-all.sh
```

### 5.2 Scripts disponibles

| Script | Acción |
|--------|--------|
| `setup.sh` | Crea estructura de directorios, asigna PUID/PGID |
| `start-all.sh` | Arranca todos los servicios |
| `start-plex-only.sh` | Arranca solo Plex (ahorra recursos) |
| `start-services.sh` | Arranca solo servicios de descarga |
| `stop-services.sh` | Detiene servicios de descarga (Plex sigue) |
| `watch-downloads.sh` | `tail -f` sobre logs de Sonarr/Radarr filtrados |

### 5.3 URLs de servicios

| Servicio | URL |
|----------|-----|
| Plex | `http://<host>:32400/web` |
| Transmission | `http://<host>:9091` |
| Sonarr | `http://<host>:8989` |
| Radarr | `http://<host>:7878` |
| Prowlarr | `http://<host>:9696` |
| Bazarr | `http://<host>:6767` |
| Flaresolverr | `http://<host>:8191/v1` |

---

## 6. Estado actual del stack (junio 2026)

- **Plex**: Configurado con nombre "Plex-Stefanov", usuario `alanstefanov`, conectado a Plex Online.
- **Transmission**: 111 GB descargados, ~220 MB subidos, 13 torrents encolados, 6 descargas activas.
- **Biblioteca TV**: "El Encargado" (temporadas 2-4, idioma español).
- **Biblioteca Películas**: "Crime 101 (2026)" [2160p 4K WEB].
- **Sonarr/Radarr**: Configurados con `LogLevel=debug` y `AuthenticationMethod=None`.
- **Bazarr**: 26 proveedores de subtítulos configurados, Google Translate + Gemini como traductores, WhisperAI local para generación por IA.

---

## 7. 🔴 CRÍTICAS Y OBSERVACIONES OBLIGATORIAS

### 7.1 🔴 SEGURIDAD — MÚLTIPLES FALLOS GRAVES

| # | Problema | Severidad | Archivo |
|---|----------|-----------|---------|
| 1 | **API keys en texto plano en el repositorio** — Sonarr, Radarr, Prowlarr, Bazarr exponen sus claves API sin restricción. Cualquiera con acceso al repositorio puede controlar estos servicios. | **CRÍTICA** | `config/sonarr/config.xml`, `config/radarr/config.xml`, `config/prowlarr/config.xml`, `config/bazarr/config/config.yaml` |
| 2 | **PLEX_CLAIM en .env** — Token de claim almacenado y commitido (o al menos presente en disco). Si este repositorio se publica, cualquiera puede reclamar el servidor. | **CRÍTICA** | `.env` |
| 3 | **Sin autenticación en ningún servicio** — `AuthenticationMethod=None` en Sonarr, Radarr, Prowlarr. Transmission sin RPC auth. Cero barreras de entrada. | **ALTA** | `config/sonarr/config.xml`, `config/radarr/config.xml`, `config/prowlarr/config.xml`, `config/transmission/settings.json` |
| 4 | **Secretos de Bazarr expuestos** — La API key de Bazarr, la config de Gemini, el endpoint de WhisperAI están en texto plano. | **ALTA** | `config/bazarr/config/config.yaml` |
| 5 | **Red host para Plex** — `network_mode: host` elimina el aislamiento de red del contenedor. Plex tiene acceso completo a la red del host. | **MEDIA** | `docker-compose.yml` |
| 6 | **Sin .gitignore** — Si esto se trackea con git, `.env` y todo `config/` se subirán al repositorio remoto. Esto ya ocurrió. | **CRÍTICA** | Repositorio raíz |

**Solución recomendada:**
- Mover todos los secretos a variables de entorno.
- Agregar `AuthenticationMethod=External` o `Forms` en Sonarr/Radarr/Prowlarr.
- Configurar contraseña RPC en Transmission.
- Eliminar `config/` del control de versiones y usar volúmenes Docker exclusivamente.
- Crear `.gitignore` que excluya `.env`, `config/`, `data/`, `transcode/`.
- Rotar todas las API keys expuestas inmediatamente.

### 7.2 🟡 INFRAESTRUCTURA — FALENCIAS TÉCNICAS

| # | Problema | Impacto |
|---|----------|---------|
| 1 | **Imágenes sin pin de versión** — Todas usan `:latest`. Una actualización rompedora puede dejar el stack inoperativo. | **ALTO** |
| 2 | **Sin healthchecks** — Docker Compose no verifica que los servicios estén realmente operativos. | **MEDIO** |
| 3 | **Sin límites de recursos** — Ningún contenedor define `mem_limit`, `cpus`, `ulimits`. Un servicio puede consumir todo el host. | **MEDIO** |
| 4 | **Sin redes definidas** — Todos los servicios están en la red por defecto de Compose sin segmentación. | **BAJO** |
| 5 | **Sin política de backups** — No hay scripts, cronjobs ni estrategia para respaldar configuraciones y bases de datos. | **MEDIO** |
| 6 | **Sin monitoreo** — No hay alertas si un contenedor cae, un disco se llena o un servicio falla. | **MEDIO** |
| 7 | **Sin restricción de versiones de Docker Compose** — `docker-compose.yml` no especifica `version:` (obsoleto pero aún usado en guías). | **BAJO** |

### 7.3 🟡 MANTENIMIENTO Y CALIDAD DEL REPOSITORIO

| # | Problema |
|---|----------|
| 1 | **Sin control de versiones** — El directorio no tiene repositorio git inicializado. No hay historial, no hay rollback, no hay ramas. |
| 2 | **`log.txt` intruso** — Archivo `log.txt` en la raíz que pertenece a una herramienta Ventoy, no al stack. Contaminación del repositorio. |
| 3 | **Scripts frágiles** — `setup.sh`, `start-all.sh` etc. crean directorios cada vez que se ejecutan, pero no validan prerequisites (Docker installed? Docker Compose available?). |
| 4 | **Bazarr sobreconfigurado** — 26 proveedores de subtítulos, la mayoría sin credenciales. Van a fallar silenciosamente. |
| 5 | **Puertos mapeados innecesarios** — `transmission` expone `51413` en TCP y UDP. ¿Es necesario o es duplicación? |
| 6 | **Sin documentación de mantenimiento** — No hay instrucciones para actualizar servicios, migrar configuraciones, o recuperarse de fallos. |
| 7 | **Sin pruebas** — Cero scripts de validación. No hay forma de verificar que el stack funcione después de un cambio. |

---

## 8. Recomendaciones técnicas obligatorias

### 8.1 Inmediatas (antes del próximo deploy)

- [ ] Crear `.gitignore` con: `.env`, `config/`, `data/`, `transcode/`, `log.txt`
- [ ] Inicializar repositorio git
- [ ] Rotar todas las API keys de Sonarr, Radarr, Prowlarr, Bazarr
- [ ] Regenerar el PLEX_CLAIM (el actual expira tras el primer uso)
- [ ] Configurar autenticación en Sonarr, Radarr, Prowlarr, Transmission
- [ ] Eliminar `log.txt`
- [ ] Agregar `mem_limit: 2g` o similar a cada servicio

### 8.2 Corto plazo

- [ ] Pinear versiones de imágenes (`lscr.io/linuxserver/sonarr:4.0.13`, no `:latest`)
- [ ] Agregar healthchecks personalizados en `docker-compose.yml`
- [ ] Definir redes separadas: `frontend` (Plex) y `backend` (servicios de descarga)
- [ ] Configurar cron para backups de `config/` y `data/` (bases de datos de Sonarr/Radarr/Plex)
- [ ] Documentar procedimiento de actualización

### 8.3 Mediano plazo

- [ ] Migrar a Docker Compose con variables de entorno para todos los secretos
- [ ] Implementar monitoreo (Uptime Kuma, Prometheus + node_exporter, o similar)
- [ ] Agregar alertas de espacio en disco
- [ ] Evaluar si Transmission es el cliente correcto o si qBittorrent ofrece mejores prestaciones
- [ ] Agregar VPN obligatoria para Transmission (wireguard, gluetun)
- [ ] Migrar Plex a `network_mode: bridge` con mapeo explícito de puertos si DLNA no es necesario

---

## 9. Contribuciones

Este es un proyecto colaborativo. Las contribuciones son bienvenidas.

### Lineamientos

- **No incluir configuraciones locales ni secretos** — `config/` y `.env` están en `.gitignore`.
- **Los PRs deben ser revisados antes de mergear.**
- **Mantener el mismo nivel de rigor** — toda nueva feature debe documentarse, todo cambio debe ser revisable.
- **Probar localmente antes de abrir un PR.**

### Cómo contribuir

1. Fork el repositorio.
2. Crear una rama con nombre descriptivo (`feature/...`, `fix/...`).
3. Hacer los cambios.
4. Abrir un Pull Request describiendo qué se cambió y por qué.

---

## 10. Licencia

**GPL-3.0** — Este repositorio está licenciado bajo GNU General Public License v3.0.

El código de terceros (imágenes Docker) pertenece a sus respectivos autores y está sujeto a sus propias licencias:
- **Sonarr, Radarr, Prowlarr, Bazarr, Transmission**: GPL-3.0
- **Flaresolverr**: MIT
- **Plex Media Server**: Propietaria

---

## 11. Disclaimer

Este stack está diseñado para uso personal en un entorno controlado. La exposición pública de estos servicios sin autenticación, sin HTTPS, y con secretos en texto plano **no es segura** bajo ningún estándar profesional. Todo uso es bajo responsabilidad del operador.
