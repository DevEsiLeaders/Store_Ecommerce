# Étape 1 : Compilation de l'application
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app

# Copie du fichier pom.xml
COPY pom.xml .

# Copie du code source
COPY src /app/src

# Compilation et packaging de l'application sans exécuter les tests
RUN mvn clean package -DskipTests

# Étape 2 : Exécution de l'application
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copie du JAR généré depuis l'étape builder
COPY --from=builder /app/target/Ecommerce_Store-*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]