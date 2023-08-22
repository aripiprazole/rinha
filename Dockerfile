FROM ubuntu:22.04

RUN apt-get update && apt-get install -y git curl libcurl4-openssl-dev build-essential pkg-config python3 python3-pip python3-venv libpq-dev clang  libgmp3-dev clang libc++-dev libc++abi-dev

ENV APP_HOME /app
ENV HOME /app

WORKDIR $APP_HOME

RUN curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s --  -y 
ENV PATH="${APP_HOME}/.elan/bin:${PATH}"

COPY ./entrypoint.sh /app/entrypoint.sh
COPY . /app

RUN cd /app 

ENV LEAN_CC "clang++"

RUN lake update
RUN lake build rinha

RUN cp build/bin/rinha /app/rinha

ENTRYPOINT ["/app/entrypoint.sh"]
