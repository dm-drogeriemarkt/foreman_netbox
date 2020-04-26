# ForemanNetbox

This is a plugin for Foreman that introduces integration with [NetBox](https://netbox.readthedocs.io)

## Installation

See [How_to_Install_a_Plugin](http://projects.theforeman.org/projects/foreman/wiki/How_to_Install_a_Plugin)
for how to install Foreman plugins

## Integration tests

The easiest way to start Netbox is to use [netbox-docker](https://github.com/netbox-community/netbox-docker). To run integration tests provide `FOREMAN_NETBOX_URL` and `FOREMAN_NETBOX_TOKEN` variables, eg.

```
$ FOREMAN_NETBOX_URL=http://0.0.0.0:8000 FOREMAN_NETBOX_TOKEN=0123456789abcdef0123456789abcdef01234567 bundle exec rake test:foreman_netbox
```

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

