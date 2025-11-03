# Eyra Mono D3I

This repository contains the D3I fork of eyra/mono (containing the SaaS product Next).
This repository is used to deploy Next on Surf research cloud. Only use this repository as a catalog item on Surf Research Cloud!

The changes with the upstream are:

- No footer
- No brand logo
- Changed login
- support for Surf Research Drive

## Surf Research Drive

To use Surf Research Drive you need to configure an app, this will result in a password that you can use to store the data.

If you want donated data to be stored on Surf Research Drive set these environment variables when deploying Next:

| Variable Name                                   | Example Value                                  | Description |
|------------------------------------------------|------------------------------------------------|-------------|
| `STORAGE_BUILTIN_SURF_RESEARCH_DRIVE_USER`      | `1234565@intitution.com`                       | Your Surf Drive user account |
| `STORAGE_BUILTIN_SURF_RESEARCH_DRIVE_PASSWORD`  | `ASDASD-QWEQWE-ZXCZXC`                         | Auto generated password |
| `STORAGE_BUILTIN_SURF_RESEARCH_DRIVE_URL`       | `https://WebDAVUrl.nl/remote.php/etc/etc`      | WebDAV Url |
| `STORAGE_BUILTIN_SURF_RESEARCH_DRIVE_FOLDER`    | `foler name`                                   | folder within SURF Research Drive where files will be stored |


# Eyra Mono

Codebase used by the Next platform, which is also available for self hosting (see [bundles](https://github.com/eyra/mono#bundles)).

## Projects

* Core
* Banking Proxy

## Core

Project implementing a SaaS platform based on interlinked modules called Systems. These Systems are composed into Bundles to form specific deployments. Deployments use config to expose a set of features (web pages) to the public.

### Systems (shortlist)

* Banking
* Bookkeeping
* Budget
* Advert
* Assignment
* Lab
* Questionnaire
* Pool
* ..

### Bundles

* Next

Primary bundle with all features available. Next is configured and hosted by Eyra.

* Self

Customizable bundle that can be used to run Core on one of your own servers.
See [SELFHOSTING.md](SELFHOSTING.md) for detailed instructions.


## Banking Proxy

Project implementing a proxy server used in Banking (core/systems/banking). It allows for a limited and secure interaction with a banking account.


## Using TLS between app and database
TLS peer verification is possible between the elixir app and the postgres database. By default this is enabled. To disable it, set `DB_TLS_VERIFY=none` in the docker compose file.
To make sure everything is set up correctly, you can generate the certs using the following commands:
```bash
./postgres_ssl/generate.sh
```
This command will generate the certs in the `postgres_ssl` directory. The certs are generated using the `openssl` command. The custom docker file for the postgres image will copy the certs to the correct location in the image.
