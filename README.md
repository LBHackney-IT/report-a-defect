# Report a Defect

A web service that allows Hackney residents to report defects with their newly built properties and the new build team to manage those defects.

## Documentation
Documentation can be found in the doc directory.

## ADRs
Architecture decision records can be found in the doc/architecture/decisions directory.

## Prerequisites
* [Docker](https://docs.docker.com/docker-for-mac)

## Getting started

The following command will start all containers, do any database set up if required before leaving you on an interactive prompt within rails server:

```bash
bin/dstart
```

If you'd like to see all logs, like Sidekiq or Redis you can use the default:

```
docker-compose up
```

## Running the tests

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

## Access

### Staging
https://lbh-report-a-defect-staging.herokuapp.com/

### Production
https://lbh-report-a-defect-production.herokuapp.com/
