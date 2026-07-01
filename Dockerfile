FROM python:3.12-slim


WORKDIR /app

COPY /FinalProject/requirements.txt .

RUN pip install -r requirements.txt


COPY /FinalProject/. .

EXPOSE 3500

CMD ["python", "app.py"]

