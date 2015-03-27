# Apparently the debian build it quite good and light.
FROM debian:latest

# whoami
MAINTAINER Pete Saia, pete@lev-interactive.com

# Intstall server basics.
RUN apt-get update && \
      apt-get install -y curl build-essential && \
      curl -sL https://deb.nodesource.com/setup | bash - && \
      apt-get install -y nodejs

# Install globals we need for npm to build and run the project.
RUN npm install -g forever bower grunt-cli

# Var for express/node. You'd want to overwrite this when running
# in staging or production. Overwrite on the run command.
ENV NODE_ENV development

# Port to run the app on.
ENV APP_PORT 8080

# Where the app libs on the host.
ENV APP_ROOT /src/app

# Where the logs live on the host.
ENV LOGS_ROOT /src/logs

# Copy the local app to the host.
COPY ./src/ $APP_ROOT

# Go to the app root.
WORKDIR $APP_ROOT

# Prep the app. This would be a good place to build assets and whatnot.
RUN mkdir $LOGS_ROOT && npm install

# Start the app. Notice forever didn't start it with `start`
# so it wouldn't go into the background. Important that it stays
# in the foreground.
CMD forever -a -w \
      -l ${LOGS_ROOT}/app.forever.log \
      -o ${LOGS_ROOT}/app.stdout.log \
      -e ${LOGS_ROOT}/app.stderr.log \
      index.js

# Expose the port that the app runs on so it can be bound.
EXPOSE $APP_PORT
