# JsonSvcEx

## Description

Basic Json microservice using sinatra style inline routes, powered by Cowboy
All base paths are defined in `Router.Base` that forwards to independent controllers for simplified RESTFUL api interfaces.

a Helper Json.Response module was created to simplify status code handling and default response bodies
