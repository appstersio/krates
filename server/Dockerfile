FROM ruby:2.5-slim
LABEL maintainer="Pavel Tsurbeleu <staticpagesio@gmail.com>"

ENV LANG=C.UTF-8 \
    BUNDLER_VERSION=2.1.4 \
    BUNDLE_JOBS=16 \
    BUNDLE_GEMFILE=

ADD Gemfile Gemfile.lock /app/

RUN apt-get update -y && apt-get install -y make gcc g++ && \
    gem install bundler --version ${BUNDLER_VERSION} && \
    gem cleanup bundler; cd app ; bundle install && \
    apt-get remove -y make gcc g++ && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

ADD . /app

USER nobody

ENV PATH="/app/bin:${PATH}" \
    RACK_ENV=production

EXPOSE 9292

WORKDIR /app

CMD ["./run.sh"]