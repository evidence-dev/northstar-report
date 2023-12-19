# Stage 1: Build the Svelte Kit app
FROM node:19-alpine3.16 as build

WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

# Stage 2: Use a lightweight base image suitable for serving static files
FROM nginx:alpine

# Copy the static files from the build stage to the NGINX web root
COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]