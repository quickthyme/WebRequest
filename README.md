# WebRequest

Handy proxy for decoupling and abstracting network delivery mechanisms away from application code.

A `WebRequest` allows you to compose all of the pieces and parts needed to build, execute, and test any
sort of network request. Intended for static compostition, but also supports and enables dynamic building.

Using WebRequest to subscribe to external data couldn't be any easier.

Just **describe** the request, **inject** the delivery mechanism, **execute**.

It comes with 4 built-in delivery mechanisms out of the box, all of which natively use Apple's `URLSession`:

  -  HTTPWebRequestDelivery - standard RFC-3986 call and response over HTTP
  -  JSONWebRequestDelivery - same as HTTP, but sends `JSON` body data *instead* of `x-www-form-urlencoded`
  -  FileDownloadWebRequestDelivery - downloads a file resource
  -  MultipartFormUploadWebRequestDelivery - uploads file(s)

To extend functionality, you can create new ones from scratch (such as if you want to wrap
another request library like AlamoFire), or you can subclass the default ones and tweak them
to your needs.

