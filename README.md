<h1 align="center">CAS-Component: lua-resty-cas</h1>

<p align="center">
  <img src="https://cdn.rawgit.com/cas-x/cas-logo/master/cas.svg" width="200" height="200" />
  <br />
  <a href="https://img.shields.io/badge/branch-master-brightgreen.svg?style=flat-square">
    <img src="https://img.shields.io/badge/branch-master-brightgreen.svg?style=flat-square" />
  </a>
  <a href="https://img.shields.io/badge/license-MIT-blue.svg">
    <img src="https://img.shields.io/badge/license-MIT-blue.svg" />
  </a>
  <a href="https://img.shields.io/github/release/cas-x/lua-resty-cas.svg">
    <img src="https://img.shields.io/github/release/cas-x/lua-resty-cas.svg" />
  </a>
</p>


A component for nginx access phase module integrated with CAS

# How To Work

lua-resty-cas is based on the cas-server、nginx_lua_module and the ssl mutual authentication under the hood. It working on the access phase of nginx. Before acess the real content, we will get the certificate info from nginx and pass them to the cas-server to check whether the certificate is right.

# How To Deploy
At First let us show the architecture about these component as the following:

![lua-rest-cas](https://raw.githubusercontent.com/cas-x/lua-resty-cas/master/docs/images/lua-resty-cas.jpg)

the nginx conf like this as the following:

````
    lua_code_cache off;
    lua_package_path '/shared/art/opensource/personal/cas/lua-resty-cas/?.lua';
    access_by_lua_file '/shared/art/opensource/personal/cas/lua-resty-cas/cas.lua';

    server {
    listen 443 ssl;
    server_name example.com;

    ssl on;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers "EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA256:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384:EDH+aRSA+AESGCM:EDH+aRSA+SHA256:EDH+aRSA:EECDH:!aNULL:!eNULL:!MEDIUM:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS:!RC4:!SEED";

    ssl_certificate      /opt/nginx/ssl/CN=example.com.crt;
    ssl_certificate_key  /opt/nginx/ssl/CN=example.com.key;
    ssl_trusted_certificate /opt/nginx/ssl/ca.crt;
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_client_certificate /opt/ssl/ca.crt;
    ssl_verify_client on; #it require client to present certificate from cas
````


Contributing
------------

To contribute to lua-resty-cas, clone this repo locally and commit your code on a separate branch. 


Author
------

> GitHub [@detailyang](https://github.com/detailyang)     
  

License
-------

lua-resty-cas is licensed under the [MIT] license. 
