#!/bin/bash

deploy_directory=$(pwd)
set +o errexit
CHANGED_FILES=($(git diff --name-only $TRAVIS_COMMIT_RANGE | tr "\n" " " ))
echo "commit range: $TRAVIS_COMMIT_RANGE"

echo "changed files: $CHANGED_FILES"

#if [ $CHANGED_FILES == *"templates/ar-api.json"* ] || [ $CHANGED_FILES == *"templates/ea-api.json"* ]; then
if [[ "a" == "a" ]]; then
    openssl aes-256-cbc -K $encrypted_sdk_templates_key -iv $encrypted_sdk_templates_iv -in sdk_templates.enc -out sdk_templates -d
    chmod 600 sdk_templates
    eval `ssh-agent -s`
    ssh-add -D
    ssh-add sdk_templates
    git clone $repo_templates

    if [[ $CHANGED_FILES == *"templates/ar-api.json"* ]]; then
        echo "ar_api json modified"
        #git clone $repo_sdk_ar_lib
        openssl aes-256-cbc -K $encrypted_sdk_ar_typescript_library_key -iv $encrypted_sdk_ar_typescript_library_iv -in sdk_ar_typescript.enc -out sdk_ar_typescript -d
        chmod 600 sdk_ar_typescript
        ssh-add -D
        ssh-add sdk_ar_typescript
        git clone $repo_sdk_ar_lib
        #generate new library
        mkdir -p $deploy_directory/api_output/ar
        java -jar $SWAGGER_CODEGEN_CLI generate -l typescript-fetch -i $deploy_directory/templates/ar-api.json -t $deploy_directory/sdk-templates/typescript/v2.2.3-mod -o $deploy_directory/api_output/ar/ --additional-properties supportsES6=true

        cd sdk-ar-typescript-library
        git checkout master
        rm -rf $deploy_directory/sdk-ar-typescript-library/codegen
        mkdir $deploy_directory/sdk-ar-typescript-library/codegen
        cp -r $deploy_directory/api_output/ar/* $deploy_directory/sdk-ar-typescript-library/codegen
        git add .
        git commit -m "Auto generated"
        npm version minor
        git add .
        git push -u origin master
        cd $deploy_directory

    fi
    if [[ $CHANGED_FILES == *"templates/ea-api.json"* ]]; then
        echo "ea_api json modified"

        #update sdk-client-java
        openssl aes-256-cbc -K $encrypted_0f4123442544_key -iv $encrypted_0f4123442544_iv -in sdk_client_java.enc -out sdk_client_java -d
        chmod 600 sdk_client_java
        ssh-add -D
        ssh-add sdk_client_java
        git clone $repo_sdk_client_java
        # Add changes of swagger-codegen source code and templates
        cp -rf $deploy_directory/sdk-templates/java/v2.2.3-mod/templates/* $SWAGGER_CODEGEN_TMPL_DIR/Java/
        cp -rf $deploy_directory/sdk-templates/java/v2.2.3-mod/swagger-codegen/* $SWAGGER_CODEGEN_SOURCE_DIR
        pushd $SWAGGER_CODEGEN_DIR
        # Compile swagger-codegen with modified source code
        mvn clean install
        popd
        pushd $deploy_directory/sdk-client-java
        git checkout master
        rm -rf *
        java -jar $SWAGGER_CODEGEN_CLI generate -i $deploy_directory/templates/ea-api.json -l java --library=okhttp-gson --artifact-id sdk-client-java --group-id com.touchvie --invoker-package com.touchvie.sdk --model-package com.touchvie.sdk.model --api-package com.touchvie.sdk.api --git-repo-id sdk-client-java --git-user-id dive-tv -o $deploy_directory/sdk-client-java/ --additional-properties serializableModel=true,hideGenerationTimestamp=true
        git add .
        git commit -m "Auto generated"
        git add .
        git push -u origin master
        cd $deploy_directory
        source $deploy_directory/scr/git-version.sh

        openssl aes-256-cbc -K $encrypted_sdk_ea_typescript_key -iv $encrypted_sdk_ea_typescript_iv -in sdk_ea_typescript.enc -out sdk_ea_typescript -d
        chmod 600 sdk_ea_typescript
        ssh-add -D
        ssh-add sdk_ea_typescript
        git clone $repo_sdk_ea_lib
        #generate new library
        mkdir -p $deploy_directory/api_output/ea
        java -jar $SWAGGER_CODEGEN_CLI generate -l typescript-fetch -i $deploy_directory/templates/ea-api.json -t $deploy_directory/sdk-templates/typescript/v2.2.3-mod -o $deploy_directory/api_output/ea/ --additional-properties supportsES6=true
        cd sdk-ea-typescript-library
        git checkout master
        rm -rf $deploy_directory/sdk-ea-typescript-library/codegen
        mkdir $deploy_directory/sdk-ea-typescript-library/codegen
        cp -r $deploy_directory/api_output/ea/* $deploy_directory/sdk-ea-typescript-library/codegen
        npm version minor
        git add .
        git commit -m "Auto generated"
        git add .
        git push -u origin master
    fi


    #update sdk-client-java
    openssl aes-256-cbc -K $encrypted_0f4123442544_key -iv $encrypted_0f4123442544_iv -in sdk_client_java.enc -out sdk_client_java -d
    chmod 600 sdk_client_java
    ssh-add -D
    ssh-add sdk_client_java
    git clone $repo_sdk_client_java
    # Add changes of swagger-codegen source code and templates
    cp -rf $deploy_directory/sdk-templates/java/v2.2.3-mod/templates/* $SWAGGER_CODEGEN_TMPL_DIR/Java/
    cp -rf $deploy_directory/sdk-templates/java/v2.2.3-mod/swagger-codegen/* $SWAGGER_CODEGEN_SOURCE_DIR
    pushd $SWAGGER_CODEGEN_DIR
    # Compile swagger-codegen with modified source code
    mvn clean install
    popd
    pushd $deploy_directory/sdk-client-java
    git checkout master
    rm -rf *
    java -jar $SWAGGER_CODEGEN_CLI generate -i $deploy_directory/templates/ea-api.json -l java --library=okhttp-gson --artifact-id sdk-client-java --group-id com.touchvie --invoker-package com.touchvie.sdk --model-package com.touchvie.sdk.model --api-package com.touchvie.sdk.api --git-repo-id sdk-client-java --git-user-id dive-tv -o $deploy_directory/sdk-client-java/ --additional-properties serializableModel=true,hideGenerationTimestamp=true
    echo "call git commands"
    git add .
    git commit -m "Auto generated"
    git add .
    git push -u origin master
    echo "call git-version.sh"
    source $deploy_directory/scr/git-version.sh

fi
