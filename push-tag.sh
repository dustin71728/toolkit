#!/usr/bin/env bash

BRANCH_NAME="${1:-$(git rev-parse --abbrev-ref HEAD)}"

git push --follow-tags origin "$BRANCH_NAME"