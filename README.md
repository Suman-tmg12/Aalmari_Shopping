# Login Application

A simple login form built with:
- **Frontend:** JSP (JavaServer Pages) + HTML/CSS
- **Backend:** Java, Spring Boot 3.2.5, Spring MVC

## Features
- Login form (username + password) with validation
- Welcome page shown after a successful login
- Error message shown for invalid credentials
- Default credentials: `admin` / `admin123`

## Requirements
- Java 21 (JDK)
- No global Maven install needed (uses the included Maven wrapper)

## How to run
JSPs require running in development mode via the Spring Boot Maven plugin, so use:

```
mvnw.cmd spring-boot:run
```

(On Linux/macOS use `./mvnw spring-boot:run`)

Then open your browser at: http://localhost:8080

## Project structure
```
src/main/
├── java/com/example/login/
│   ├── LoginApplication.java     # Spring Boot main class
│   └── LoginController.java      # Handles GET / (login form) and POST /login
├── resources/
│   └── application.properties    # Port + JSP view resolver config
└── webapp/WEB-INF/views/
    ├── login.jsp                 # Login form page
    └── welcome.jsp               # Success page
```

## How it works
1. `GET /` renders the login form (`login.jsp`).
2. `POST /login` reads `username` and `password`.
3. The controller checks the credentials; valid logins render `welcome.jsp`,
   invalid ones re-render `login.jsp` with an error message.

> Note: JSPs do not run reliably from an executable uber-jar with embedded
> Tomcat, so this project is intended to be run with `spring-boot:run`.
