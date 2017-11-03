#!/bin/bash

protoc -I=./proto/ -o./proto/proto.pb `find ./ -name '*.proto'`
