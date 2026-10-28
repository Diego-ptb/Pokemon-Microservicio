# syntax=docker/dockerfile:1.7
# =====================================================================
# Dockerfile multi-stage para pokemon-service (Spring Boot 3 / Java 21)
#
#  Etapa 1 (build):   compila el JAR con Maven + JDK completo
#  Etapa 2 (extract): separa el JAR en capas (dependencias / app)
#  Etapa 3 (runtime): solo JRE Alpine + capas, usuario sin privilegios
#
# Resultado: imagen final ~200 MB en vez de ~800 MB con JDK + Maven,
# sin código fuente ni herramientas de compilación dentro.
# =====================================================================

# ---------- Etapa 1: compilación ----------
FROM maven:3.9-eclipse-temurin-26 AS build
WORKDIR /workspace

# Primero solo el pom.xml: si no cambian las dependencias, Docker reutiliza
# esta capa y no vuelve a descargarlas en cada build.
COPY pom.xml .
RUN --mount=type=cache,target=/root/.m2 \
    mvn -B -q dependency:go-offline

COPY src ./src
# Las pruebas se ejecutan en un job dedicado del pipeline (con reporte de
# cobertura); aquí solo se empaqueta para no duplicar tiempo de build.
RUN --mount=type=cache,target=/root/.m2 \
    mvn -B -q package -DskipTests \
 && cp target/*.jar application.jar

# ---------- Etapa 2: extracción en capas ----------
FROM eclipse-temurin:21-jre-alpine AS extract
WORKDIR /builder
COPY --from=build /workspace/application.jar application.jar
# Spring Boot separa librerías (cambian poco) del código propio (cambia
# en cada commit) para que las capas grandes se reutilicen entre versiones.
RUN java -Djarmode=tools -jar application.jar extract --layers --destination extracted

# ---------- Etapa 3: imagen final de ejecución ----------
FROM eclipse-temurin:21-jre-alpine AS runtime

# Metadatos de trazabilidad (los completa el pipeline con --build-arg)
ARG GIT_COMMIT=unknown
ARG APP_VERSION=local
ARG BUILD_DATE=unknown
LABEL org.opencontainers.image.title="pokemon-service" \
      org.opencontainers.image.description="Microservicio CRUD de Pokémon (Spring Boot)" \
      org.opencontainers.image.revision="${GIT_COMMIT}" \
      org.opencontainers.image.version="${APP_VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}"

# Aplica los parches de seguridad publicados para los paquetes del sistema
# base (Alpine) desde que se construyó la imagen eclipse-temurin.
# Usuario sin privilegios (UID fijo, sin shell de login)
# hadolint ignore=DL3017
RUN apk upgrade --no-cache \
 && addgroup -S -g 10001 spring \
 && adduser -S -D -H -u 10001 -G spring -s /sbin/nologin spring

WORKDIR /application
COPY --from=extract --chown=spring:spring /builder/extracted/dependencies/ ./
COPY --from=extract --chown=spring:spring /builder/extracted/spring-boot-loader/ ./
COPY --from=extract --chown=spring:spring /builder/extracted/snapshot-dependencies/ ./
COPY --from=extract --chown=spring:spring /builder/extracted/application/ ./

USER spring:spring

# GIT_COMMIT / APP_VERSION: Spring Boot los expone en /actuator/info (qué versión corre).
# JAVA_TOOL_OPTIONS: la JVM usa como máximo el 75% de la memoria límite del
# contenedor y termina limpiamente ante un OutOfMemory (el orquestador la reinicia).
ENV GIT_COMMIT=${GIT_COMMIT} \
    APP_VERSION=${APP_VERSION} \
    SERVER_PORT=8080 \
    JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75.0 -XX:InitialRAMPercentage=50.0 -XX:+ExitOnOutOfMemoryError -Djava.security.egd=file:/dev/./urandom"

EXPOSE 8080

# Docker marca el contenedor como unhealthy si la app deja de responder
HEALTHCHECK --interval=15s --timeout=5s --start-period=60s --retries=5 \
    CMD wget -q -O /dev/null http://127.0.0.1:8080/actuator/health/liveness || exit 1

ENTRYPOINT ["java", "-jar", "application.jar"]
