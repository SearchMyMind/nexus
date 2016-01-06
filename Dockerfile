FROM armbuild/dockerfile-java:oracle-java8
MAINTAINER Sébastien Brousse <sebastien.brousse@searchmymind.com>

ENV NEXUS_DATA /nexus-data
ENV NEXUS_VERSION 3.0.0-b2015110601

RUN mkdir -p /opt/sonatype/nexus \
    && curl --fail --silent --location --retry 3 \
      https://download.sonatype.com/nexus/oss/nexus-${NEXUS_VERSION}-bundle.tar.gz \
    | gunzip \
    | tar x -C /tmp nexus-${NEXUS_VERSION} \
    && mv /tmp/nexus-${NEXUS_VERSION}/* /opt/sonatype/nexus/ \
    && rm -rf /tmp/nexus-${NEXUS_VERSION}

RUN useradd -r -u 200 -m -c "nexus role account" -d ${NEXUS_DATA} -s /bin/false nexus

# configure nexus runtime env
RUN sed -e "s|KARAF_HOME}/instances|KARAF_DATA}/instances|" -i /opt/sonatype/nexus/bin/nexus


VOLUME ${NEXUS_DATA}

EXPOSE 8081
WORKDIR /opt/sonatype/nexus
USER nexus
ENV KARAF_BASE /opt/sonatype/nexus
ENV KARAF_DATA ${NEXUS_DATA}
ENV KARAF_ETC ${KARAF_BASE}/etc
ENV KARAF_HOME ${KARAF_BASE}

ENV CONTEXT_PATH /
ENV MAX_HEAP 768m
ENV MIN_HEAP 256m
ENV JAVA_OPTS -server -Djava.net.preferIPv4Stack=true
CMD bin/nexus start