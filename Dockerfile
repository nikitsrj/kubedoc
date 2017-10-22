FROM maven:3.5.0-jdk-8
RUN apt-get update -y && apt-get install mongodb-server -y
ADD . /App
WORKDIR /App
RUN mvn package -DskipTests
EXPOSE 8080
ENTRYPOINT service mongodb start && java -jar target/my-first-app-1.0-SNAPSHOT-fat.jar

