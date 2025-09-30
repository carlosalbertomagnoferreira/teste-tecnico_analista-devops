FROM nginx:1.29.1-alpine3.22-slim
COPY ./docker/nginx/nginx.conf /etc/nginx/nginx.conf
WORKDIR /var/www/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]