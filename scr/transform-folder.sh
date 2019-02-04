#!/bin/bash

result=$( find $1 -name '*.md' )
for i in ${result}; do
    #copying .md files in slate folder
    cp $i ${SLATE_INC_DIR}/

    #rename files
    mv ${SLATE_INC_DIR}/${i##*/} ${SLATE_INC_DIR}/_${i##*/}

    #transforming files in specific markdown
    python3 scr/transform_docs.py ${SLATE_INC_DIR}/_${i##*/}
    if [ $? -ne 0 ]; then
        echo "Error transforming $1 paths document to slate format"
        exit 1
    fi

    #if file is README.md, we rename it to repo´s name
    if [ $i == ${folder_name}/README.md ]; then
        mv ${SLATE_INC_DIR}/_README.md ${SLATE_SRC_DIR}/${folder_name}.html.md 
    fi
done


