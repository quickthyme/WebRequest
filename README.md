# WebRequest

![release_version](https://img.shields.io/github/tag/quickthyme/WebRequest.svg?label=release)
[![build status](https://travis-ci.org/quickthyme/WebRequest.svg?branch=master)](https://travis-ci.org/quickthyme/WebRequest)
[![swiftpm_compatible](https://img.shields.io/badge/swift_pm-compatible-brightgreen.svg?style=flat) ](https://swift.org/package-manager/)
![license](https://img.shields.io/github/license/quickthyme/WebRequest.svg?color=black)

**WebRequest** decouples network resources from their request declarations.

A `WebRequest` allows you to compose all of the pieces and parts needed to build, execute, and test any
sort of network request, using either static composition or dynamic building. Just **describe** the
request, **inject** the web delivery-mechanism, then **execute**.

The `WebResponse` you get back will have the original request attached along with the status code,
headers, and other data depending on whichever mechanism was used.

It comes with 4 built-in delivery mechanisms out of the box, all of which natively use Apple's `URLSession`:

  -  HTTPWebRequestDelivery - default RFC-3986 and `x-www-form-urlencoded` interactions over HTTP
  -  JSONWebRequestDelivery - same as HTTP, but tuned for `JSON` purposes
  -  FileDownloadWebRequestDelivery - for file download requests
  -  MultipartFormUploadWebRequestDelivery - for uploading files

To extend functionality, you can create new ones from scratch (such as if you want to wrap
another request library like AlamoFire), or you can subclass the default ones and tweak them
to your needs.

