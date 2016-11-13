FROM elixir:1.3.4

COPY . /build

WORKDIR /build

RUN yes | mix deps.get

CMD ["mix", "run", "--no-halt"]
