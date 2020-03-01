FROM debian:buster-slim AS odoo-base
MAINTAINER JoynalFrametOlimpo

ENV LANG C.UTF-8
ENV TZ=America/Guayaquil
ENV ODOO_VERSION 13.0
ENV ODOO_DEPTH 1

# Set Timezone
RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime

# Utility
RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            dirmngr \
            fonts-noto-cjk \
            git \
            gnupg \
            libssl-dev \
            node-less \
            npm \
            python3-babel \
            python3-decorator \
            python-docutils \
            python-feedparser \
            python3-gevent \
            python3-html2text \
            python3-jinja2 \
            python3-libsass \
            python3-mako \
            python3-mock \
            python3-num2words \
            python3-ofxparse \
            python3-passlib \
            python3-pip \
            python3-polib \
            python3-psutil \
            python3-pypdf2 \           
            python3-psycopg2 \
            python3-pydot \
            python3-pyparsing \
            python3-phonenumbers \
            python3-pyldap \
            python3-reportlab \
            python3-requests \
            python3-serial \
            python3-tz \
            python3-qrcode \
            python3-renderpm \
            python3-setuptools \
            python3-usb \
            python3-vatnumber \
            python3-werkzeug \
            python3-xlsxwriter \
            python3-vobject \
            python3-watchdog \
            python3-xlwt \
            xz-utils \
        && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb \
        && echo '7e35a63f9db14f93ec7feeb0fce76b30c08f2057 wkhtmltox.deb' | sha1sum -c - \
        && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# postgresql-client
RUN set -x; \
   apt-get update  \
&& apt-get install -y postgresql-client --no-install-recommends \
&& rm -rf /var/lib/apt/lists/*


# Install rtlcss
RUN set -x; \
    npm install -g rtlcss --no-install-recommends

# create user Odoo
RUN adduser --system --quiet --shell=/bin/bash --no-create-home --gecos 'ODOO' --group odoo

# Copy entrypoint script 
COPY ./entrypoint.sh /

# Create odoo directory 
RUN mkdir -p /opt/odoo/extra-addons \
    && mkdir -p /opt/odoo/data \
    && mkdir -p /opt/odoo/conf \
    && mkdir -p /opt/odoo/src \
    && chown -R odoo /opt/odoo

# Copy odoo configuration
COPY ./odoo.conf /opt/odoo/conf
RUN chown odoo /opt/odoo/conf/odoo.conf

# directory permission
RUN mkdir -p /var/lib/odoo \
    && chown -R odoo:odoo /var/lib/odoo

# Mount volumes
VOLUME ["/var/lib/odoo","/opt/odoo/data", "/opt/odoo/extra-addons", "/opt/odoo/src"]

# Install odoo requirement
ENV ODOO_SOURCE odoo/odoo

RUN set -x; \
         apt-get update \
         && pip3 install \
        -r https://raw.githubusercontent.com/$ODOO_SOURCE/$ODOO_VERSION/requirements.txt \
         wheel \
         wdb \
         wdb.server \
    && (python3 -m compileall -q /usr/local/lib/python3.7/ || true) \
    && apt-get purge -yqq $build_deps \
    && apt-get autopurge -yqq \
    && rm -Rf /var/lib/apt/lists/* /tmp/*

# Expose Odoo services
EXPOSE 8069 8071

# Set the default config file
ENV ODOO_RC /opt/odoo/conf/odoo.conf

COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py


FROM odoo-base

# Set default user when running the container
RUN ls -la /opt/odoo/src
RUN chown -R odoo:odoo /opt/odoo
RUN chown -R odoo:odoo /var/lib/odoo
RUN ln -s /opt/odoo/src/odoo-bin /usr/bin/odoo
RUN ls -la /opt/odoo/src

ENV WDB_NO_BROWSER_AUTO_OPEN=True \
    WDB_SOCKET_SERVER=wdb \
    WDB_WEB_PORT=1984 \
    WDB_WEB_SERVER=localhost

RUN set -x; \
        apt-get update \
       && apt-get install python-pip -y \
       && pip install wdb.server

RUN wdb.server.py &

USER odoo
ENTRYPOINT ["/entrypoint.sh"]

CMD ["odoo"]
VOLUME = ["/opt/odoo/src"]


