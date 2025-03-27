# Use the GDAL Alpine-based image as the base image
FROM ghcr.io/osgeo/gdal:alpine-small-latest

# Install dependencies: nodejs, psql, and curl
RUN apk add --no-cache \
    nodejs \
    npm \
    postgresql-client \
    curl \
    libc6-compat \
    gcompat

# Install pg2b3dm
RUN wget https://github.com/Geodan/pg2b3dm/releases/download/v2.18.1/pg2b3dm-linux-x64.zip -P /home
RUN unzip /home/pg2b3dm-linux-x64.zip -d /usr/local/bin

# Create the /workspace directory
RUN mkdir -p /workspace

# Set the working directory
WORKDIR /workspace

# Set the container to run continuously
CMD ["tail", "-f", "/dev/null"]