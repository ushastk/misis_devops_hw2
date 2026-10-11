# Образ приложения в один этап — отправная точка домашнего задания.
# <базовый образ> заменить базовым образом своего варианта.
# В таком виде сборка падает: драйверы баз компилируются из исходников,
# а компилятора и заголовков в образе нет. Задание — переписать файл в два этапа
FROM python:3.12-alpine AS build

RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    mariadb-connector-c-dev \
    pkgconf

WORKDIR /app
COPY requirements.txt .

RUN python -m venv /venv
RUN /venv/bin/pip install --no-cache-dir -r requirements.txt


FROM python:3.12-alpine

RUN apk add --no-cache \
    libpq \
    mariadb-connector-c

WORKDIR /app

COPY --from=build /venv /venv
COPY app.py .

ENV PATH="/venv/bin:$PATH"
ENV PYTHONDONTWRITEBYTECODE=1

ARG VERSION=5.0
RUN echo "$VERSION" > /app/VERSION

STOPSIGNAL SIGINT
CMD ["python", "app.py"]
