# use intranet-baseimage with hugo, npm extended image for building in build step
FROM quay.io/giantswarm/intranet-baseimage:0.1.53-abbeb0a4f86c81e5d03b4df0a084bb2c940c78c5  AS build
# copy in the source files (docs/markdown)
COPY . /src
RUN cd themes/docsy && npm install
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
FROM quay.io/giantswarm/nginx-unprivileged:1.24-alpine
EXPOSE 8080
USER 0

# The custom config enables the /searchapi route, proxying to sitesearch-app.docs:9200
COPY proxy/proxy-production.default.conf /etc/nginx/conf.d/default.conf

# copy in staticly built hugo site from build step above
COPY --from=build-production /src/public /usr/share/nginx/html
USER 101
