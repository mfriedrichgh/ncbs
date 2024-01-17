FROM rust:slim

WORKDIR /usr/src/backend
COPY . .

RUN apt-get update && apt-get upgrade
RUN apt-get install git -y

RUN cargo install --path .

EXPOSE 3001
CMD ["backend"]
