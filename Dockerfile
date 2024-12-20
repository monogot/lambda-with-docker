FROM node:18 AS build-image

RUN apt-get update && \
    apt-get install -y \
    g++ \
    make \
    cmake
# Copy function code
COPY index.js package.json cputil-linux-x64_v112.tar.gz .

# Extract the cputil zip file
RUN mkdir -p /opt && \
    tar -xzf cputil-linux-x64_v112.tar.gz -C /opt && \
    rm cputil-linux-x64_v112.tar.gz && \
    chmod 755 /opt/cputil-linux-x64/cputil && \
    chmod +x /opt/cputil-linux-x64/cputil && \
    ln -s /opt/cputil-linux-x64/cputil /usr/local/bin/cputil

# Install Node.js dependencies
RUN npm install

# Install the runtime interface client
RUN npm install aws-lambda-ric

# Grab a fresh slim copy of the image to reduce the final size
FROM node:18-slim

# Required for Node runtimes which use npm@8.6.0+ because
# by default npm writes logs under /home/.npm and Lambda fs is read-only
ENV NPM_CONFIG_CACHE=/tmp/.npm

# Copy in the built dependencies
COPY --from=build-image . .

# Set runtime interface client as default command for the container runtime
ENTRYPOINT ["/usr/local/bin/npx", "aws-lambda-ric"]

# Pass the name of the function handler as an argument to the runtime
CMD ["index.handler"]

# docker build --platform linux/amd64 -t hello-world:test --progress=plain --no-cache .
# docker build --platform linux/arm64 -t starcloud .
# docker tag starcloud:latest 399083768160.dkr.ecr.ap-southeast-1.amazonaws.com/starcloud:latest
# docker push 399083768160.dkr.ecr.ap-southeast-1.amazonaws.com/starcloud:latest
