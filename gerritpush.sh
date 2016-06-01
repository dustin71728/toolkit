#!/bin/bash
branch=$(git rev-parse --abbrev-ref HEAD)
commit=HEAD
if [ $# -eq 2 ]
then
	branch=$1
	commit=$2
elif [ $# -eq 1 ]
then
	branch=$1
fi

echo "Pull and rebase first."
echo
git pull --rebase
echo "Push to gerrit use branch:"$branch" commit-id: "$commit
echo
if [ $? -eq 0 ]
then
	git push origin $commit:refs/for/$branch
fi