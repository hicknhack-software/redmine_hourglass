ARG RUBY_VERSION=3.1
ARG REDMINE_VERSION=5-stable

FROM alpinelab/ruby-dev:${RUBY_VERSION} AS redmine
ARG REDMINE_VERSION
ENV REDMINE_VERSION=${REDMINE_VERSION}

RUN \
  cd / \
  && mv /app /redmine \
  && chmod ugo+w /redmine
WORKDIR /redmine
