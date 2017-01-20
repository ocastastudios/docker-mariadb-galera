#! /bin/sh

set -e

if [ "${S3_ACCESS_KEY_ID}" = "**None**" ]; then
  echo "You need to set the S3_ACCESS_KEY_ID environment variable."
  exit 1
fi

if [ "${S3_SECRET_ACCESS_KEY}" = "**None**" ]; then
  echo "You need to set the S3_SECRET_ACCESS_KEY environment variable."
  exit 1
fi

if [ "${S3_BUCKET}" = "**None**" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ "${S3_REGION}" = "**None**" ]; then
  echo "You need to set the S3_REGION environment variable."
  exit 1
fi

if [ "${S3_PREFIX}" = "**None**" ]; then
  echo "You need to set the S3_PREFIX environment variable."
  exit 1
fi

# env vars needed for aws tools
export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY

MYSQL_HOST_OPTS=" --user $SQLUSER --password $SQLPASSWORD --encrypt=AES256 --encrypt-key=$ENCRYPT_KEY --stream=xbstream --compress ."

echo "Creating backup of ${MYSQLDUMP_DATABASE} database(s) from ${MYSQL_HOST}..."

# Use gof3r rather than s3cmd because it takes a stream
innobackupex $MYSQL_HOST_OPTS  | gof3r put --endpoint $S3_REGION -b $S3_BUCKET -k $S3_PREFIX/$(date +"%Y-%m-%dT%H%M%SZ").xbcrypt

echo "SQL backup to $S3_BUCKET completed successfully"
