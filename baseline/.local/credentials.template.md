# Local credentials — NEVER commit this file

Esta carpeta `.local/` está gitignored. Contiene credenciales vivas que
Claude (y vos) usan para operar el proyecto.

**Si alguna se expone, ROTAR inmediatamente antes de re-usar.**

---

## Production server (si aplica)

- **Host:** `[IP_O_DOMINIO]`
- **SSH Port:** `[PORT]`
- **User:** `[USER]`
- **Password / SSH Key path:** `[PASSWORD_O_PATH]`

### SSH command template

```bash
sshpass -p '[PASSWORD]' ssh -o StrictHostKeyChecking=no \
  -o ConnectTimeout=10 -o PreferredAuthentications=password \
  -o PubkeyAuthentication=no -p [PORT] [USER]@[HOST] "<COMMAND>"
```

> Adaptar a tu stack (key-based auth, jump host, bastion, etc.)

---

## Auth provider (Keycloak, Auth0, Cognito, etc.)

Realm: `[realm]` · Admin console: `[url]`

| Rol | Email / Username | Password / Token |
|-----|------------------|------------------|
| [Admin] | `[email]` | `[password]` |
| [Otro rol] | `[email]` | `[password]` |

---

## DB connection (si aplica)

- Host: `[host]`
- Port: `[port]`
- Database: `[db_name]`
- User: `[db_user]`
- Password: `[db_password]`

---

## URLs

- Portal: `[url]`
- Backend API: `[url]`
- Auth: `[url]`

---

## Cómo Claude lo usa

- Antes de operaciones SSH al server: leer este archivo y sustituir
  placeholders en los comandos del repo (`$HOST`, `$PASSWORD`, etc.) por
  los valores reales.
- Si las credenciales fallan: probablemente alguien las rotó. Pedir las
  nuevas al usuario y actualizar este archivo.
- NUNCA pegar los valores reales en commits ni en chat — sólo usarlos
  en línea de comandos efímeros.
