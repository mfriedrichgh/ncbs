FROM rust:slim

WORKDIR /usr/src/backend
COPY . .

RUN apt-get update
RUN apt-get install git -y

RUN rustup install nightly

RUN cargo install --path .

EXPOSE 3001
CMD ["backend"]
