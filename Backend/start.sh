#!/bin/bash

uwsgi --socket 0.0.0.0:8085 --protocol=http -w main:app &  
