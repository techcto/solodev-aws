#!/bin/bash
berks update
berks package cookbooks.tar.gz
aws s3 cp cookbooks.tar.gz s3://solodev-aws-ha
rm -Rf cookbooks.tar.gz