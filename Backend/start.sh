#!/bin/bash

pid=`ps -ef | grep uwsgi | awk {'print $2'} | head -n 1`
echo "Existing PID $pid"
kill -9 $pid

echo "STARTING..."
uwsgi --socket 0.0.0.0:8085 --protocol=http -w main:app &  
