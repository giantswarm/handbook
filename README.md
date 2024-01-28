# Handbook

This is the repository for our public [handbook](https://handbook.giantswarm.io/).

For purely internal information we have our [intranet](https://intranet.giantswarm.io).

## Repository Overview

The `content` folder of this repository is served using the static site generator [HUGO](https://gohugo.io/) docs page.
It is set up with the [Google docsy](https://github.com/google/docsy) theme and served at [https://handbook.giantswarm.io/](https://handbook.giantswarm.io/).

## Development

1. Create a `.env` file with the following content (replace the values with your own):
    ```
    ORIGINS=localhost:8081
    OAUTH_CLIENT_ID=23456789abcdef123456
    OAUTH_CLIENT_SECRET=abcdef1234567890124567890abcdef123456789
    GIT_HOSTNAME=
    ```
2. You can then easily test and render any changes to the handbook with:
    ```sh
    docker-compose build --pull
    docker-compose up
    ```
    The locally rendered site should then be accessible via `http://localhost:8081`.

Or for a simplified setup, run `hugo server`.

Auto-generated content needs to be rendered manually (eg. `make rfcs`), as it's normally updated through a GitHub action.
