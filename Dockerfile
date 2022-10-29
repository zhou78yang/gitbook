FROM node:6-slim as build-stage

ARG VERSION=3.2.1

LABEL version=$VERSION

RUN npm config set registry=http://registry.npm.taobao.org &&\
	npm install --global gitbook-cli &&\
	gitbook fetch ${VERSION} &&\
	npm cache clear &&\
	rm -rf /tmp/*

COPY ./data /srv/gitbook
WORKDIR /srv/gitbook
RUN /usr/local/bin/gitbook install && \
    /usr/local/bin/gitbook build

FROM nginx:alpine as prod-stage

COPY --from=build-stage /srv/gitbook/_book /usr/share/nginx/html
