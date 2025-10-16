FROM ruby:3.4-alpine

RUN apk add --no-cache build-base git

WORKDIR /app

COPY Gemfile Gemfile.lock lago-ruby-client.gemspec .git  ./
COPY lib/lago/version.rb ./lib/lago/version.rb

RUN bundle install

COPY . .

CMD ["bundle", "exec", "rspec"]
