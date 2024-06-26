# Cheatsheet

## Common fetches

## Match source IP address

acl is\_malicious src 192.168.10.32 acl is\_local\_net src 192.168.32.0/24 # match IP range

## Match request path

acl is\_api path -i -m beg /api # match paths starting with /api acl is\_image -i -m end .jpg .png .gif # match paths ending with .jpg .png and .gif extensions acl is\_health -i path\_str /health # exact match path /health acl is\_dotfile path\_sub /. # match paths containing /.

## Match request param

acl has\_param url\_param(user\_id) -m found

## Match request header

acl is\_google\_domain req.hdr(host) -i -m end google.com # Domain name ends with google.com; e.g. [www.google.com](http://www.google.com/), mail.google.com

## Check if connection uses ssl

## Reject request if made over a non-ssl connection

http-request deny unless ssl\_fc

## Redirect to a different address

http-request redirect https://google.local%\[capture.req.uri] if is\_google\_domain

## Redirect to a different scheme

http-request redirect scheme https if !{ ssl\_fc }

## Redirect by adding prefix to original url e.g redirect to /v2/{original url}

http-request redirect prefix /v2 unless { path\_beg /v2 }

## Use custom HTTP code with HTTP redirects. If not specified, default is 302

## Code 301 throght 308 can be used

## Redirect to https with HTTP code 301

http-request redirect scheme code 301 https if !{ ssl\_fc }

## Select backend based on map file and request path

use\_backend be\_%\[path,map\_beg(/etc/haprofxy/backend\_map.acl, default)] # or use be\_default if no mapping if found

## Change request path

http-request set-path /v2%\[path] if !{ path\_beg -i /v2 }

## set-query can also be used to change query params

## set-uri can be used to set entire path and query

## Cache response for select requests

acl is\_assets path\_beg -i /assets # ACL for asset files http-reqeest cache-use assets if is\_assets http-response cache-store assets if is\_assets

## Deny request with custom HTTP code. Default code is 403

http-request deny deny\_status 500 if is\_malicious

## Drop request based on HTTP protocol

http-request deny if HTTP\_1.0
