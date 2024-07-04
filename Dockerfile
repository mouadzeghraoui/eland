# syntax=docker/dockerfile:1
FROM python:3.10-slim

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y \
      build-essential \
      pkg-config \
      cmake \
      libzip-dev \
      libjpeg-dev

ADD . /eland
WORKDIR /eland

ARG TARGETPLATFORM

ENV MPLCONFIGDIR=/tmp/matplotlib-cache
RUN mkdir -p /tmp/matplotlib-cache && chmod 777 /tmp/matplotlib-cache

ENV TRANSFORMERS_CACHE=/tmp/transformers_cache
RUN mkdir -p /tmp/transformers_cache && chmod 777 /tmp/transformers_cache

RUN --mount=type=cache,target=/root/.cache/pip \
    if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
      python3 -m pip install \
        --no-cache-dir --disable-pip-version-check --extra-index-url https://download.pytorch.org/whl/cpu  \
        torch==1.13.1+cpu \
        .[all]; \
    else \
      python3 -m pip install \
        --no-cache-dir --disable-pip-version-check \
        torch==1.13.1 \
        .[all]; \
    fi

CMD ["/bin/sh"]