#!/bin/bash

# This is run in the context of the Dockerfile
RAILS_ENV=production RACK_ENV=production NODE_ENV=production bundle exec bin/webpack

