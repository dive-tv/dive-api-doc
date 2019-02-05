#!/bin/bash

if [[ ! -z ${TRAVIS} ]]; then
    pushd $TRAVIS_BUILD_DIR
    openssl aes-256-cbc -K $encrypted_swift_model_key -iv $encrypted_swift_model_iv -in deploy-swift-model-key.enc -out deploy-swift-model-key -d
    chmod 700 deploy-swift-model-key
    eval `ssh-agent -s`
    ssh-add -D
    ssh-add deploy-swift-model-key
    popd
fi

pushd $TMP_DIR
git clone git@github.com:dive-tv/data-model-ios.git
popd