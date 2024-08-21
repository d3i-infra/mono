# Eyra Mono D3I

This repository contains the D3I fork of eyra/mono (containing the SaaS product Next).
This repository is used to deploy Next on Surf research cloud.

The changes with the upstream are:

- No footer
- No brand logo
- Changed the `GoogleSignIn` module. Google sign in is not used anymore. Pressign sign in, will sign you in with a default hardcoded account. See `google_sign_in.ex` and `./google_sign_in/plug.ex`.


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
