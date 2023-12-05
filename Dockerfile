# 빌드 스테이지
FROM eclipse-temurin:17 AS builder
LABEL authors="limvik"

WORKDIR workspace
ARG WAR_FILE=build/libs/jsp-docker-0.0.1-SNAPSHOT.war
COPY ${WAR_FILE} jsp-docker.war
RUN java -Djarmode=layertools -jar jsp-docker.war extract

# 실행 스테이지
FROM eclipse-temurin:17
RUN useradd limvik
USER limvik
WORKDIR workspace

# layertools로 추출된 레이어들 복사
COPY --from=builder workspace/dependencies/ ./
COPY --from=builder workspace/spring-boot-loader/ ./
COPY --from=builder workspace/snapshot-dependencies/ ./
COPY --from=builder --chown=limvik:limvik workspace/application/ ./

ENTRYPOINT ["java", "org.springframework.boot.loader.launch.WarLauncher"]