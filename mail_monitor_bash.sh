#!/bin/sh

#PATH=/bin:/sbin:/usr/bin:/usr/bin
#export PATH

LOG_DIR=/var/log/maillog
CNT_MAIL_LOST_CONNECTION=0
#閾値の設定
THRESHOLD=10
SAMPLE_MAILLOG=""
PATTERN="[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}"


#lost connection mail in the past 5 mins
for i in {1..5}
do
    SAMPLE_TIME=`date -d "${i} minutes ago" +%H:%M`
    CURRENT_CNT_MAIL_LOST_CONNECTION=($(cat "$LOG_DIR" | grep "$SAMPLE_TIME" | grep "lost connection" | wc -l))
    CNT_MAIL_LOST_CONNECTION=$(($CNT_MAIL_LOST_CONNECTION+$CURRENT_CNT_MAIL_LOST_CONNECTION))
    #メールアドレスを伏字にする
    SAMPLE_MAIL_LOST_CONNECTION=$(cat /var/log/maillog | grep "Jun 13 16:45" | grep "lost connection" | sed -e "s/[^,@]*@[^,]*/xxx@xxxxxx.xx/g")
    SAMPLE_MAILLOG+="$SAMPLE_MAIL_LOST_CONNECTION"
done

if [ $CNT_MAIL_LOST_CONNECTION -ge $THRESHOLD ]; then
    LOST_CONNECTION_STATUS=$'lost connection mail over threshold\ncount:'
    LOST_CONNECTION_STATUS+=$CNT_MAIL_LOST_CONNECTION
    MAIL_BODY=$'From: xxxx@xxxx.co.jp\nTo: xxxx@xxxx.co.jp\nSubject: Postfix lost connection check in the past 5mins\n\n'
    nl=$'\n'
    MAIL_BODY+="$LOST_CONNECTION_STATUS${nl}"
    MAIL_BODY+="$SAMPLE_MAILLOG"
    echo $MAIL_BODY
    echo "$MAIL_BODY" | /sbin/sendmail -i -t
else
    LOST_CONNECTION_STATUS='lost connection mail under threshold\ncount:'
    LOST_CONNECTION_STATUS+=$CNT_MAIL_LOST_CONNECTION
fi