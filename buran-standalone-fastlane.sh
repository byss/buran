#!/bin/bash

exec "~/.fastlane/bin/bundle/bin/bundle-env" "$(dirname $0)/buran.rb" "$@"
