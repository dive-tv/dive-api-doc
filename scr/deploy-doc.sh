#!/bin/bash

if [[ -n "${TRAVIS}" && ${TRAVIS} = true ]]; then
    DEPLOY_OPTS="-k ${TRAVIS_BUILD_DIR}/deploy_key.enc"
fi

TARGET_DIR=${TRAVIS_BUILD_DIR}/target
BUILD_DIR=${TRAVIS_BUILD_DIR}/build
STATIC_DIR=${TRAVIS_BUILD_DIR}/static

SLATE_BUILD_DIR=${SLATE_DIR}/build
SLATE_SRC_DIR=${SLATE_DIR}/source
SLATE_INC_DIR=${SLATE_SRC_DIR}/includes

DOCS_TO_TRANSFORM=('paths' 'definitions')
REPOSITORIES=("https://github.com/dive-tv/sdk-client-java.git" "https://github.com/dive-tv/ea-client-sdk-android.git")

RET_VAL=0

clean_slate() {
    rm -rf ${SLATE_DIR}
    rm -rf ${TARGET_DIR}
    rm -rf ${BUILD_DIR}
}

install_slate() {
    pushd ${SLATE_DIR}

    bundler --version 2> /dev/null || gem install bundler
    bundle install
    if [ $? -ne 0 ]; then
        echo "Error installing bundler"
        exit 1
    fi

    popd
}

generate_slate() {
    pushd ${SLATE_DIR}

    # generate slate doc
    bundle exec middleman build --clean --verbose

    # copy generated docs to api-doc repo
    mkdir -p ${BUILD_DIR}
    cp -R ${SLATE_BUILD_DIR}/* ${BUILD_DIR}/

    popd
}

# Deploy only if we're deploying the master branch
if [[ -z ${TRAVIS} || "$TRAVIS_BRANCH" == "master" ]]; then

    ########
    # Init #
    ########

    # install slate requirements
    install_slate

    # generate markdown from swagger templates
    mvn deploy
    if [ $? -ne 0 ]; then
        echo "Error generating markdown from swagger templates"
        exit 1
    fi
    
    # copy static content to slate
    mkdir -p ${SLATE_INC_DIR}
    cp ${STATIC_DIR}/_*.md ${SLATE_INC_DIR}
    cp ${STATIC_DIR}/*.html.md ${SLATE_SRC_DIR}
    cp ${STATIC_DIR}/logo.png ${SLATE_SRC_DIR}/images/

    #####################
    ## Generate EA-API ##
    #####################

    # transform ea-api files to slate format
    for DOC in "${DOCS_TO_TRANSFORM[@]}"; do
        python3 scr/transform.py ${TARGET_DIR}/ea-api/markdown/_ea.api.${DOC}.mhon3 scr/transform.py ${TARGET_DIR}/ea-api/markdown/_ea.api.${DOC}.md
        if [ $? -ne 0 ]; then
            echo "Error transforming ea-api $DOC document from markdown to slate format"
            exit 1
        fi
    done

    # generate ea-api slate doc
    cp ${TARGET_DIR}/ea-api/markdown/* ${SLATE_INC_DIR}/
    generate_slate

    #####################
    ## Generate AR-API ##
    #####################

    # transform ar-api files to slate format
    for DOC in "${DOCS_TO_TRANSFORM[@]}"; do
        python3 scr/transform.py ${TARGET_DIR}/ar-api/markdown/_ar.api.${DOC}.md
        if [ $? -ne 0 ]; then
            echo "Error transforming ar-api $DOC document from markdown to slate format"
            exit 1
        fi
    done

    # generate ar-api slate doc
    cp ${TARGET_DIR}/ar-api/markdown/* ${SLATE_INC_DIR}/
    generate_slate

    #######################
    ## Generate DIVE-API ##
    #######################

    # transform dive-api files to slate format
    python3 scr/transform.py ${TARGET_DIR}/dive-api/markdown/_dive.api.paths.md
    if [ $? -ne 0 ]; then
        echo "Error transforming dive-api paths document to slate format"
        exit 1
    fi

    # generate dive-api slate doc
    cp ${TARGET_DIR}/dive-api/markdown/* ${SLATE_INC_DIR}/
    generate_slate


    ##################################
    ## Generate Repositories' docs  ##
    ##################################

    for REPO in "${REPOSITORIES[@]}"; do
        #obtain name of repo
        filename="${REPO##*/}"
        folder_name="${filename%.*}"

        #deleting repo folder
        echo "deleting ${folder_name}"
        rm -rf ${folder_name}

        #cloning repo in specific folder
        echo "cloning ${folder_name}"
        mkdir -v ${folder_name}
        git clone ${REPO} ${folder_name}

        #transforming .md files
        source scr/transform-folder.sh ${folder_name}
        generate_slate

        #deleting repo folder
        echo "deleting ${folder_name}"
        rm -rf ${folder_name}
    done

    ###########
    # Publish #
    ###########

    # publish all slate docs
   # source scr/deploy-slate-doc.sh $DEPLOY_OPTS
   # RET_VAL=$?

    # Upload templates to CDN
   # source scr/upload-templates.sh
   # RET_VAL=$?

    clean_slate

else
    echo "Not in master, skipping build"
fi

exit ${RET_VAL}