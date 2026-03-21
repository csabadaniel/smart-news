# Stage 1: Build
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /build

COPY pom.xml .
COPY mvnw .
COPY mvnw.cmd .
COPY .mvn .mvn

COPY src src

RUN ./mvnw clean package -DskipTests

# Stage 2: Runtime
FROM gcr.io/distroless/java21-debian12:nonroot

WORKDIR /app

COPY --from=builder /build/target/smart-news-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080

ENV PORT=8080

ENTRYPOINT ["java", "-jar", "app.jar"]
CMD ["--server.port=${PORT}"]
