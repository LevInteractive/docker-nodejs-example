## Play with it.

```bash
# Get it up.
docker-compose up -p my-container

# Now you should be able to visit localhost or (<boot2docker ip>) if on a mac.
# So something like this:
# http://192.168.59.103:8080/ <=== Port forwarded for the node app running locally. 8080:8080
# http://192.168.59.103:8888/ <=== Port forwarded from port 80 being run by nginx.  8888:80

# In production, obviously you wouldn't need to forward these ports if DNS is setup and nginx
# is running on port 80. Feel free to tweak nginx/* and just re-run: docker-compose build.

# Rebuilds Dockfile if you made changes to that.
docker-compose build && docker-compose up

# Build from scratch.
docker-compose build --no-cache web && docker-compose up
```
