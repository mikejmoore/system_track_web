#!/bin/bash
cd "$APP_HOME"

echo "================ Waiting for MySQL's port to respond"

/bin/bash /wait_for_port.sh system-track-accounts 3000
/bin/bash /wait_for_port.sh system-track-machines 3000

echo "================ Migrating Openlogic database"
rake db:create db:migrate

# echo "================ Starting memcache - oh no, two long running processes in the same container."
# memcached -d -uroot


rails s -d Puma -b 0.0.0.0 -p 3000
tail -100f ./log/production.log
