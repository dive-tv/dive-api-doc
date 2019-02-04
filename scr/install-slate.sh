#!/bin/bash

pushd $TMP_DIR

git clone --chmod=+x https://github.com/dive-tv/slate

rm -rf slate/Gemfile.lock

popd