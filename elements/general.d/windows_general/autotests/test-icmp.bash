#!/bin/bash
if ping -c 100 ${IMG_VM_IP} &> /dev/null
then
  info_out "ICMP answer found. Machine is running."
  exit 0
else
  err_out "Machine is unacessible. ICMP unavailable."
  exit 1
fi