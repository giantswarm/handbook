# Handbook

This is the repository for our public [handbook](https://handbook.giantswarm.io/).

For purely internal information we have our [intranet](https://intranet.giantswarm.io).

## Repository Overview

The `content` folder of this repository is served using the static site generator [HUGO](https://gohugo.io/) docs page.
It is set up with the [Google docsy](https://github.com/google/docsy) theme and served at [https://handbook.giantswarm.io/](https://handbook.giantswarm.io/).

## Development

You can easily test and render any changes to the handbook with:

```sh
docker-compose build --pull
docker-compose up
```

Content changes are then auto-reloaded in the `docker-compose` setup.

Or for a simplified setup, run `hugo server`.
