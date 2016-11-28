FROM elixir:1.3.4

ENV DEBIAN_FRONTEND=noninteractive
ENV PHOENIX_VERSION 1.2.1

RUN /usr/local/bin/mix local.hex --force && \
    /usr/local/bin/mix local.rebar --force

# install the Phoenix Mix archive
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new-$PHOENIX_VERSION.ez

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y -q nodejs

ONBUILD WORKDIR /usr/src/app
ONBUILD ENV MIX_ENV prod

ONBUILD COPY mix.* /usr/src/app/
ONBUILD RUN mix do deps.get --only prod
# phoenix and phoenix_html JS dependencies are included from Hex packages
ONBUILD COPY package.json /usr/src/app/
ONBUILD RUN npm install
ONBUILD RUN mix deps.compile --only prod

ONBUILD COPY . /usr/src/app/
ONBUILD RUN mkdir -p /usr/src/app/priv/static
ONBUILD RUN mix phoenix.digest
ONBUILD RUN mix compile

