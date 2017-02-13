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

if [ "${RESTORE_FILENAME}" = "**None**" ]; then
  echo "You need to specify the filename of the backup to restore"
  exit 1
fi

DIR=/${RESTORE_FILENAME}-extract
mkdir -p $DIR
rm -rf /var/lib/mysql/*

# Use s3cmd rather than gof3r because the gof3r get is broken outside of us-west aws region
s3cmd --access_key=$S3_ACCESS_KEY_ID --secret_key=$S3_SECRET_ACCESS_KEY --region=$S3_REGION get s3://$S3_BUCKET/$S3_PREFIX/$RESTORE_FILENAME $RESTORE_FILENAME
xbstream -x <  $RESTORE_FILENAME -C $DIR
innobackupex --decrypt=AES256 --encrypt-key=$ENCRYPT_KEY $DIR
innobackupex --decompress --parallel=4 $DIR
find $DIR/ -name "*.qp" -delete
innobackupex --apply-log $DIR
innobackupex --copy-back $DIR
rm -rf $DIR

echo "SQL restore completed successfully"

