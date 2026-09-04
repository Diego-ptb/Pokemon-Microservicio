# Microservicio Pokémon

## 1. Descripción

Microservicio crud de pokemon

El repositorio forma parte de la Evaluación Parcial N°1 de la asignatura **Ingeniería DevOps**.

---

## 2. Integrantes

* Nombre: Diego Araya
* Nombre: Leonardo Mendez
* Nombre: Cristopher López

---

## 3. Tecnologías utilizadas

* Java
* Spring Boot
* Maven
* PostgreSQL / Supabase
* Git
* GitHub
* GitHub Actions
* Swagger / OpenAPI

---

# 4. Estrategia de branching

Para el desarrollo colaborativo se utilizamos GitFlow, este nos permitio colaborar en distintas ramas. mientras unos subian el codigo base, el otro desarrollaba otra funcionalidad.
Se eligió GitFlow en lugar de Trunk-Based Development debido a que el proyecto requiere una separación clara entre el código estable y el código en desarrollo,

La estructura utilizada será:

main
│
└── develop
    ├── feature/getbyname
    ├── feature/deletebyname
    └── hotfix/errordeprueba
    └── hotfix/endpoints-duplicados


### Ramas principales

#### `main`

Contiene la versión base y ejecutable del proyecto.

Los cambios hacia main se realizan mediante Pull Requests desde la rama develop y deben ser revisados (github tiene un compilador para probar que no haya conflicto de codigo) antes de realizar el merge.

#### `develop`

Contiene la versión de desarrollo donde se integran las nuevas funcionalidades desde las ramas features mediane pull request

#### `feature/nombrefuncionalidad`

Se utiliza para desarrollar nuevas funcionalidades.

Ejemplos:
feature/gebyname
feature/deletebyname
feaure/swagger


Una vez terminada la funcionalidad, se crea un Pull Request hacia la rama develop.

#### `hotfix/<nombre>`

Se utiliza para solucionar errores criticos de manera rapida y se integra mediante pull request a la rama correspondiente.
Generalmente se integra en varias ramas para corregir el error, por ejemplo primero se hace el pullrequest al feature y luego al develop.

Ejemplos:
hotfix/errortipeo
hotfix/errorversion
hotfix/errorcodigoduplicado


Los cambios del hotfix deben ser revisados mediante Pull Request antes de integrarse a la rama correspondiente.

---

# 5. Convención de nombres de ramas

Se utilizará la siguiente nomenclatura:

feature/<funcionalidad>
hotfix/<error>


Los nombres deben:

* Estar escritos en minúsculas.
* Utilizar palabras descriptivas.
* Separar palabras mediante `-`.
* Indicar claramente el objetivo del cambio.

Ejemplos:

feature/create-pokemon
feature/delete-pokemon
hotfix/errorcontroller
hotfix/fix-delete-mapping


---

# 6. Convención de commits

Se utilizará una convención basada en Conventional Commits.

Formato:

tipo: descripción

Tipos principales:

  feat      Nueva funcionalidad                
  fix       Corrección de errores              


Ejemplos:

feat: agregar endpoint para eliminar pokemon

fix: corregir mapping de delete por nombre



Los mensajes de commit deben ser claros, breves y describir el cambio realizado.

---

# 7. Flujo de trabajo

El flujo de trabajo definido para el proyecto será:


feature/<funcionalidad>
       ↓
     develop
       ↓
      main


Para desarrollar una nueva funcionalidad:

1. Crear una rama feature/<funcionaliadad> desde develop.
2. Realizar los cambios necesarios.
3. Crear commits descriptivos.
4. Realizar `push` de la rama a GitHub.
5. Crear un Pull Request hacia `develop`.
6. Realizar la revisión del código.
7. Corregir las observaciones realizadas durante la revisión.
8. Aprobar el Pull Request.
9. Realizar el merge hacia `develop`.

Para una corrección urgente:


hotfix/<error>
       ↓
     develop


El hotfix debe ser revisado mediante Pull Request antes de integrarse.

---

# 8. Pull Requests

Todos los cambios realizados mediante ramas `feature` y `hotfix` deben integrarse utilizando Pull Requests.

Cada Pull Request debe contener:

* Título descriptivo.
* Descripción del cambio realizado.
* Rama de origen.
* Rama de destino.
* Revisión por otro integrante del equipo.

No se deben realizar cambios directamente sobre `main`.

---

# 9. Estrategia de revisión

La revisión de código se realizará mediante **Pull Requests de GitHub**.

El integrante que no desarrolló directamente el cambio deberá revisar el Pull Request.

Durante la revisión se verificará:

* Funcionamiento del código.
* Cumplimiento de las convenciones de commits.
* Correcta nomenclatura de ramas.
* Calidad y legibilidad del código.
* Ausencia de errores evidentes.
* Correcta implementación de la funcionalidad.

Si existen observaciones, estas deberán ser corregidas antes de realizar el merge.

---

# 10. GitHub Actions

El proyecto utiliza GitHub Actions, por el momento solo es un print cuando se ejecuta un commit hacia la rama develop o un pull request hacia develop y main

El objetivo es verificar automáticamente que el proyecto pueda compilar correctamente y detectar errores antes de integrar cambios a la rama principal.

Archivo utilizado:

archivo ci.yml 


Flujo:


Push a develop
       ↓
GitHub Actions
       ↓
Build / Tests
       ↓
Resultado de CI


Además, los Pull Requests hacia `main` ejecutan la misma validación para evitar integrar cambios que presenten errores.

---

# 11. Estructura del repositorio


.
├── .github/
│   └── workflows/
│       └── ci.yml
├── src/
├── pom.xml
├── README.md
└── ...


---

# 12. Ejecución del proyecto

Para ejecutar el proyecto localmente se requiere:

* Java instalado.
* Maven.
* Acceso a la base de datos configurada.

Clonar el repositorio:

```bash
git clone <URL_DEL_REPOSITORIO>
```

Ingresar al proyecto:

```bash
cd <NOMBRE_DEL_REPOSITORIO>
```

Ejecutar:

```bash
./mvnw spring-boot:run
```

En Windows también puede utilizarse:

```bash
mvnw.cmd spring-boot:run
```

---

# 13. API

La API permite realizar operaciones CRUD sobre Pokémon.

Principales endpoints:


GET     /api/pokemons
GET     /api/pokemons/{id}
GET     /api/pokemons/name/{name}
POST    /api/pokemons
PUT     /api/pokemons/{id}
DELETE  /api/pokemons/{id}
DELETE  /api/pokemons/name/{name}


La documentación de la API puede ser consultada mediante Swagger/OpenAPI.

---

# 14. Objetivo DevOps

El objetivo del repositorio es establecer una base de trabajo colaborativa que permita integrar:

* Control de versiones mediante Git.
* Colaboración mediante GitHub.
* Estrategias de branching.
* Pull Requests y revisión de código.
* Automatización mediante GitHub Actions.
* Integración continua (CI).

Este flujo permitirá posteriormente incorporar nuevas etapas de automatización y despliegue durante el desarrollo del proyecto.
