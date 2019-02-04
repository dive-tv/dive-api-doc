#!/bin/bash

if [[ -z ${TRAVIS} ]]; then

    # fake Travis env
    echo "This is a local build"

    export TRAVIS_BUILD_DIR=$(pwd)
    export ENCRYPTION_LABEL="f456d91f26a4"
    export COMMIT_AUTHOR_USERNAME="TravisCI"
    export COMMIT_AUTHOR_EMAIL="development@dive.tv"
    export TMP_DIR=/tmp
    export SWAGGER_CODEGEN_DIR=${TMP_DIR}/swagger-codegen
    export SWAGGER_CODEGEN_CLI=${SWAGGER_CODEGEN_DIR}/modules/swagger-codegen-cli/target/swagger-codegen-cli.jar
    export SWAGGER_CODEGEN_TMPL_DIR=${SWAGGER_CODEGEN_DIR}/modules/swagger-codegen/src/main/resources
    export SWAGGER_CODEGEN_CONF_DIR=${SWAGGER_CODEGEN_DIR}/bin/touchvie
    export SLATE_DIR=${TMP_DIR}/slate

    # Install swagger-codegen repo in '/tmp' directory
    #source scr/install-swagger-codegen.sh
    # Install api-dive-ios repo in '/tmp' directory
    #source scr/install-api-dive-ios.sh
    # Install data-model-ios repo in '/tmp' directory
    #source scr/install-data-model-ios.sh
    # Install slate repo in '/tmp' directory
    source scr/install-slate.sh
fi

RET_VAL=0

# Deploy only if we're testing the master branch
if [[ -z ${TRAVIS} || ${TRAVIS} = false || "$TRAVIS_BRANCH" == "master" ]]; then

    ####################
    # codegen disabled for now
    ####################
    if [ "a" == "b" ]; then
        pushd 'templates'
        for tmpl in *'.json'
        do
        (
            TMPL_DIR=${TRAVIS_BUILD_DIR}/templates/$tmpl
            VERS=$(cat $TMPL_DIR | jq -r '.info.version')

            # Deploy only dive-api clients...
            if [[ $tmpl == *"dive"* ]]; then

                pushd $TRAVIS_BUILD_DIR



                echo "Deploying Java client for $tmpl, version $VERS... (TODO)"
                echo "Deploying TypeScript client for $tmpl, version $VERS... (TODO)"

                popd
            fi
        )
        done
        popd
    fi
    source scr/deploy-doc.sh

fi

exit ${RET_VAL}