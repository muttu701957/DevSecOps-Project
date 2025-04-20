FROM node:16.17.0-alpine as builder
WORKDIR /app

# Copy dependencies and install
COPY ./package.json . 
COPY ./yarn.lock .
RUN yarn install

# Copy source code
COPY . .

# Accept and set RapidAPI-related build arguments
ARG RAPIDAPI_KEY
ARG RAPIDAPI_HOST
ARG API_ENDPOINT_URL

# Set environment variables to be used in Vite
ENV VITE_RAPIDAPI_KEY=${RAPIDAPI_KEY}
ENV VITE_RAPIDAPI_HOST=${RAPIDAPI_HOST}
ENV VITE_APP_API_ENDPOINT_URL=${API_ENDPOINT_URL}

# Build the application
RUN yarn build

# Serve the app using Nginx
FROM nginx:stable-alpine
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=builder /app/dist .  # Copy the build artifacts to Nginx
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]
