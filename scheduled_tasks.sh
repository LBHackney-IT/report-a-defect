#!/bin/bash

# Description: This script is intended to be run as a cron job to notify users about escalated defects and due soon/overdue defects. Will be run daily at 7 AM UTC (check terraform - eventbridge).

set -e # Exit immediately if a command exits with a non-zero status.

bundle exec rake notify:escalated_defects
bundle exec rake notify:due_soon_and_overdue_defects