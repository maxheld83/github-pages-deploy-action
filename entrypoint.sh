#!/bin/sh -l

if [ -z "$ACCESS_TOKEN" ]
then
  echo "You must provide the action with a GitHub Personal Access Token secret in order to deploy."
  exit 1
fi

if [ -z "$BRANCH" ]
then
  echo "You must provide the action with a branch name it should deploy to, for example gh-pages or docs."
  exit 1
fi

if [ -z "$FOLDER" ]
then
  echo "You must provide the action with the folder name in the repository where your compiled page lives."
  exit 1
fi

if [ -z "$COMMIT_EMAIL" ]
then
  COMMIT_EMAIL="${GITHUB_ACTOR}@users.noreply.github.com"
fi

if [ -z "$COMMIT_NAME" ]
then
  COMMIT_NAME="${GITHUB_ACTOR}"
fi

## Initializes the repository path using the access token.
REPOSITORY_PATH="https://${ACCESS_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" && \

# Installs Git.
apt-get update && \
apt-get install -y git && \

# Directs the action to the the Github workspace.
cd $GITHUB_WORKSPACE && \

# Configures Git and checks out the base branch.
git init && \
git config --global user.email "${COMMIT_EMAIL}" && \
git config --global user.name "${COMMIT_NAME}" && \
git checkout "${BASE_BRANCH:-master}" && \

# Builds the project if a build script is provided.
echo "Running build scripts... $BUILD_SCRIPT"
eval "$BUILD_SCRIPT"

# Commits the data to Github.
echo "Deploying to GitHub..." && \
git add -f $FOLDER && \
git commit -m "Deploying to ${BRANCH} - $(date +"%T")" && \
git push $REPOSITORY_PATH `git subtree split --prefix $FOLDER master`:$BRANCH --force && \
echo "Deployment Succesful!"