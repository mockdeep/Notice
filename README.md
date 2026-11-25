# Notice

Notice keeps an eye on the things you need to deal with and tells you when
they need attention. Each "check" counts something, like cards in a Trello
list, pull requests assigned to you on GitHub, or a number you enter by hand.
You set a target for each check, and Notice flags the ones that go over it.

## Setup

You'll need Ruby (see `.ruby-version`), Node (see `.node-version`), pnpm, and
PostgreSQL.

Set these environment variables:

* `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET`
* `NOTICE_TRELLO_DEVELOPER_PUBLIC_KEY`

Then install dependencies and set up the database:

```sh
bin/setup
```

## Running locally

`Procfile.dev` lists the processes for local development: the web server,
JS and CSS builds, the job worker, and MailCatcher. Start them with a Procfile
runner, for example:

```sh
foreman start -f Procfile.dev
```

## Tests

```sh
bin/rspec   # Ruby specs
pnpm test   # Vitest
```

By default, specs use fake versions of GitHub and Trello. To run against the
real services, set `FAKE_APIS=false` and put real credentials in
`.env.test.local`, including `NOTICE_DEV_TRELLO_EMAIL` and
`NOTICE_DEV_TRELLO_PASSWORD`.
