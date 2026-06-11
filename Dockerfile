# ─────────────────────────────────────────────────────────────────
# STAGE 1: BUILD STAGE
# Uses the full JDK Alpine image to build the JAR inside Docker
# itself, so the final image doesn't need Gradle or JDK at all.
# ─────────────────────────────────────────────────────────────────
FROM eclipse-temurin:21-jdk-alpine AS builder

# set working directory inside the container
WORKDIR /app

COPY . .
# copy entire project into the container
# build the fat JAR, --no-daemon avoids background Gradle process
RUN chmod +x ./gradlew && \
    ./gradlew bootJar --no-daemon

# ─────────────────────────────────────────────────────────────────
# STAGE 2: RUNTIME STAGE
# Uses a lightweight JRE (not full JDK) to just run the JAR.
# This keeps the final image as small as possible.
# ─────────────────────────────────────────────────────────────────
FROM eclipse-temurin:21-jre-alpine
# set working directory inside the container
WORKDIR /app
# copy only the built JAR from the builder stage
COPY --from=builder /app/build/libs/*.jar app.jar
# document that the app runs on port 8080
EXPOSE 8080
# command to run when the container starts
ENTRYPOINT ["java", "-jar", "app.jar"]