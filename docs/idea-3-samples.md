# Idea 3: Samples shells

## Main idea

The repository will contains `apps` and `mfes` (see distinction here Confluence doc in SP TDR front), common/shared npm `packages` and also `samples` (which will in fact be only shells).

These `samples` will have a real dependency (in `package.json`) to their `apps/*` or `mfes/*`, this way:

  - They will also be bumped & published when related `apps` / `mfe` is bumped
  - Will appear in releases
  - Will also be seend as "published" by the GH Action

Moreover samples are not tied to a single MFE or WL App, in the future we could imagine a sample using several MFE together.

Package naming convention will be `@<mainTopic>/<topic>-<mfe|app|sample>`, like:

- `@sp/form-app`
- `@sp/card-mfe`
- `@sp/form-sample`


## Refactoring on Shell & dependencies

Same as "[Idea 2](./idea-2-pairing.md)"

## Repository structure


- `/packages`: Contains all common packages
  - `/packages/frontend-monitoring`: Datadog (Sentry?) stuff to enable or disable monitoring
  - `/packages/dev-drawer`: Component customisable to chang eon the fly the custom props
  - `/packages/msw-scenarios`: Lib to enable (with associated scenario) or disabled MSW
  - `/packages/sp-contact-form`: Contact form package used by both SP Card and SP Details Page
- `/apps`
  - `/apps/form`: WL App Form to add or edit a SP
  - `/apps/details-page`: WL App Details Page of a SP
- `/mfes`
  - `/mfe/card`: MFE Card to disply SP incentive
- `/samples`
  - `/samples/form`: Shell in charge of `@sp/mfe-form` loading
  - `/samples/card`: Shell in charge of `@sp/mfe-card` loading
  - `/samples/details-page`: Shell in charge of `@sp/mfe-details-page` loading

## Local development

Convention:

- Samples will use `800x` ports, one per sample (8001, 8002, 8003...)
- Apps/MFE will use `700x` ports, one per MFE (7001, 7002, 7003...)

Local `.env` files (not versionned) take care of the spread (`PUBLIC_PATH`, remte entry url).

TODO: Check how to configure turborepo to not run "dev" on linked workspace npm packages but the "build" command

```
// See https://turbo.build/repo/docs/core-concepts/monorepos/filtering#include-dependencies-of-matched-workspaces
"dev:form": "turbo run dev --filter='@sp/form-shell...'", // This run the "dev" command in the shell and all its local workspace dependencies, thus the MFEs
"dev:card": "turbo run dev --filter='@sp/card-shell...'",
"dev:details-page": "turbo run dev --filter='@sp/details-page-shell...'",
```

## CI Build & Deploy

Reminder: try to stick to `/assets/{apps,mfes}/{identifier}/{version}/{client,server}/remoteEntry.js` path

### AWS Architecture

#### Dev S3 bucket

- `/samples`
  - `/samples/form/`: Contains sample (shell) source code of `main` branch
  - `/samples/card/`: Contains sample (shell) source code of `main` branch
  - `/samples/details-page/`: Contains sample (shell) source code of `main` branch
- `/<sha1>`
  - `/<sha1>/samples/form/`: Contains sample (shell) source code for a specific PR
  - `/<sha1>/samples/card/`: Contains sample (shell) source code for a specific PR
  - `/<sha1>/samples/details-page/`: Contains sample (shell) source code a specific PR
- `/assets/apps/<appOrMfeName>/vX`
  - `/assets/apps/form/v0`: Contains Form (micro-frontend) App source code for v0 major, for `main` branch
  - `/assets/mfe/card/v0`: Contains card MFE source code for v0 major, for `main` branch
  - `/assets/apps/details-page/v0`: Contains Details Page (micro-frontend) App source code for v0 major, for `main` branch
- `/<sha1>/assets/apps/<appOrMfeName>/vX`
  - `/<sha1>/assets/apps/form/v0`: Contains Form (micro-frontend) App source code for v0 major for a specific PR
  - `/<sha1>/assets/mfe/card/v0`: Contains card MFE source code for v0 major for a specific PR
  - `/<sha1>/assets/apps/details-page/v0`: Contains Details Page (micro-frontend) App source code for v0 major for a specific PR

Apps/MFEs:
- https://initiative.slug-foo-dev.example.com/assets/apps/form/v0/client/remoteEntry.js
- https://initiative.slug-foo-dev.example.com/assets/apps/details-page/v0/client/remoteEntry.js
- https://initiative.slug-foo-dev.example.com/assets/mfes/card/v0/client/remoteEntry.js
- https://initiative.slug-foo-dev.example.com/cfe9e48906dd99d49224751cb40fad44cb43174d/assets/apps/form/v0/client/remoteEntry.js

Samples (Shells):
- https://initiative.slug-foo-dev.example.com/samples/form/
- https://initiative.slug-foo-dev.example.com/samples/details-page/
- https://initiative.slug-foo-dev.example.com/samples/card/
- https://initiative.slug-foo-dev.example.com/cfe9e48906dd99d49224751cb40fad44cb43174d/samples/form/

🚨: Cloudfront function for redirection may have to be tweaked to achieve this properly

