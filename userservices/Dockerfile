FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean install

FROM openjdk:17-alpine
WORKDIR /app
COPY --from=build /app/target/userservices-0.0.1-SNAPSHOT.jar ./qmm-backend.jar
EXPOSE 8443
CMD ["java", "-jar", "qmm-backend.jar"]