# use intranet-baseimage with hugo, npm extended image for building in build step
FROM quay.io/giantswarm/intranet-baseimage:0.0.0-5a27c8b54ae5e584d0354c162aa50fcfeae81764 AS build
# copy in the source files (docs/markdown)
COPY . /src
RUN cd themes/docsy && npm install
# build static site
RUN hugo --verbose --gc --minify --enableGitInfo --cleanDestinationDir --destination /src/public

# use minimal nginx alpine image for serving static html
FROM quay.io/giantswarm/nginx-unprivileged:1.21-alpine
EXPOSE 8080
USER 0

# enable relative 301 redirects to fix invalid redirects on missing trailing slash
# (a downstream server doesn't necessarily know the public name and port)
RUN sed -i 's/location \/ {/location \/ {\n        absolute_redirect off;/' /etc/nginx/conf.d/default.conf

# copy in staticly built hugo site from build step above
COPY --from=build /src/public /usr/share/nginx/html
USER 101
