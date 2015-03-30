## What is this?

This can be used as a boilerplate for a node project. The benefit to using docker is that it allows you to manage your environment
is to make sure all environments are consistent from the developers to the production server. It also saves you a ton of time.

## How do I use it?

First you should have a general understanding of what [docker](https://www.docker.com/) and [docker-compose](https://docs.docker.com/compose/yml/) are 
and make sure they're installed on your machine. For Linux it's a snap. For OS X, [there are a few extra steps](http://viget.com/extend/how-to-use-docker-on-os-x-the-missing-guide) 
but it really isn't that bad.

The idea is pretty simple. You can tweak the volumes in the [docker-compose.yml](docker-compose.yml) to match your enviornment and get going.
Optionally, you can create another copy for a specific environment.

```bash
# Get it up.
docker-compose up

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
