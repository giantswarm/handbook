# use intranet-baseimage with hugo, npm extended image for building in build step
# the base image also includes installed NPM packages and the Hugo theme(s)
FROM gsoci.azurecr.io/giantswarm/intranet-baseimage:0.1.174  AS build

# refresh relevant files (without clobbering stuff in the baseimage)
COPY .git /src/.git/
COPY archetypes /src/archetypes/
COPY assets /src/assets/
COPY content /src/content/
COPY layouts /src/layouts/
COPY static /src/static/
COPY config.toml /src/config.toml

# build static site
RUN hugo --verbose --gc --minify --enableGitInfo --cleanDestinationDir --destination /src/public

# final hugo output polished exclusively for production (static files served by nginx)
FROM build AS build-production

# Compress files using gzip
# (creates a copy and leaves the uncompressed version in place)
RUN find /src/public \
  -type f -regextype posix-extended \
  -iregex '.*\.(css|csv|html?|js|svg|txt|xml|json|webmanifest|ttf)' | \
    xargs gzip -9 -k

# Remove uncompressed HTML files
# to reduce storage requirements and image size.
RUN find /src/public \
  -type f \
  -name 'index.html' \
  -delete

# use minimal nginx alpine image for serving static html
FROM quay.io/giantswarm/nginx-unprivileged:1.25-alpine
EXPOSE 8080
USER 0

# The custom config disables absolute redirects and enables gzip compression
COPY proxy/proxy-production.default.conf /etc/nginx/conf.d/default.conf

# copy in staticly built hugo site from build step above
COPY --from=build-production /src/public /usr/share/nginx/html
USER 101
