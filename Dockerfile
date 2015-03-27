# https://registry.hub.docker.com/_/nginx/
FROM nginx

# whoami
MAINTAINER Pete Saia, pete@lev-interactive.com

# Install the latest node with some build-esstentials.
RUN apt-get update && \
      apt-get install -y curl build-essential && \
      curl -sL https://deb.nodesource.com/setup_0.12 | bash - && \
      apt-get install -y nodejs

# Install globals we need for npm to build and run the project.
RUN npm install -g forever bower grunt-cli node-gyp

# Var for express/node. You'd want to overwrite this when running
# in staging or production. Overwrite on the run command.
ENV NODE_ENV development

# Port to run the app on.
ENV APP_PORT 8080

# Where the app libs on the host (container).
ENV APP_ROOT /src/app

# Where the logs live on the host (container).
ENV LOGS_ROOT /src/logs

# Copy the local app to the host.
COPY src/ $APP_ROOT

# Go to the app root.
WORKDIR $APP_ROOT

# Prep the app. This would be a good place to build assets and whatnot.
RUN mkdir $LOGS_ROOT && npm cache clean && npm install

# Setup nginx config files.
COPY nginx/sites-enabled /etc/nginx/sites-enabled
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Expose the port that the app runs on so it can be bound.
EXPOSE $APP_PORT

# Start the app. Notice forever didn't start it with `start`
# so it wouldn't go into the background. Important that it stays
# in the foreground.
CMD forever start -a -w -v \
    -l ${LOGS_ROOT}/app.forever.log \
    -o ${LOGS_ROOT}/app.stdout.log \
    -e ${LOGS_ROOT}/app.stderr.log \
    index.js && \
    nginx -g "daemon off;"
