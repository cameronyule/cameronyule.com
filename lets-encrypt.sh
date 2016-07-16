#!/usr/bin/env bash

set -euf -o pipefail

AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""
AWS_S3_BUCKET=""
AWS_S3_REGION="eu-west-1"
AWS_CF_DISTRIBUTION_ID=""
DOMAIN="cameronyule.com"

letsencrypt --agree-tos -a letsencrypt-s3front:auth \
--letsencrypt-s3front:auth-s3-bucket "${AWS_S3_BUCKET}" \
--letsencrypt-s3front:auth-s3-region "${AWS_S3_REGION}" \
-i letsencrypt-s3front:installer \
--letsencrypt-s3front:installer-cf-distribution-id "${AWS_CF_DISTRIBUTION_ID}" \
-d "${DOMAIN}"
