FROM ubuntu:22.04

RUN apt-get update && apt-get install -y git curl libcurl4-openssl-dev build-essential pkg-config python3 python3-pip python3-venv libpq-dev clang

ENV APP_HOME /app
ENV HOME /app

WORKDIR $APP_HOME

RUN curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s --  -y 
ENV PATH="${APP_HOME}/.elan/bin:${PATH}"

RUN apt-get -y install libpq5 libssl-dev libpq-dev  postgresql-client-common

COPY ./entrypoint.sh /app/entrypoint.sh
COPY . /app

RUN cd /app 
RUN lake update
RUN lake build rinha

COPY build/bin/rinha /app/rinha

ENTRYPOINT ["/app/entrypoint.sh"]
