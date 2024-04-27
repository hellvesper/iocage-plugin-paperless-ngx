# iocage-plugin-onedev

Artifact files for OneDev iocage plugin

site: https://onedev.io
github: https://github.com/theonedev/onedev

The plugin script will install OneDev version 10.4.0 from official release 

To install:

- ssh to your TrueNAS or open **Shell** in Web UI
- download plugin `fetch https://raw.githubusercontent.com/hellvesper/iocage-plugin-onedev/master/onedev.json`
- launch installation `iocage fetch -P onedev.json -n onedev` where `onedev` - your plugin jail name.

After installation you can open OneDev using ip address or mDNS domain address which will equal jail name. For example above mDNS address will be `http:/onedev.local`

Note:

Plugin configured to use `DHCP`, so it will acquire new `IP` address from you router which will differ from your **NAS** IP
