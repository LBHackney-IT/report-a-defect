#!/bin/sh
set -e

echo "Waiting for Postgres to be ready at $DB_HOST..."
until nc -z "$DB_HOST" 5432; do
  echo "Still waiting for Postgres..."
  sleep 2
done

echo "Postgres is up. Launching Rails."
exec "$@"
