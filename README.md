# JsonSvcEx

Documentation is available using [ExDocs](https://chiengineer.github.io/json_svc_ex)

This project was inspired by a talk at [Abstractions Conference 2016](http://abstractions.io) by Bobby Calderwood titled "Decoupled, Immutable REST APIs with Kafka Streams" [(slides)](https://speakerdeck.com/bobbycalderwood/commander-decoupled-immutable-rest-apis-with-kafka-streams)

## Description

Basic Json microservice using sinatra style inline routes, powered by Cowboy
All base paths are defined in `Router.Base` that forwards to independent controllers for simplified RESTFUL api interfaces.

a Helper Json.Response module was created to simplify status code handling and default response bodies.

A Kafka publisher is included (via docker-compose.yml) to provide a ledger based api.  The expected use case is to provide users with an async by default interface.  Future improvements include providing and setting a transaction id for the request.

## Getting Started

Install dependancies:
```
mix deps.get
```

run tests:
```
script/test
```

Start Kafka - from existing container (assumes ssh git)
```
docker-machine start
$ eval "$(docker-machine env default)"
cd <your-preferred-file-location>
git clone git@github.com:wurstmeister/kafka-docker.git
cd kafka-docker
docker-compose up
```
If you don't have docker installed follow [the directions below](#install-docker)

run interactive server (default env is `dev`):
```
script/server
```
The server will not fully start without kafka running

you will know kafka is running correctly when you can run the following:
```
iex(1)> KafkaEx.metadata
%KafkaEx.Protocol.Metadata.Response{
  brokers: [%KafkaEx.Protocol.Metadata.Broker{host: "192.168.99.100",
  node_id: 1001, port: 32769, socket: nil}], topic_metadatas: []
}
```

## Install docker

### OS X

install via homebrew
```
brew install docker-machine docker-compose
```
