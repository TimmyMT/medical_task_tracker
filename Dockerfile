# Dockerfile

FROM ruby:3.2.5

# зависимости системы
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  git \
  && rm -rf /var/lib/apt/lists/*

# рабочая директория
WORKDIR /app

# bundler
RUN gem install bundler

# копируем Gemfile
COPY Gemfile Gemfile.lock ./

RUN bundle install

# копируем проект
COPY . .

# entrypoint
ENTRYPOINT ["./entrypoint.sh"]

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
