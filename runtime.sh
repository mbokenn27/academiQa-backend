#!/usr/bin/env bash
set -euo pipefail
python3 manage.py migrate --noinput
python3 manage.py collectstatic --noinput
exec daphne --access-log - -b 0.0.0.0 -p "${PORT:-8000}" task_manager.asgi:application
