FROM python:3.9.9

RUN apt-get update && \
    apt-get install -y git

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

COPY . .

RUN chmod +x run.sh
CMD ["./run.sh"]
