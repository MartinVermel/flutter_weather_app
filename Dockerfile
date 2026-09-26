# syntax=docker/dockerfile:1

# ---- Stage 1: build the Flutter web bundle ----
FROM ghcr.io/cirruslabs/flutter:3.24.5 AS build
WORKDIR /app

# Resolve dependencies first so this layer is cached until pubspec changes
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

COPY . .
ARG OPENWEATHER_API_KEY=YOUR_KEY_HERE
RUN flutter build web --release --dart-define=OPENWEATHER_API_KEY=$OPENWEATHER_API_KEY

# ---- Stage 2: serve static files with nginx ----
FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost/ >/dev/null || exit 1
