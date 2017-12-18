#!/bin/bash

exec "/usr/local/lib/fastlane_lib/bundle/bin/bundle-env" "$(dirname $0)/buran.rb" "$@"
