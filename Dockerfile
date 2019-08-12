FROM krates/toolbox:2.4.3

WORKDIR /src/krates

ADD . .

RUN rake build:setup