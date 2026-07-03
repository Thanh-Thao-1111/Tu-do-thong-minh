# ============================================================
# Stage 1: Build Flutter Web
# ============================================================
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy dependency files first for better layer caching
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy the rest of the project
COPY . .

# Build the Flutter web app (release mode, optimized)
RUN flutter build web --release --web-renderer canvaskit

# ============================================================
# Stage 2: Serve with Nginx
# ============================================================
FROM nginx:alpine AS production

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy the built Flutter web app from the build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
