#!/bin/bash
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
set -xe

# check required env
set -u
echo $local_ip
set +u

touch /var/log/rtpengine.log

service cron start
rsyslogd

min_port=${min_port:-20000}
max_port=${max_port:-40000}
log_level=${log_level:-6} # [0-7] 7:debug, 6:info, 5:notice
ng_port=${ng_port:-7890}
cli_port=${cli_port:-7891}
http_port=${http_port:-7892}
delete_delay=${delete_delay:-10}
max_sessions=${max_sessions:-8000}
recording_dir=${recording_dir:-/var/log/recording}

RUN_PARAMS="-p /var/run/rtpengine.pid \
-n $local_ip:$ng_port \
-c $local_ip:$cli_port \
-m $min_port -M $max_port  \
-t 0 \
--delete-delay=$delete_delay \
--max-sessions=$max_sessions \
--listen-http=$http_port \
--log-facility=local0 \
-L $log_level -f \
"

if [[ "$enable_recording" == "yes" ]]; then
mkdir -p $recording_path

RUN_PARAMS="$RUN_PARAMS \
--recording-dir=$recording_dir \
--recording-method=pcap \
--recording-format=eth \
"
fi

if [[ "$gdb_debug" == "yes" ]]; then
    bash
    exit
fi

exec rtpengine $RUN_PARAMS
