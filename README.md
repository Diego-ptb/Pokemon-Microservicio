# Pokemon Service

Este proyecto es un microservicio REST en Spring Boot para gestionar Pokémon con PostgreSQL en Supabase.

## Requisitos

- Java 21
- Maven 3.8+
- Una base de datos PostgreSQL en Supabase

## 1) Configurar las variables de entorno

En la raíz del proyecto crea un archivo llamado `.env` con este contenido:

```env
DB_URL=jdbc:postgresql://aws-0-us-east-1.pooler.supabase.com:6543/postgres?sslmode=require
DB_USERNAME=postgres.wgckznwgamfiadgtvyds
DB_PASSWORD=TU_PASSWORD_REAL
DB_DRIVER=org.postgresql.Driver
SERVER_PORT=8081
```

Importante:
- reemplaza `TU_PASSWORD_REAL` por la contraseña real de la base de datos de Supabase
- no subas el `.env` a Git
- si quieres cambiar de puerto, modifica `SERVER_PORT`

## 2) Configurar Spring Boot para leer el .env

En `src/main/resources/application.yml` ya está configurado así:

```yaml
spring:
  config:
    import: optional:file:.env[.properties]
```

Y el puerto se lee desde la variable:

```yaml
server:
  port: ${SERVER_PORT:8080}
```

## 3) Crear la tabla en Supabase

Abre Supabase ? SQL Editor y ejecuta el contenido de `schema.sql`.

Si la tabla aún no existe, Spring puede crearla con Hibernate, pero lo recomendado es ejecutar el script para tener los datos iniciales y la estructura correcta.

## 4) Ejecutar el proyecto

Desde la raíz del proyecto:

```bash
mvn spring-boot:run
```

Si deseas arrancarlo con un puerto específico desde terminal en Windows PowerShell:

```powershell
$env:SERVER_PORT = 8081
mvn spring-boot:run
```

## 5) Verificar que arranca bien

Cuando termine el arranque, deberías ver algo similar a esto en la consola:

- `Tomcat initialized with port 8081`
- `Started PokemonServiceApplication`

## 6) Abrir Swagger

Con el proyecto levantado, entra aquí:

```text
http://localhost:8081/swagger-ui.html
```

O si usas el puerto por defecto:

```text
http://localhost:8080/swagger-ui.html
```

## 7) Endpoints principales

La base de la API suele quedar así:

```text
http://localhost:8081/api/pokemons
```

Endpoints típicos:

- `GET /api/pokemons`
- `GET /api/pokemons/{id}`
- `POST /api/pokemons`
- `PUT /api/pokemons/{id}`
- `DELETE /api/pokemons/{id}`

## Solución de problemas

### Error: port already in use

Si aparece:

```text
Web server failed to start. Port 8081 was already in use.
```

Haz una de estas dos cosas:

1. mata el proceso que ocupa ese puerto, o
2. cambia `SERVER_PORT` en el `.env` a otro valor, por ejemplo 8082

### Error: no se conecta a la base de datos

Revisa:

- que la contraseña en `.env` sea la correcta
- que el host sea el pooler de Supabase
- que el usuario sea `postgres.wgckznwgamfiadgtvyds`
- que la base sea `postgres`

### Error: missing table pokemon

Ejecuta de nuevo `schema.sql` en Supabase o deja Hibernate con `update` mientras pruebas:

```yaml
spring:
  jpa:
    hibernate:
      ddl-auto: update
```

## Resumen rápido

```bash
cd "C:/Users/Diego/Desktop/Microservicio/Microservicio de pokemon"
mvn spring-boot:run
```

Y luego abre:

```text
http://localhost:8081/swagger-ui.html
```

---

Proyecto listo para correr con Supabase y Swagger.
