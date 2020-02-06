FROM python:3-alpine

MAINTAINER Angel Cabrera <diablinux@gmail.com>

WORKDIR /service
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY hello/hello.py ./

EXPOSE 5000
ENTRYPOINT ["python3", "hello.py"]
