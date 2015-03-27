## Play with it.

```bash
# First, build the image. I'm calling it lev-interactive/testapp but you can call it anything you'd like.
docker build -t lev-interactive/testapp .

# Now look at it. Should be the first in the list of images.
docker images

# Then run the image as a container.
docker run -d -p 3000:8080 --name my-app-container lev-interactive/testapp

# Look at it. Sweet.
docker ps

# Now checkout localhost:3000 if you're on linux. If not checkout your <boot2docker ip>:3000
# It will be something like: http://192.168.59.103:3000/

# Tail the logs.
docker logs -f my-app-container

# Okay, cool. Kill the container.
docker rm <container-id>

# What if you're actively developing? Create a volume (-v), then checkout
# the app in your browser. Now change some code. Boom.
# Note on OS X (not Linux) you must provide a full path to the local volume.. so make it your own.
# Also note that you'll probably need to run npm install in your local version first.
# The app will restart when you make changes because of the -w flag in the Dockerfile (on forever).
docker run -d -p 3000:8080 -v /Users/petesaia/Work/nodejs-docker-example/src/:/src/app --name my-app-container lev-interactive/testapp

# Kill the container and image.
docker rm <container-id>
docker rmi <image-id>

# Nice.
```
