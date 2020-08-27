## First things first
- This branch is based off: https://github.com/fylein/postgrest/releases/tag/v6.0.2
- The whole repo is forked from: https://github.com/PostgREST/postgrest
- Find the master's README at: https://github.com/fylein/postgrest

We are customising this version as per our needs. To be specific:
- We are adding support for returning the sql query generated for a given request without actually firing that query.
- If the `Accept` header in the request has the value of `application/sql`, we return the sql query generated for that request.
- We are adding this support only for `ActionRead` kind of `Action`. In non-postgrest lingo, just for `GET` kind of requests. Other actions are untouched, and the behaviour for them would be same as that of standard library.

## Local dev
Note: As of developing this, the latest Stack version is:
```shell script
% stack --version
Version 2.3.3, Git revision cb44d51bed48b723a5deb08c3348c0b3ccfc437e x86_64 hpack-0.33.0
```
All the testing is done with this version of Stack, so would recommend to stick to the same to avoid any surprises. But, if you are more of a explorer, go ahead, experiment!

The following two links are your friends:
- http://postgrest.org/en/v7.0.0/tutorials/tut0.html
- http://postgrest.org/en/v7.0.0/development.html#build-source

Assuming, you have the `stack` installed:
- Build the application: `stack build --install-ghc --copy-bins --local-bin-path /usr/local/bin`
- Note: `--install-ghc` flag is only needed for the first build. Can be dropped in subsequent builds.
- Run the application: `postgrest tutorial.conf`

You can create the above conf file by copying the content from the first tutorial above.

## Local dev usage
Assuming you have the below table from the above tutorial:
```shell script
% docker exec -it tutorial psql -U postgres                       
psql (12.4 (Debian 12.4-1.pgdg100+1))
Type "help" for help.

postgres=# select * from api.todos;
id | done |       task        | due 
----+------+-------------------+-----
1 | f    | finish tutorial 0 | 
2 | f    | pat self on back  | 
(2 rows)

postgres=# \q
```

Everything else will work as standard library:
```shell script
% curl http://localhost:3000/todos -i                                    
HTTP/1.1 200 OK
Transfer-Encoding: chunked
Date: Thu, 20 Aug 2020 04:37:32 GMT
Server: postgrest/6.0.2 (677580c)
Content-Type: application/json; charset=utf-8
Content-Range: 0-1/*
Content-Location: /todos

[{"id":1,"done":false,"task":"finish tutorial 0","due":null}, 
{"id":2,"done":false,"task":"pat self on back","due":null}]%                                                                                                                                                                                 
```

Except when the `Accept` header has a value of `application/sql`:
```shell script
% curl http://localhost:3000/todos -i -H "Accept: application/sql"         
HTTP/1.1 200 OK
Transfer-Encoding: chunked
Date: Thu, 20 Aug 2020 04:37:40 GMT
Server: postgrest/6.0.2 (677580c)
Content-Type: application/sql; charset=utf-8

SELECT "api"."todos".* FROM "api"."todos"    %                                                                                                                                                                                                
``` 

## Related
- https://github.com/PostgREST/postgrest/issues/1573