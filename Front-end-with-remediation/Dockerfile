# Stage 1: Build flutter app for web
FROM ghcr.io/cirruslabs/flutter:3.38.9 AS build

WORKDIR /app

# Copy dependency configs first
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy all code after packages are grabbed
COPY . .

# Build the Web artifact
RUN flutter build web

# Stage 2: Serve using Nginx
FROM nginx:alpine

# Copy the generated flutter web files to Nginx docroot 
COPY --from=build /app/build/web /usr/share/nginx/html

# Port exposed internally for docker network
EXPOSE 80

# Daemon mode off to keep container running
CMD ["nginx", "-g", "daemon off;"]
