FROM freeradius/freeradius-server:3.2.3-alpine
LABEL maintainer="Marco Moenig <marco@moenig.it>"

ARG PLUGIN_VERSION=3.4.3
COPY raddb/ /etc/raddb/
COPY entrypoint.sh /

ADD https://raw.githubusercontent.com/privacyidea/FreeRADIUS/refs/tags/v${PLUGIN_VERSION}/privacyidea_radius.pm /usr/share/privacyidea/freeradius/
ADD https://raw.githubusercontent.com/privacyidea/FreeRADIUS/refs/tags/v${PLUGIN_VERSION}/dictionary.netknights /etc/raddb/dictionary

RUN apk update 
RUN apk add \
        perl \
        perl-config-inifiles \
        perl-data-dump \
        perl-try-tiny \
        perl-json \
        perl-lwp-protocol-https \
        perl-yaml-libyaml\
        perl-module-build \
        freeradius-utils
        
RUN perl -MCPAN -e 'install URI::Encode' \
        rm -fr /root/.cpan /root/.cpanm

# Generic cleanup
RUN rm -fr "$(find /usr/local/lib/perl5 -type f -name "*.pod")" \
        /usr/local/share/man /usr/local/share/doc \
        /var/cache/apk/* /tmp/* \
        /usr/share/man/* /usr/share/doc/* \
        /usr/share/locale/* /usr/share/info/*

RUN rm /etc/raddb/sites-enabled/inner-tunnel \
    /etc/raddb/sites-enabled/default \
    /etc/raddb/mods-enabled/eap \
    echo "DEFAULT Auth-Type := Perl" >> /etc/raddb/users

EXPOSE 1812/udp
EXPOSE 1813/udp
EXPOSE 1812/tcp

ENTRYPOINT ["/entrypoint.sh"]
CMD [ "radiusd" ]


