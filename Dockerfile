FROM proxy-docker.nexus-ein.com.intraMyProject/openjdk:21-slim

LABEL name="Microservices template"
LABEL description="MyProject Mediation Platform: Consume customer events from companyRef by eBus"
LABEL url="https://gitlab.tech.MyProject/cl-platform"

ARG PROJECT_NAME=mediationplatform-customer-consumer
ARG USER_NAME=mediationplatform
ENV PROJECT_DIR=/home/$PROJECT_NAME
ENV PROJECT=$PROJECT_NAME
ENV LOG_DIR=$PROJECT_DIR/files/logs
ENV TZ=Europe/Paris

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl libcurl4 tzdata && \
    groupadd -g 1002 0kogroup && \
    useradd -u 1002 -d $PROJECT_DIR -M -g 0kogroup -s /usr/sbin/nologin $USER_NAME && \
    mkdir -p $LOG_DIR && \
    chown -R $USER_NAME:0kogroup $LOG_DIR && \
    chmod -R 777 $LOG_DIR && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    rm -rf /var/lib/apt/lists/*


HEALTHCHECK --interval=5s --timeout=10s --retries=3 CMD curl -sS 127.0.0.1:8080 || exit 1

WORKDIR $PROJECT_DIR
COPY target/$PROJECT.jar $PROJECT.jar
USER $PROJECT_NAME

ENTRYPOINT ["sh", "-c", "exec java -Dlog4j2.formatMsgNoLookups=true -Djavax.net.debug=ssl -Djavax.net.ssl.trustStore=$PROJECT_DIR/common/truststore.jks -Djavax.net.ssl.trustStorePassword=customerlinksplatform -jar $(ls $PROJECT_DIR/*.jar | head -n 1)"]

EXPOSE 8080
