#!/bin/bash
cd /home/pi/rpisentiment
R --no-restore --no-save --args "#bigdata" 100 < RunTwitterSentiment.r
cd

