# Announce on startup
@reboot root besic-announce
# Update deployment info hourly
@hourly root besic-update
# Sent heartbeat every minute
* * * * * root besic-heartbeat
