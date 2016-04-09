#!/bin/sh

#  StartAria2c.sh
#  WebSocket
#
#  Created by xjbeta on 16/2/9.
#  Copyright © 2016年 xjbeta. All rights reserved.
process=`ps aux | grep aria2D_aria2c | grep -v grep`;
if [ "$process" == "" ]; then
/Applications/aria2D.app/Contents/Resources/aria2D_aria2c --conf-path="/Applications/aria2D.app/Contents/Resources/aria2.conf" --dir="$HOME/Downloads/" -c -D
fi
