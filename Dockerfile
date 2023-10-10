FROM python:3.12-alpine

RUN apk add --no-cache ca-certificates && pip install s3cmd

COPY file/monitoring-s3.sh /app/monitoring-s3.sh

WORKDIR /app

CMD ["/bin/sh", "/app/monitoring-s3.sh"]