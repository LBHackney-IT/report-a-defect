# Report a Defect

A web service that allows Hackney residents to report defects with their newly built properties and the new build team to manage those defects.

## Documentation

Documentation can be found in the doc directory.

Technical handover and summary information of the beta can be read in a [Hackney Google Sheet](https://docs.google.com/document/d/1qfhREOLLcKOf4VKfXmLAVF1-qHxTTBLZGfYCgIqlVJE/edit).

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

## Rake tasks

We have two rake tasks.

* `rails notify:escalated_defects` will send one email with all the open defects
with manual escalations.
* `rails notify:due_soon_and_overdue_defects` will send one email with all defects
which are either due soon or overdue.

## Releasing changes

This application supports branch based deployments.

* To deploy to staging, create and merge pull requests into the `develop` branch
* To deploy to production, update your local `develop` branch and merge it into
  the `master` branch and push

[Circle CI](https://app.circleci.com/pipelines/github/LBHackney-IT/report-a-defect)
will automatically deploy this to Heroku.

## Access

### Staging

<https://lbh-report-a-defect-staging.herokuapp.com/>

### Production

<https://lbh-report-a-defect-production.herokuapp.com/>
