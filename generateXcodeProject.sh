#!/bin/bash

set -e 

# clean swift package
swift package clean
rm -rdf .build/

# install dependencies
swift package update

# generate project
swift package generate-xcodeproj --xcconfig-overrides config.xcconfig

# open project
open *.xcodeproj
