#!/bin/bash
set -e

exec rake jobs:work &
exec rails s -b 0.0.0.0

exec "$@"
