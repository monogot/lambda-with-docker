ARG FUNCTION_DIR="/function"

FROM node:22 AS build-image

# Include global arg in this stage of the build
ARG FUNCTION_DIR

# Install build dependencies
RUN apt-get update && \
    apt-get install -y \
    g++ \
    make \
    cmake \
    unzip \
    libcurl4-openssl-dev

# Copy function code
RUN mkdir -p ${FUNCTION_DIR}/
COPY index.js package.json cputil-linux-x64.tar.gz ${FUNCTION_DIR}

RUN tar -xzf ${FUNCTION_DIR}/cputil-linux-x64.tar.gz -C ${FUNCTION_DIR} && \
    rm ${FUNCTION_DIR}/cputil-linux-x64.tar.gz && \
    chmod 755 ${FUNCTION_DIR}/cputil-linux-x64/cputil && \
    ln -s ${FUNCTION_DIR}/cputil-linux-x64/cputil /usr/local/bin/cputil

WORKDIR ${FUNCTION_DIR}

# Install Node.js dependencies
RUN npm install

# Install the runtime interface client
RUN npm install aws-lambda-ric

# Grab a fresh slim copy of the image to reduce the final size
FROM node:22-slim

# Required for Node runtimes which use npm@8.6.0+ because
# by default npm writes logs under /home/.npm and Lambda fs is read-only
ENV NPM_CONFIG_CACHE=/tmp/.npm

# Include global arg in this stage of the build
ARG FUNCTION_DIR

# Set working directory to function root directory
WORKDIR ${FUNCTION_DIR}

# Copy in the built dependencies
COPY --from=build-image ${FUNCTION_DIR} ${FUNCTION_DIR}

RUN apt-get update && apt-get install -y libssl-dev

# Set runtime interface client as default command for the container runtime
ENTRYPOINT ["/usr/local/bin/npx", "aws-lambda-ric"]

# Pass the name of the function handler as an argument to the runtime
CMD ["index.handler"]

# Comments
# RUN test=$(ldd ${FUNCTION_DIR}/cputil-linux-x64/cputil) && echo "$test"
# docker build --platform linux/amd64 -t starcloud:latest --progress=plain --no-cache .
# docker build --platform linux/amd64 -t starcloud:latest . && docker tag starcloud:latest 399083768160.dkr.ecr.ap-southeast-1.amazonaws.com/starcloud:latest && docker push 399083768160.dkr.ecr.ap-southeast-1.amazonaws.com/starcloud:latest
