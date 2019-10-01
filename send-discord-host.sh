#!/bin/bash

# Nagios domain, used for generating our URLs
nagios_domain=""

# Webhook URL, change this to your channels URL
webhook_url="https://discordapp.com/api/webhooks/id/token"

# Some colours, change them if you like
clr_red=13632027
clr_yel=16098851
clr_grn=8311585

# pick colour
clr=$clr_yel

if [[ "$NAGIOS_NOTIFICATIONTYPE" = "PROBLEM" ]]; then
  clr=$clr_red
fi
if [[ "$NAGIOS_NOTIFICATIONTYPE" = "RECOVERY" ]]; then
  clr=$clr_grn
fi

# Our internal nagios URL
nagios_url="https://${nagios_domain}/cgi-bin/nagios3/extinfo.cgi?type=1&host=${NAGIOS_HOSTNAME}"

# totals
hosts_total=$(( $NAGIOS_TOTALHOSTSUP + $NAGIOS_TOTALHOSTSDOWN ))
services_total=$(( $NAGIOS_TOTALSERVICESOK + $NAGIOS_TOTALSERVICEPROBLEMS ))

json_data="{
  \"username\": \"Nagios\",
  \"embeds\": [
    {
      \"title\": \"Nagios alert: **${NAGIOS_HOSTNAME}** ${NAGIOS_HOSTSTATE} (${NAGIOS_NOTIFICATIONTYPE})\",
      \"description\": \"\`${NAGIOS_HOSTADDRESS}\`\",
      \"url\": \"${nagios_url}\",
      \"color\": ${clr},
      \"timestamp\": \"${NAGIOS_SHORTDATETIME}\",
      \"fields\": [
        {
          \"name\": \"Host Output\",
          \"value\": \"${NAGIOS_HOSTOUTPUT}\"
        }
      ],
      \"footer\": {
        \"text\": \"${NAGIOS_TOTALHOSTSUP}/${hosts_total} hosts up, ${NAGIOS_TOTALSERVICESOK}/${services_total} services ok\",
        \"icon_url\": \"\"
      }
    }
  ]
}"

curl -v -H 'Content-Type: application/json' "${webhook_url}" -d "$json_data" &> /tmp/send-discord-host.log
exit $?