#### Preview S3 bucket

- `/samples`
  - `/samples/form/`: Contains sample (shell) source code of latest prerelease or release
  - `/samples/card/`: Contains sample (shell) source code of latest prerelease or release
  - `/samples/details-page/`: Contains sample (shell) source code of latest prerelease or release
- `/assets/apps/<appOrMfeName>/vX`
  - `/assets/apps/form/v0`: Contains Form (micro-frontend) App source code for latest major
  - `/assets/mfe/card/v0`: Contains card MFE source code for latest major
  - `/assets/apps/details-page/v0`: Contains Details Page (micro-frontend) App source code for latest major

Apps/MFEs:
- https://initiative.slug-foo-preview.example.com/assets/apps/form/v0/client/remoteEntry.js
- https://initiative.slug-foo-preview.example.com/assets/apps/details-page/v0/client/remoteEntry.js
- https://initiative.slug-foo-preview.example.com/assets/mfes/card/v0/client/remoteEntry.js

Samples (Shells):
- https://initiative.slug-foo-preview.example.com/samples/form/
- https://initiative.slug-foo-preview.example.com/samples/details-page/
- https://initiative.slug-foo-preview.example.com/samples/card/

🚨: Cloudfront function for redirection may have to be tweaked to achieve this properly

#### Live S3 bucket

- `/assets/apps/<appOrMfeName>/vX`
  - `/assets/apps/form/v0`: Contains Form (micro-frontend) App source code for latest major
  - `/assets/mfe/card/v0`: Contains card MFE source code for latest major
  - `/assets/apps/details-page/v0`: Contains Details Page (micro-frontend) App source code for latest major

Apps/MFEs:
- https://initiative.slug-foo-live.example.com/assets/apps/form/v0/client/remoteEntry.js
- https://initiative.slug-foo-live.example.com/assets/apps/details-page/v0/client/remoteEntry.js
- https://initiative.slug-foo-live.example.com/assets/mfes/card/v0/client/remoteEntry.js

-> No samples on Live

### Workflow

Upon publish (either pre-release or release) CircleCI will receive (as JSON) the published package (see section below), for apps, mfes and also samples (shells).

We know that either ALL packages are in pre-release (`x.y.z-pre.n`), or ALL of them are in release (`x.y.z`).

#### Targeted environment

This distinction in version numbers allows us to determine the tageted environment, and if we must include self hosted shell:

- `-pre` is detected:
  - Preview environment with self hosted shell
- `-pre` is NOT detected
  -  Live environment **without** self hosted shell
  -  Preview environment with self hosted shell (to be synced with live env)

#### Targeted mfe

Provided published packages name allows us to determine:
- Which MFE must be built (and deployed)
- Which Shell must be built (depending on targeted environment, see above)

Steps are, for each publised packages (mfe):

- Run the "build" for each provided published package
  - Use appropriate env context (see section related to env vars below)
  - Define the remoteEntry url depending on published MFE (<-- hard part)
    - !!! Have to let turbo handle dependencies build for package but exclude apps/mfe dependencies, something like:
      - `pnpm run build --filter='!@sp/mfe-card' --filter='@sp/shell-foo'` // Build the shell & linked internal packages but not the MFE
- Determine path to associated `dist/` folder(s) (see [section](../README.md#miscellaneous) with the `pnpm ls -r --depth -1 --json` command)
  - Push dist folders to appropriated aws S3 bucket folder (samples, apps, mfes, vX etc...)

**Good to know**

```
# List all projects (not packages) in the workspace, related to the "pkg-c" package, only direct dependencies
pnpm ls --parseable --only-projects --filter="pkg-c" --long --depth 0
```

**Scoped naming convention for Env Vars**

It could be great to define one **context** per environment (dev, preview, live) containing **all** env var for ALL MFEs/WL Apps.

To avoid conflict we must scope the variables name by a prefix indicating the associated MFE/Wl App:

```
# the "GLOBAL_" prefix can be used when var is used be ALL the mfes / WL Apps
GLOBAL_FOO=''

# the "SP_APP_FORM_" prefix indicate that the `@sp/app-form` package use this one
SP_APP_FORM_BAR=''

# the "SP_MFE_CARD_" prefix indicate that the `@sp/mfe-card` package use this one
SP_MFE_CARD_BLUP=''
```

## Remaining

Remaining things to do to achieve the POC:

- Properly Handle environment variable definition (through context), based on naming convention written above
- Properly handle MFE remote entry environment variable values based on published (or not) MFE
  - Scenario: Sample `Foo` uses MFE `red` and `green`
  - feature was merged for MFE `red`, leading to publish of Sample `Foo` and MFE `red` (note that MFE `green` is not seen as "must be published")
  - Workflow must build `Foo` and provide as env var the url on ephemeral env for `red` BUT keep a fallback url for `green`
    - Less impact on Preview / Live env but could also concern them in case of "major" bump (`red: v1 -> v2`, `green: stay at v1`)
- Properly run the build command to target the right package to build, explude the MFE-Apps but keep internal lib package to build
- Properly handle the fact that samples must NOT be deployed on live environment