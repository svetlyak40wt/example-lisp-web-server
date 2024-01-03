How to build
============

docker build -t http-app .

How to run
==========

docker network create test-net

docker run --rm --network test-net -ti --name foo -p 1090:80 http-app

then in other console:

docker run --rm --network test-net -ti --name bar -p 1090:80 http-app
