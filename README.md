## Nagios Discord Notifications

This simply takes Nagios environment variables ([see here](https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/3/en/macrolist.html)), and builds a quick JSON block to send to a Discord webhook.

Fill out the two empty variables at the top of the scripts, and place them in your Nagios plugins directory.

You'll want to add some commands, to be able to call the notify scripts, say in your `commands.cfg`:

```
define command {
  command_name notify-host-by-discord
  command_line /usr/lib/nagios/plugins/send-discord-host.sh
}

define command {
  command_name notify-service-by-discord
  command_line /usr/lib/nagios/plugins/send-discord-service.sh
}
```

Also ensure there's a separate "discord" contact, or similar in your `contacts.cfg`:

```
define contact {
  contact_name discord
  use discord-contact
  alias Discord Contact
  email some@example.com
}
```

Update your `contactgroup` as well:

```
define contactgroup {
  contactgroup_name everyone
  alias Everyone
  members alice,bob,discord
}
```

Note, if you use contact groups extensively, you could also add that to the script, and then alert groups/roles with `@mentions` in your alerts.

The last thing to worry about adding, is your base contact, likely in your `templates.cfg`:

```
define contact {
  name discord-contact
  service_notification_period 24x7
  host_notification_period 24x7
  service_notification_options w,u,c,r,f,s
  host_notification_options d,u,r,f,s
  service_notification_commands notify-service-by-discord
  host_notification_commands notify-host-by-discord
  register 0
}
```
