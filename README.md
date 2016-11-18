# JsonSvcEx

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

Start Kafka
```
docker-compose up
```
If you don't have docker installed follow [the directions below](#install-docker)

run interactive server (default env is `dev`):
```
script/server
```
The server will not fully start without kafka running

## Install docker

### OS X

install via homebrew
```
brew install docker-machine docker-compose
```
