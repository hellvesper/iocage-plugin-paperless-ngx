# iocage-plugin-paperless-ngx

Artifact files for Paperless-ngx iocage plugin

site: https://docs.paperless-ngx.com
github: https://github.com/paperless-ngx/paperless-ngx

The plugin script will install Paperless-ngx version 2.7.2 from official release 

#### To install:

- ssh to your TrueNAS or open **Shell** in Web UI
- download plugin `fetch https://raw.githubusercontent.com/hellvesper/iocage-plugin-paperless-ngx/master/paperless-ngx.json`
- launch installation `iocage fetch -P paperless-ngx.json -n paperless-ngx` where `paperless-ngx` - your plugin jail name.
    choose jail name carefully, it will your mDNS domain, like `paperless-ngx` -> `http://paperless-ngx.local`
- Setup mount points for **consume** dir and **data**, **media** dirs if needed.

You can mount dirs from FreeBSD terminal or TrueNAS terminal like this:
```sh
sudo iocage fstab -a your_paperless_jail_name /path/to/host/dir /mnt/host_dir nullfs rw 0 0
```
i.e. `sudo iocage fstab -a paperless-ngx /Storage/paperless/consume /mnt/consume nullfs rw 0 0`

Or in **TrueNAS** GUI: *Jails -> **your_jail_name** click arrow **>** -> Mount points*

Ensure that dirs has write permission

After installation you can open Paperless-ngx using ip address or mDNS domain address which will equal jail name. For example above mDNS address will be `http:/paperless-ngx.local`

#### Note

Plugin configured to use `DHCP`, so it will acquire new `IP` address from you router which will differ from your **NAS** IP


#### Description

Paperless-ngx is a community-supported open-source document management system that transforms your physical documents into a searchable online archive so you can keep, well, less paper.

##### Features

- **Organize and index** your scanned documents with tags, correspondents, types, and more.
- _Your_ data is stored locally on _your_ server and is never transmitted or shared in any way.
- Performs **OCR** on your documents, adding searchable and selectable text, even to documents scanned with only images.
- Utilizes the open-source Tesseract engine to recognize more than 100 languages.
- Documents are saved as PDF/A format which is designed for long term storage, alongside the unaltered originals.
- Uses machine-learning to automatically add tags, correspondents and document types to your documents.
- Supports PDF documents, images, plain text files, Office documents (Word, Excel, Powerpoint, and LibreOffice equivalents)[1](https://docs.paperless-ngx.com/#fn:1) and more.
- Paperless stores your documents plain on disk. Filenames and folders are managed by paperless and their format can be configured freely with different configurations assigned to different documents.
- **Beautiful, modern web application** that features:
    - Customizable dashboard with statistics.
    - Filtering by tags, correspondents, types, and more.
    - Bulk editing of tags, correspondents, types and more.
    - Drag-and-drop uploading of documents throughout the app.
    - Customizable views can be saved and displayed on the dashboard and / or sidebar.
    - Support for custom fields of various data types.
    - Shareable public links with optional expiration.
- **Full text search** helps you find what you need:
    - Auto completion suggests relevant words from your documents.
    - Results are sorted by relevance to your search query.
    - Highlighting shows you which parts of the document matched the query.
    - Searching for similar documents ("More like this")
- **Email processing**[1](https://docs.paperless-ngx.com/#fn:1): import documents from your email accounts:
    - Configure multiple accounts and rules for each account.
    - After processing, paperless can perform actions on the messages such as marking as read, deleting and more.
- A built-in robust **multi-user permissions** system that supports 'global' permissions as well as per document or object.
- A powerful workflow system that gives you even more control.
- **Optimized** for multi core systems: Paperless-ngx consumes multiple documents in parallel.
- The integrated sanity checker makes sure that your document archive is in good health.