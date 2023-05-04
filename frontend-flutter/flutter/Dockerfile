FROM nginx:1.23.4

COPY nginx/local.conf /etc/nginx/conf.d/local.conf

RUN mkdir /app/
WORKDIR /app/
ADD web /usr/share/nginx/html/