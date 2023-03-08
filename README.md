# ForemanNetbox

[<img src="https://opensourcelogos.aws.dmtech.cloud/dmTECH_opensource_logo.svg" height="21" width="130">](https://www.dmtech.de/)

This is a plugin for Foreman that introduces integration with [NetBox](https://netbox.readthedocs.io)

## Compatibility

| Netbox Version | Plugin Version |
| -------------- | -------------- |
| 2.8            | 1.0            |
| 2.11           | 1.1            |
| 3.3            | 1.2            |

## Installation

See [How_to_Install_a_Plugin](https://theforeman.org/manuals/2.3/index.html#6.1InstallaPlugin)
for how to install Foreman plugins.

The gem name is "foreman_netbox".



## Integration tests

The easiest way to start Netbox is to use [netbox-docker](https://github.com/netbox-community/netbox-docker). To run integration tests provide `FOREMAN_NETBOX_URL` and `FOREMAN_NETBOX_TOKEN` variables, eg.

```
$ FOREMAN_NETBOX_URL=http://0.0.0.0:8000 FOREMAN_NETBOX_TOKEN=0123456789abcdef0123456789abcdef01234567 bundle exec rake test:foreman_netbox
```

After installation of the plugin you can find these settings as well under Administer/Settings/Netbox tab.

You will find there as well a Netbox Orchestration Switch.

If the switch is enabled every change of a Foreman Hostobject will be synced with your netbox instance.

## Contributing

Fork and send a Pull Request. Thanks!

## Copyright

Copyright (c) 2019 dmTECH GmbH, [dmtech.de](https://www.dmtech.de/)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

