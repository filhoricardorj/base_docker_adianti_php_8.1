FROM debian:11

ENV DEBIAN_FRONTEND noninteractive
ENV TIMEZONE America/Sao_Paulo

RUN apt update
RUN apt upgrade -y
RUN apt -y install locate mlocate wget apt-utils curl apt-transport-https lsb-release \
    ca-certificates software-properties-common zip unzip vim rpl

# Fix ‘add-apt-repository command not found’
RUN apt install software-properties-common

RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

RUN ln -fs /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && apt update \
    && apt install -y --no-install-recommends tzdata \
    && dpkg-reconfigure --frontend noninteractive tzdata

RUN apt -y install apache2 libapache2-mod-php8.1 php8.1 php8.1-cli php8.1-common php8.1-opcache


RUN apt -y install curl git-core php8.1-curl php8.1-dom php8.1-xml php8.1-zip \
    php8.1-soap php8.1-intl php8.1-xsl php8.1-mbstring php8.1-gd php8.1-pdo \
    php8.1-pdo-sqlite php8.1-sqlite3 php8.1-pdo php8.1-mysql

RUN a2dismod mpm_event mpm_worker

RUN a2enmod mpm_prefork rewrite php8.1 authnz_ldap ldap ssl

RUN a2ensite default-ssl

RUN LANG="en_US.UTF-8" rpl "AllowOverride None" "AllowOverride All" /etc/apache2/apache2.conf

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


## PHPUnit ## DESCOMENTAR AS LINHAS ABAIXO PARA INSTALAR
# RUN wget -O /usr/local/bin/phpunit-9.phar https://phar.phpunit.de/phpunit-9.phar; chmod +x /usr/local/bin/phpunit-9.phar; \
# ln -s /usr/local/bin/phpunit-9.phar /usr/local/bin/phpunit

## Xdebug ## DESCOMENTAR AS LINHAS ABAIXO PARA INSTALAR
RUN apt -y install php8.1-xdebug
RUN echo "xdebug.mode=debug,dev" >> /etc/php/8.1/mods-available/xdebug.ini
RUN echo "xdebug.discover_client_host=0" >> /etc/php/8.1/mods-available/xdebug.ini
RUN echo "xdebug.client_host=host.docker.internal" >> /etc/php/8.1/mods-available/xdebug.ini
RUN echo "xdebug.idekey=XDEBUG" >> /etc/php/8.1/mods-available/xdebug.ini


RUN apt clean && updatedb

RUN chmod 777 /var/lib/php/sessions

EXPOSE 80

CMD apache2ctl -D FOREGROUND
