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

if [[ "$NAGIOS_NOTIFICATIONTYPE" == "PROBLEM" ]]; then
  clr=$clr_red
fi
if [[ "$NAGIOS_NOTIFICATIONTYPE" == "RECOVERY" ]]; then
  clr=$clr_grn
fi

# Our internal nagios URL
nagios_url="https://${nagios_domain}/cgi-bin/nagios3/extinfo.cgi?type=2&host=${NAGIOS_HOSTNAME}&service=${NAGIOS_SERVICEDESC}"

# Replace spaces with + because discord doesn't like this
nagios_url=$(echo "${nagios_url}" | sed s/\ /\+/g)

# totals
hosts_total=$(( $NAGIOS_TOTALHOSTSUP + $NAGIOS_TOTALHOSTSDOWN ))
services_total=$(( $NAGIOS_TOTALSERVICESOK + $NAGIOS_TOTALSERVICEPROBLEMS ))

json_data="{
  \"username\": \"Nagios\",
  \"embeds\": [
    {
      \"title\": \"Nagios alert: **${NAGIOS_HOSTNAME} - ${NAGIOS_SERVICEDESC}**: ${NAGIOS_SERVICESTATE} (${NAGIOS_NOTIFICATIONTYPE})\",
      \"description\": \"\`${NAGIOS_HOSTADDRESS}\`\n\",
      \"url\": \"${nagios_url}\",
      \"color\": ${clr},
      \"timestamp\": \"${NAGIOS_SHORTDATETIME}\",
      \"fields\": [
        {
          \"name\": \"Service Output\",
          \"value\": \"${NAGIOS_SERVICEOUTPUT}\"
        }
      ],
      \"footer\": {
        \"text\": \"${NAGIOS_TOTALHOSTSUP}/${hosts_total} hosts up, ${NAGIOS_TOTALSERVICESOK}/${services_total} services ok\"
      }
    }
  ]
}"

curl -v -H 'Content-Type: application/json' "${webhook_url}" -d "$json_data" &> /tmp/send-discord-service.log
exit $?
