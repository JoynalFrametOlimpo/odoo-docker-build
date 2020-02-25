FROM debian:buster-slim
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
RUN pip3 install \
        -r https://raw.githubusercontent.com/$ODOO_SOURCE/$ODOO_VERSION/requirements.txt

# Expose Odoo services
EXPOSE 8069 8071

# Set the default config file
ENV ODOO_RC /opt/odoo/conf/odoo.conf

COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

# Set default user when running the container
ONBUILD RUN ln -s /opt/odoo/src/odoo-bin /usr/bin/odoo
ONBUILD RUN chown -R odoo:odoo /opt/odoo
ONBUILD RUN chown -R odoo:odoo /var/lib/odoo

ONBUILD USER odoo

ONBUILD ENTRYPOINT ["/entrypoint.sh"]

ONBUILD CMD ["odoo"]
ONBUILD VOLUME = ["/opt/odoo/src"]


