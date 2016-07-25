#! bash

# Configuring a remote for a fork

# https://help.github.com/articles/configuring-a-remote-for-a-fork/

# To sync changes you make in a fork with the original repository, you must
# configure a remote that points to the upstream repository in Git.

# usage example: sh git_fork_config.sh "https://github.com/example/repo.git"

# List the current configured remote repository for your fork.
git remote -v | grep --regexp="^upstream $1"
if [ $? = 0 ]; then
    err=$?
    echo "Upstream seems to have been configured already"
    exit $err
fi

# Specify a new remote upstream repository that will be synced with the fork.
git remote add upstream $1

# Verify the new upstream repository you've specified for your fork.
git remote -v
git remote -v | grep --regexp="^upstream $1"
if [ $? -gt 0 ]; then
    err=$?
    echo "Failed!"
    exit $err
fi

