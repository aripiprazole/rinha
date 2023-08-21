FROM alpine:latest

RUN apk update \
  && apk upgrade \
  && apk add --no-cache \
    clang \
    clang-dev \
    alpine-sdk \
    dpkg \
    cmake \
    ccache \
    python3

RUN ln -sf /usr/bin/clang /usr/bin/cc \
  && ln -sf /usr/bin/clang++ /usr/bin/c++ \
  && update-alternatives --install /usr/bin/cc cc /usr/bin/clang 10\
  && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 10\
  && update-alternatives --auto cc \
  && update-alternatives --auto c++ \
  && update-alternatives --display cc \
  && update-alternatives --display c++ \
  && ls -l /usr/bin/cc /usr/bin/c++ \
  && cc --version \
  && c++ --version

WORKDIR /code

COPY ./entrypoint.sh /code/entrypoint.sh
COPY ./elan-init.sh /code/elan-init.sh

RUN sh /code/elan-init.sh -y \
  && ~/.elan/bin/elan default leanprover/lean4:nightly
  && ~/.elan/bin/lake update
  && ~/.elan/bin/lake build

COPY build/bin/rinha /code/rinha

ENTRYPOINT ["/code/entrypoint.sh"]
