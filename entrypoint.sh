#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

bundle exec rake notify:escalated_defects
bundle exec rake notify:due_soon_and_overdue_defects