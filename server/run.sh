#!/bin/sh

printenv

echo "** Starting Krates Master version `cat VERSION` **"
puma -p ${PORT:-9292} -e production