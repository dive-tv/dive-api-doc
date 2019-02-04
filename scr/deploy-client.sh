#!/bin/bash

client_name=$1

load_api_doc_info() {
	echo "Loading dive-api-doc current commit info..."
	pushd $TRAVIS_BUILD_DIR
	commit_title=$(git log -n 1 --format="%s" HEAD)
	commit_hash=$(git log -n 1 --format="%H" HEAD)
	commit_message="publish: ${commit_title}"
	commit_message="${commit_message}"$'\n\n'"generated from commit ${commit_hash}"
	deploy_branch=master
	repo=origin
	popd
}

incremental_deploy() {
	deploy_directory=$(pwd)

	#make deploy_branch the current branch
	git symbolic-ref HEAD refs/heads/${deploy_branch}

	#put the previously committed contents of deploy_branch into the index
	git --work-tree "$deploy_directory" reset --mixed --quiet
	git --work-tree "$deploy_directory" add --all

	set +o errexit
	diff=$(git --work-tree "$deploy_directory" diff --exit-code --quiet HEAD --)$?
	set -o errexit
	case $diff in
		0)
			echo No changes to files in $deploy_directory. Skipping commit.
			;;
		1)
			commit+push
			;;
		*)
			echo git diff exited with code $diff. Aborting. Staying on branch $deploy_branch so you can debug. To switch back to master, use: git symbolic-ref HEAD refs/heads/master && git reset --mixed >&2
      		return $diff
      		;;
  	esac
}

commit+push() {
	set_user_id
	deploy_directory=$(pwd)

	echo "Commiting '${deploy_directory}'..."
	echo "#git --work-tree "$deploy_directory" commit -m "$commit_message""
	git --work-tree "${deploy_directory}" commit -m "${commit_message}"

	echo "Pushing '${deploy_directory}' content to '${repo}/${deploy_branch}'..."
	#--quiet is important here to avoid outputting the repo URL, which may contain a secret token
	echo "#git push --quiet ${repo} ${deploy_branch}"
	git push --quiet ${repo} ${deploy_branch}
}

set_user_id() {
	echo "Setting user config..."
	git config user.name "$COMMIT_AUTHOR_USERNAME"
	git config --global user.email "$COMMIT_AUTHOR_EMAIL"
	git config user.email "$COMMIT_AUTHOR_EMAIL"
}

# add Github's deploy key by using Travis's stored variables to decrypt key
add_deploy_key() {
	if [[ -z ${TRAVIS} ]]; then
		echo "Local execution..."
	else
		echo "Adding '${TRAVIS_BUILD_DIR}/deploy-${1}-key' key to ssh-agent..."
		pushd $TRAVIS_BUILD_DIR

   		eval `ssh-agent -s`
		ssh-add -D
    	ssh-add deploy-${1}-key

		popd
	fi
}

main() {
	load_api_doc_info


if [ $client_name = "java" ] || [ $client_name = "typescript" ]; then
	main
else
	echo $"Unsupported client: $client_name"
fi