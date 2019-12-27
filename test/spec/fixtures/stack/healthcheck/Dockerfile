FROM ruby:2.4.3-slim

RUN gem install webrick

ADD server.rb .

CMD ["ruby", "server.rb"]
