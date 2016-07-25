#! bash
# Sync a fork of a repository to keep it up-to-date with the upstream
# repository.
# https://help.github.com/articles/syncing-a-fork/

# Fetch the branches and their respective commits from the upstream repository.
# Commits to master will be stored in a local branch, upstream/master.
git fetch upstream

# Check out your fork's local master branch.
git checkout master

# Merge the changes from upstream/master into your local master branch. This 
# brings your fork's master branch into sync with the upstream repository, 
# without losing your local changes.
git merge upstream/master

echo Sync complete. Please push your changes!

