FROM eclipse-temurin:17-jdk-jammy

WORKDIR /app


EXPOSE 8080

ENTRYPOINT ["java","-jar","app.jar"]

