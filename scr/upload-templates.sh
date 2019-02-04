#!/bin/bash

AWS_CLI=$(which aws)
S3_BUCKET=touchvie-pro-cdn
S3_KEY=swagger
CLOUDFRONT_DISTRIBUTION=E1EOJ4G5NRI0GG

# Deploy only if we're testing the master branch
if [[ -z ${TRAVIS} || ${TRAVIS} = false || "$TRAVIS_BRANCH" == "master" ]]; then

    pushd 'templates'
    for tmpl in *'.json'
    do
    (
        ${AWS_CLI} --region $AWS_DEFAULT_REGION s3 cp ${tmpl} s3://${S3_BUCKET}/${S3_KEY}/${tmpl}
        if [ $? -ne 0 ]; then
            echo "ERROR: Uploading template '$tmpl' to S3..."
        fi
        ${AWS_CLI} --region $AWS_DEFAULT_REGION cloudfront create-invalidation --distribution-id ${CLOUDFRONT_DISTRIBUTION} --paths /${S3_KEY}/${tmpl}
        if [ $? -ne 0 ]; then
            echo "ERROR: Invalidating template '$tmpl' to cloudfront..."
        fi
    )
    done
    popd
fi

exit 0