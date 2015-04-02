## What is this?

This is a really handy Makefile example for docker development. The example here is a nginx load balanced node, mongo, and redis 
application. The benefit to the Makefile is that you can have "controlled persistence". Obviously, if you remove a container 
then your data will be lost. When you re-run/build your containers you will be left with a clean slate. This Makefile gives you 
2 manual actions for controlling persistence - `make save` and `make restore`. Use them in development, use them in deployment. 
Every time you `make save`, a database backup is created in the folder specified (defaults to backups/). You can restore to any point 
in history now. This example was made with mongo, but with a little tweaking any store could be used.

This can be used as a boilerplate for a node project. The benefit to using docker is that it allows you to manage your environment
is to make sure all environments are consistent from the developers to the production server. It also saves you a ton of time.

## How do I use it?

First you should have a general understanding of what [docker](https://www.docker.com/) is and make sure they're installed on your 
machine. For Linux it's a snap. For OS X, [there are a few extra steps](http://viget.com/extend/how-to-use-docker-on-os-x-the-missing-guide) but it really isn't that bad.

1. First, run `make build`. This will build the image for the application.
2. Then run `make run-dev`. This will run all of the containers and you're ready to develop. On linux you can visit localhost:3030. On OS X
visit your (boot2docker ip):3030.
3. Refresh a few times, which adds cats to the system. Head back to the command line and do `make save`.
4. Head back to the browser and refresh as many times as you can. Then go back and do `make restore`. You'll be back where you saved. Controlled 
persistence.
5. To remove this app do `make destroy`.

```text
~ :: make

Application management. Please make sure you have the env_make file setup.

Usage:
make build        This builds the lev-interactive/myapp image.
make run-dev      This will start the application mapping port 80 to 3030. All src
                  files will be volumed as well for automatic restarts.
                  be working in for instant changes. Runs on port 3000.
make run-release  This will run a container without the volumes on port 80. Good
                  for production. @TODO
make save         This will save the database in the backups directory.
make restore      This will restore from the last time you saved.
make destroy      Stops and removes all running containers.
```

## TODO's

* Redis persistence.
* Ability to pass in the name of a mongodb dump directory instead of it always pulling the latest.
