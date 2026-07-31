FROM python:3.12-alpine

LABEL maintainer="Angel Cabrera <diablinux@gmail.com>"

ENV PYTHONDONTWRITEBYTECODE=1 \
	PYTHONUNBUFFERED=1

WORKDIR /service

RUN apk add --no-cache nginx

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY hello/ ./hello/
COPY docker/nginx/default.conf /etc/nginx/http.d/default.conf
COPY docker/start.sh /start.sh

RUN chmod +x /start.sh && mkdir -p /run/nginx

EXPOSE 5000
ENTRYPOINT ["/start.sh"]
