#!/bin/bash -l

set -eux

my_branch=${GITHUB_REF#refs/heads/}
my_branch_RE=$(echo "$my_branch" | sed -e 's/\([\/()]\)/\\\1/g')

my_project=${GITHUB_REPOSITORY#*/}

if [ "$my_branch" = master ]; then
    # landing, return to standard commented out hint
    sed -i -e "/^@Library(value='${my_project}@/s/\(^@Library(value='${my_project}@\).*\('.*\)$/\/\/\1my_branch_name\2/" Jenkinsfile
    exit 0
fi

if grep "^@Library(value='${my_project}@${my_branch}') _" Jenkinsfile; then
    # already set, nothing to do
    exit 0
fi

if grep "^@Library(value='${my_project}@" Jenkinsfile; then
    # set to something else set, change it
    sed -i -e "/^@Library(value='${my_project}@/s/\(${my_project}\).*\"/\1${my_branch_RE}'/" Jenkinsfile
    exit 0
fi

# not set at all, add it
sed -i -e "s/^\/\/\(@Library(value='${my_project}@\)my_branch_name\(') _\)/\1${my_branch_RE}\2/" Jenkinsfile

exit 0
