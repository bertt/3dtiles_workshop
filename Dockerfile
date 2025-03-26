# Use the GDAL Alpine-based image as the base image
FROM ghcr.io/osgeo/gdal:alpine-small-latest

# Install dependencies: nodejs, psql, and curl
RUN apk add --no-cache \
    nodejs \
    npm \
    postgresql-client \
    curl

# Create the /workspace directory
RUN mkdir -p /workspace

# Set the working directory
WORKDIR /workspace

# Set the container to run continuously
CMD ["tail", "-f", "/dev/null"]