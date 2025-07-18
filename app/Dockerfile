FROM alpine AS builder
RUN echo "<!DOCTYPE html><html><body><h1>🚀 DevOps Challenge</h1></body></html>" > /index.html


FROM nginx:alpine
LABEL maintainer="danylo.oliveira73@gmail.com"
COPY --from=builder /index.html /usr/share/nginx/html/index.html

HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost || exit 1

EXPOSE 80
