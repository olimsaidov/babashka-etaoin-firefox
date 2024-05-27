FROM babashka/babashka:1.3.190-alpine as deps

RUN apk add --no-cache openjdk21-jdk

RUN echo "{:deps {etaoin/etaoin {:mvn/version \"1.0.40\"}}}" > bb.edn && \
    bb uberjar deps.jar


FROM babashka/babashka:1.3.190-alpine


RUN apk add --no-cache firefox
RUN apk add --no-cache --virtual .build-deps wget \
    && GECKODRIVER_VERSION=v0.34.0 \
    && wget -qO /tmp/geckodriver.tar.gz "https://github.com/mozilla/geckodriver/releases/download/$GECKODRIVER_VERSION/geckodriver-$GECKODRIVER_VERSION-linux64.tar.gz" \
    && tar -xzf /tmp/geckodriver.tar.gz -C /usr/local/bin/ \
    && rm /tmp/geckodriver.tar.gz \
    && apk del .build-deps

COPY --from=deps deps.jar /deps.jar

ENTRYPOINT ["bb", "-cp", "/deps.jar"]
