FROM alpine:latest

ENV CONFIG_PATH=config_production

#ENV NODE_VERSION=16.15
ENV NODE_VERSION=18.12.1


## Installing PACKAGES
#RUN apk add \
RUN apk --no-cache add \
                    nginx \
                    php8 \
                    php8-common \
                    php8-cli \
                    php8-fpm \
                    php8-iconv \
                    php8-pdo \
                    php8-pdo_mysql \
                    php8-pdo_sqlite \
                    php8-dom \
                    php8-gd \
                    php8-mbstring \
                    php8-xml \
                    php8-xmlwriter \
                    php8-simplexml \
                    php8-intl \
                    php8-curl \
                    php8-gmp \
                    php8-bcmath \
                    php8-pcntl \
                    php8-posix \
                    php8-zip \
                    php8-redis \
                    php8-phar \
                    php8-openssl \
                    php8-ctype \
                    php8-json \
                    php8-opcache \
                    php8-session \
                    php8-zlib \
                    php8-tokenizer \
                    php8-fileinfo \
                    wget \
                    unzip \
                    gcc \
                    bzip2 \
                    git \
                    openssl \
                    curl \
                    vim \
                    supervisor \
                    npm \
                    nodejs\ 
                    python3 \
                    python3-dev 


RUN npm install -g yarn node-gyp

# Create syslink so programs on php woluld know 
RUN ln -sf /usr/bin/php8 /usr/bin/php

# Make Direcotries
RUN mkdir -p /var/www/html

# Copy CONFIG files from LOCAL to Docker Image ( Container  )
####COPY config_production/supervisord.conf /etc/supervisord.conf
COPY ${CONFIG_PATH}/supervisord.conf /etc/supervisord.conf
COPY ${CONFIG_PATH}/nginx.conf /etc/nginx/nginx.conf 
COPY ${CONFIG_PATH}/fpm-pool.conf /etc/php8/php-fpm.d/www.conf
COPY ${CONFIG_PATH}/php.ini /etc/php8/conf.d/custom.ini



# Entrypoint
COPY --chown=nginx config_production/entrypoint.sh /entrypoint.sh 
RUN chmod +x /entrypoint.sh


# Set Permissions
RUN chown -R nginx /var/www/html && \
    chown -R nginx /run && \
    chown -R nginx /var/lib/nginx && \
    chown -R nginx /var/lib/nginx


# Switch to use non-root user for Nginx
# USER www-data  // this for Apache2 server
USER nginx


# Build the App
COPY --chown=nginx dashboard /var/www/dashboard
RUN npm --prefix /var/www/dashboard install
RUN npm --prefix /var/www/dashboard run build
RUN mv /var/www/dashboard/build/* /var/www/html


# Docker>Container's Nginx : 8443 -> Connect to -> OutSide Port 443 
EXPOSE 8080
EXPOSE 8443


# LAUNCH DOCKER from Entrypoint (.sh or .bash ) and to EXECUTE on Foreground
### CMD ["nginx", "-g" ,"daemon off;"]  <== this command line from supervisord.conf
ENTRYPOINT [ "/entrypoint.sh" ]
#CMD [ "/usr/bin/supervisord", "-n" ]
CMD [ "nginx", "-g" ,"daemon off;" ]






