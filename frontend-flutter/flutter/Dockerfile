FROM nginx:1.23.4

COPY nginx/local.conf /etc/nginx/conf.d/local.conf

# Install Flutter only for web
RUN mkdir /flutter
WORKDIR /flutter
RUN  apt-get update \
  && apt-get install -y wget tar xz-utils git \
  && rm -rf /var/lib/apt/lists/*
RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.7.12-stable.tar.xz
RUN tar -xf ./flutter_linux_3.7.12-stable.tar.xz
ENV PATH="$PATH:/flutter/flutter/bin"
RUN git config --global --add safe.directory /flutter/flutter
RUN flutter precache

RUN mkdir /app
WORKDIR /app
ADD . /app/

ENTRYPOINT [ "/app/entrypoint.sh" ]