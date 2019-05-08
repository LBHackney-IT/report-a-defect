# Report a Defect

A web service that allows users to report problems with their home.

## Getting started **with** Docker

```bash
docker-compose up
```

If you'd like to use the `pry` gem for debugging start with:
```bash
bin/dstart
```

## Getting started **without** Docker

```bash
rails s
```

## Testing

### Start and stop the test server
```bash
bin/dtest-server up
bin/dtest-server down
```

Run Rake
```bash
bin/dspec
```

# Run specific tests
```bash
bin/dspec spec/features/*
```
### Or without Docker

```bash
bundle exec rspec spec
```

## Deploying

We'll use Heroku's container deployment to get this live for free.

[Make sure you have the `heroku-cli` installed, connected to your personal account and ready to go.](https://devcenter.heroku.com/articles/heroku-cli)

```bash
heroku create --manifest --region eu
```


```bash
heroku buildpacks:set https://github.com/bundler/heroku-buildpack-bundler2
```

```
heroku config:set SECRET_KEY_BASE=e6258316c349d4526b5fb29b25a94c3a8f7417e5c6fe1de061d9fe7d8dfe5737b20164507dc817a449a5cd4f5c5d7d60eeeb188361bafbeb1e8fcc31f1e1551 \
  -a report-a-repair
```

```
git push heroku/master
```
