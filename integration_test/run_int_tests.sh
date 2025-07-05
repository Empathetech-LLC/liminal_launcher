#!/usr/bin/env bash

set -e

## Setup ##

project_dir="/Users/mwaldron/repos/flutter/liminal_launcher"
device=""

# Gather flag variables
while [[ "$1" != "" ]]; do
  case $1 in
    -d ) shift
               device="-d $1"
               ;;
    -p ) shift
              project_dir="$1"
              ;;
    * ) echo "Invalid input. Aborting."; exit 1
  esac
  shift
done

## Tests ##

flutter drive --driver="$project_dir/test_driver/integration_test_driver.dart" --target="$project_dir/integration_test/test.dart" $device
