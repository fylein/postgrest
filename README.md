## First things first
- This branch is based off: https://github.com/fylein/postgrest/releases/tag/v7.0.1
- The whole repo is forked from: https://github.com/PostgREST/postgrest
- Find the master's README at: https://github.com/fylein/postgrest

We are customising this version as per our needs. To be specific:
- We are adding support for returning the sql query generated for a given request without actually firing that query.
- If the `Accept` header in the request has the value of `application/sql`, we return the sql query generated for that request.
- We are adding this support only for `ActionRead` kind of `Action`. In non-postgrest lingo, just for `GET` kind of requests. Other actions are untouched, and the behaviour for them would be same as that of standard library.
- Docker images for the customised variants can be found at: https://hub.docker.com/r/fylehq/postgrest

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

## Docker dev
- `docker build -t fylehq/postgrest:v7.0.1.1 .`
- `docker run --name postgrest -p 8008:3000 -e "PGRST_DB_URI=<db-uri>" -e "PGRST_DB_ANON_ROLE=<role>" -e "PGRST_DB_SCHEMA=<schema>" -e "PGRST_DB_EXTRA_SEARCH_PATH=<supporting-schema>" -d --rm fylehq/postgrest:v7.0.1.1`

## Naming convention
- We checkout branch from the tag of interest.
- We name this branch same as the tag(without `v`).
- For example, if we want to customise `v7.0.1`: `git checkout tags/v7.0.1 -b 7.0.1`
- Commit the changes in this branch and push to remote.
- We never change the history for `master` branch. It's left untouched.
- It means, we don't merge the private branch to `master`, instead we build our docker image out of these private branches.
- Tagging convention for docker image is: `fylehq/postgrest:{tag}.{revision}`
- Example: if we build the first image out of branch `7.0.1`, we would tag the image as: `fylehq/postgrest:v7.0.1.1`
- With subsequent build, the revision number increments by 1.

## Usage
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
Server: postgrest/7.0.1 (677580c)
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
Server: postgrest/7.0.1 (677580c)
Content-Type: application/sql; charset=utf-8

SELECT "api"."todos".* FROM "api"."todos"    %                                                                                                                                                                                                
``` 

## Helpful resources
- https://www.fpcomplete.com/blog/2017/12/building-haskell-apps-with-docker/
- `./test/Dockerfile.test`
- https://docs.haskellstack.org/en/stable/install_and_upgrade/#manual-download_2
- https://raw.githubusercontent.com/commercialhaskell/stack/stable/etc/scripts/get-stack.sh
- Entering into a non-running image: `docker run -it --entrypoint /bin/bash <image-id>`
- Login to docker account: `docker login`
- Pushing to docker hub: `docker push fylehq/postgrest:v7.0.1.1` 
- https://github.com/PostgREST/postgrest/issues/1573