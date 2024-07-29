FROM python:3.9.9

RUN apt-get update && \
    apt-get install -y git

COPY run.sh .
COPY data.sh .
COPY . .

RUN chmod +x run.sh
CMD ["./run.sh"]
