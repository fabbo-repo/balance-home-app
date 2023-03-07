FROM nginx:1.23.3

COPY nginx.conf /etc/nginx/nginx.conf
COPY app.nginx.conf /etc/nginx/sites-available/app.nginx.conf

RUN mkdir /etc/nginx/sites-enabled
RUN ln -s /etc/nginx/sites-available/app.nginx.conf /etc/nginx/sites-enabled/

CMD ["nginx", "-g", "daemon off;"]