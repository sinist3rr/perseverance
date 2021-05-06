FROM python:3.6.12-alpine
WORKDIR /app
COPY requirements.txt /app/requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt
COPY . /app
EXPOSE 80
CMD ["gunicorn", "--chdir", "app", "--bind", "0.0.0.0:80","--timeout", "90", "main:app"]
