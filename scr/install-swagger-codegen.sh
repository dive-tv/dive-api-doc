#!/bin/bash

pushd $TMP_DIR

git clone --chmod=+x https://github.com/dive-tv/swagger-codegen

pushd $SWAGGER_CODEGEN_DIR
# Swagger version 2.2.3
git checkout -b v2.2.3 v2.2.3

mvn -q clean package

popd

popd
