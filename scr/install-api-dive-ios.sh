#!/bin/bash

if [[ ! -z ${TRAVIS} ]]; then
    pushd $TRAVIS_BUILD_DIR
    openssl aes-256-cbc -K $encrypted_swift_key -iv $encrypted_swift_iv -in deploy-swift-key.enc -out deploy-swift-key -d
    chmod 700 deploy-swift-key
    eval `ssh-agent -s`
    ssh-add -D
    ssh-add deploy-swift-key
    popd
fi

pushd $TMP_DIR
git clone git@github.com:dive-tv/api-dive-ios.git
popd