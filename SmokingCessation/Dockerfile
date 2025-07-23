# first (build) stage — run Maven on AMD64
FROM --platform=linux/amd64 maven:3.8.4-openjdk-17 AS build

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

# second (runtime) stage — again target AMD64
FROM --platform=linux/amd64 openjdk:17-jdk-slim

WORKDIR /app

COPY --from=build /app/target/smoking-cessation-0.0.1-SNAPSHOT.jar .

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/smoking-cessation-0.0.1-SNAPSHOT.jar"]