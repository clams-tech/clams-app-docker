





# this runs the web server
docker run -d --name clams -p 127.0.0.1:5173:5173 clams:latest

docker logs -f clams
