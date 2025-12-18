#!/usr/bin/env bash
# set -euo pipefail
# python3 manage.py migrate --noinput
# python3 manage.py collectstatic --noinput
# exec daphne --access-log - -b 0.0.0.0 -p "${PORT:-8000}" task_manager.asgi:application


# file: entrypoint.sh
#!/usr/bin/env bash
set -euo pipefail

# --- one-time DB repair (safe to run repeatedly) ---
# If initial migrations tables already exist but django_migrations is empty,
# this marks them applied without recreating tables.
python3 manage.py migrate --fake-initial --noinput || {
  # Handle the common "django_content_type already exists" case explicitly,
  # then retry the fake-initial for all apps.
  python3 manage.py migrate contenttypes 0001 --fake || true
  python3 manage.py migrate --fake-initial --noinput
}

# Apply remaining real migrations (creates anything missing)
python3 manage.py migrate --noinput

# Static files
python3 manage.py collectstatic --noinput

# Start ASGI server
exec daphne --access-log - -b 0.0.0.0 -p "${PORT:-8000}" task_manager.asgi:application
