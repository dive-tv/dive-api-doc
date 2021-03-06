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
    # export SWIFT_DIVE_DIR=${TMP_DIR}/api-dive-ios
    # export SWIFT_MODEL_DIR=${TMP_DIR}/data-model-ios
    export SLATE_DIR=${TMP_DIR}/slate

    # Install swagger-codegen repo in '/tmp' directory
    #source scr/install-swagger-codegen.sh
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

                echo "Generating Swift client for $tmpl, version $VERS..."
                java -jar ${SWAGGER_CODEGEN_CLI} generate -t ${SWAGGER_CODEGEN_TMPL_DIR}/swift3/touchvie -i ${TMPL_DIR} -l swift3 -c ${SWAGGER_CODEGEN_CONF_DIR}/swift-touchvie.json -o ${SWIFT_DIVE_DIR}
                if [[ $? -eq 0 ]]; then
                    echo "Deploying Swift client for $tmpl, version $VERS..."
                    source scr/deploy-client.sh swift
                    if [ $? -ne 0 ]; then
                        echo "ERROR: Deploying Swift client for $tmpl, version $VERS..."
                        exit 1
                    fi
                else
                    echo "ERROR: Generating Swift client for $tmpl, version $VERS..."
                    exit 1
                fi

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
