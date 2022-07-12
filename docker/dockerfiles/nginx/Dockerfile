FROM nginx

ARG ENV

LABEL title="nginx image"
LABEL description="Provides nginx!"
LABEL version="0.1"

# Install required dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends \
    nginx-module-geoip \
    && DEBIAN_FRONTEND=noninteractive apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

# Copy configs to image
COPY ./common/ /

# grab gosu for easy step-down from root
RUN set -eux; \
	apt-get update; \
	apt-get install -y gosu; \
	rm -rf /var/lib/apt/lists/*; \
# verify that the binary works
	gosu nobody true

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
