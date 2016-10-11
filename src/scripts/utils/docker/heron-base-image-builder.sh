#!/bin/bash
wget -O DOCKERFILE https://raw.githubusercontent.com/hdinsight/HeronOnHDInsight/master/src/scripts/utils/docker/HeronBaseImageDOCKERFILE
docker build -t "heron:latest" -f DOCKERFILE .
