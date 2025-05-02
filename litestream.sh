# Download litestream

#!/bin/bash

# Download Litestream
wget https://github.com/benbjohnson/litestream/releases/download/v$LITESTREAM_VERSION/litestream-v$LITESTREAM_VERSION-linux-amd64.tar.gz
tar xvzf litestream-v$LITESTREAM_VERSION-linux-amd64.tar.gz
chmod +rwx ./litestream


# Check that all necessary environment variables are defined
if [ -z "$DB_PATH" ] || \
   [ -z "$LITESTREAM_BUCKET" ] || \
   [ -z "$BUCKET_DIRECTORY" ] || \
   [ -z "$CELLAR_ADDON_HOST" ] || \
   [ -z "$CELLAR_REGION" ] || \
   [ -z "$CELLAR_ADDON_KEY_ID" ] || \
   [ -z "$CELLAR_ADDON_KEY_SECRET" ]; then
  echo "Some environment variables are missing. Please set them before running this script."
  exit 1
fi

# Create the YAML file
cat <<EOL > $APP_HOME/litestream.yml
dbs:
  - path: $DB_PATH
    replicas:
      - type: s3
        bucket: $LITESTREAM_BUCKET
        path: $LITESTREAM_BACKUPS
        endpoint: $CELLAR_ADDON_HOST
        region: $CELLAR_REGION
        access-key-id: $CELLAR_ADDON_KEY_ID
        secret-access-key: $CELLAR_ADDON_KEY_SECRET
EOL

echo "litestream.yml file created successfully."

# Give appropriate permissions
chmod +rwx litestream.yml

# Restore last SQLite backup
rm -rf $DATA_DIR
mkdir -p $DATA_DIR
./litestream restore -config litestream.yml data/db.sqlite3
