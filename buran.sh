#!/bin/bash

exec "~/.fastlane/bin/fastlane_lib/bundle/bin/bundle-env" "$(dirname $0)/buran.rb" "$@"
