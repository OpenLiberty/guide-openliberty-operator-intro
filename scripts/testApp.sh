#!/bin/bash
set -euxo pipefail
./mvnw -version

# Build the system/ app
./mvnw -ntp -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -q -pl system clean package liberty:create liberty:install-feature liberty:deploy

# Verifies that the system app is functional
./mvnw -ntp -pl system liberty:start
if curl "http://localhost:9080/health" | grep "UP" ; then exit $?; fi
if curl "http://localhost:9080/system/properties" | grep "os.name" ; then exit $?; fi
./mvnw -ntp -pl system liberty:stop

# Delete m2 cache after completion
rm -rf ~/.m2
