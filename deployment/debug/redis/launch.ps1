docker pull redis
docker stop redis-dev
docker rm redis-dev
docker run --name redis-dev -p 6379:6379 -d redis