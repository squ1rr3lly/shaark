FROM php:7
MAINTAINER Shaark contributors <https://github.com/MarceauKa/shaark>

WORKDIR /app
COPY . /app

RUN apt-get update && \
    apt-get install -y gnupg wget && \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
    apt-get update && \
    apt-get install -y nodejs npm gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils libgmp-dev openssl zip unzip libonig-dev zlib1g-dev libpng-dev libzip-dev postgresql-server-dev-all google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
      --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

Run npm install puppeteer

RUN curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/bin/youtube-dl && \
    chmod a+rx /usr/bin/youtube-dl

RUN docker-php-ext-install gmp bcmath pdo mbstring gd exif zip sockets pdo_mysql pgsql pdo_pgsql sockets iconv

RUN cp .env.example .env

RUN composer install --no-dev -o

RUN php artisan optimize && \
    php artisan view:clear && \
    php artisan key:generate && \
    php artisan storage:link

ENV \
  DB_HOST="mariadb" \
  REDIS_HOST="redis" \
  APP_ENV="production" \
  APP_DEBUG="false" \
  APP_URL="http://localhost" \
  APP_MIGRATE_DB="true" \
  CACHE_DRIVER="redis" \
  QUEUE_CONNECTION="redis" \
  SESSION_DRIVER="redis" \
  REDIS_HOST="redis" 

ENTRYPOINT [ "/tini", "--", "./app/entrypoint-shaark.sh" ]
EXPOSE 80
