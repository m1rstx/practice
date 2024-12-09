FROM python:3.10

# optimize container size
ENV PYTHONDONTWTITEBYTECODE=1
# ensuring correct logging
ENV PYTHONUNBUFFERED=1

# make workdir a /app and copy all file inside
WORKDIR /app
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt
COPY . /app/

EXPOSE 8000

CMD [ "python3", "manage.py", "runserver", "0.0.0.0:8000" ]
