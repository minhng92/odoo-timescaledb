#!/bin/bash

set -e

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo19@2024'}}}

# install python packages
# pip3 install pip --upgrade                # may cause errors
pip3 install -r /etc/odoo/requirements.txt

# Install logrotate if not already installed
if ! dpkg -l | grep -q logrotate; then
    apt-get update && apt-get install -y logrotate
fi

# Copy logrotate config
cp /etc/odoo/logrotate /etc/logrotate.d/odoo

# Start cron daemon (required for logrotate)
cron

DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then       
        value=$(grep -E "^\s*\b${param}\b\s*=" "$ODOO_RC" |cut -d " " -f3|sed 's/["\n\r]//g')
    fi;
    DB_ARGS+=("--${param}")
    DB_ARGS+=("${value}")
}
check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"

# Function to create PostgreSQL extensions from DB_EXTENSIONS env var
function create_extensions() {
    # Check if DB_EXTENSIONS is set and not empty
    if [ -n "${DB_EXTENSIONS}" ]; then
        echo "Processing DB_EXTENSIONS: ${DB_EXTENSIONS}"

        # Split by comma and iterate through each extension
        IFS=',' read -ra EXTENSIONS <<< "$DB_EXTENSIONS"
        for extension in "${EXTENSIONS[@]}"; do
            # Trim whitespace
            extension=$(echo "$extension" | xargs)

            if [ -n "$extension" ]; then
                echo "Creating extension: $extension"

                # Try to create the extension, skip if error occurs
                PGPASSWORD="$PASSWORD" psql -h "$HOST" -p "$PORT" -U "$USER" -d postgres \
                    -c "CREATE EXTENSION IF NOT EXISTS $extension CASCADE;" 2>&1 || {
                    echo "Warning: Failed to create extension '$extension', skipping..."
                }
            fi
        done

        echo "Extension creation completed"
    else
        echo "DB_EXTENSIONS not set or empty, skipping extension creation"
    fi
}

case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec odoo "$@"
        else
            wait-for-psql.py ${DB_ARGS[@]} --timeout=30
            create_extensions
            exec odoo "$@" "${DB_ARGS[@]}"
        fi
        ;;
    -*)
        wait-for-psql.py ${DB_ARGS[@]} --timeout=30
        create_extensions
        exec odoo "$@" "${DB_ARGS[@]}"
        ;;
    *)
        exec "$@"
esac

exit 1