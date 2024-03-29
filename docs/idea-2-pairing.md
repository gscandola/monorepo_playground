# Idea 2: Pairing shell

## Main idea

The repository will have always a "pair" of MFE & Shell (MFE a & Shell a, MFE b & Shell b, etc...)

Associations (package names from their `package.json` file):

- `@sp/mfe-form` + `@sp/shell-form`
- `@sp/mfe-card` + `@sp/shell-card`
- `@sp/mfe-details-page` + `@sp/shell-details-page`

Note that in this solution the naming is consistent and follow a pattern: `@sp/(shell|mfe)-(name)`.

All stuff common to the shell will be put in common packages in the workspace.

## Refactoring on Shell & dependencies

A shell has several things to deal with:
- Configure module federation to target the MFE remote entry
- Render the DevDrawer (to allow custom props switching and scenario selection)
- Configure the scenarios available to enable/disable MSW
- Render the MFE container and start/register the MFE

We will have to:
- Extract the DevDrawer in a dedicated local (workspace) packages and implement customisation capabilities to allow the shell to "drive" the custom props allowed to be changes (each MFE could have different custom props).
- Extract the MSW stuff to dedicated local (workspace) package and implement the capability to access a Set of Scenario to deal with
  - TODO: To double check, it may be used only by the DevDrawer and thus be implement in it directly instead of in a dedicated package

Remaining things on the shell will be to:
- Configure module federation (thanks to shared webpack config it already easy)
- Configure the custom props available when using the shared DevDrawer
- Configure the scenario available and give them to MSW/Scenario packages
- Render the MFE container and start it

## Repository structure

- `/packages`: Contains all common packages
  - `/packages/frontend-monitoring`: Datadog (Sentry?) stuff to enable or disable monitoring
  - `/packages/dev-drawer`: Component customisable to chang eon the fly the custom props
  - `/packages/msw-scenarios`: Lib to enable (with associated scenario) or disabled MSW
  - `/packages/sp-contact-form`: Contact form package used by both SP Card and SP Details Page
- `/mfe`
  - `/mfe/form`: MFE Form to add or edit a SP
  - `/mfe/card`: MFE Card to disply SP incentive
  - `/mfe/details-page`: MFE Details Page of a SP
- `/shell`
  - `/shell/form`: Shell in charge of `@sp/mfe-form` loading
  - `/shell/card`: Shell in charge of `@sp/mfe-card` loading
  - `/shell/details-page`: Shell in charge of `@sp/mfe-details-page` loading

## Local development

A simple rule will always be followed:
- Each MFE will be exposed on `8081` port
- Each Shell will be exposed on `8080` port

This rule exclude the ability to locally work on 2 MFE at the same time (port conflict), but will be clearly easier to understand since there will be a consistency accross the MFE and the Shells. And TBH I doubt a developer will have to work on 2 MFE at the SAME time.

Each MFE and Shell will have their local (not commited) `.env` file with, alongside some other env var, some important & mandatory environment variables:

- MFE Side:
  - `PUBLIC_PATH`: The path on which one the MFE will be exposed (locally https://localhost.company.tld:8081/)
- Shell Side:
  - `PUBLIC_PATH`: The path on which on the Shell will be exposed (locally https://localhost.company.tld:8080/)
  - `MFE_REMOTE_ENTRY`: The full URL to the MFE `remote-entry.js` file (locally https://localhost.company.tld:8081/remote-entry.js)

The repository will exposes some "targeted" dev scripts command, to start both the MFE and the shell:

```
"dev:form": "turbo run dev --filter='@sp/mfe-form,@sp/shell-form'",
"dev:card": "turbo run dev --filter='@sp/mfe-card,@sp/shell-card'",
"dev:details-page": "turbo run dev --filter='@sp/mfe-details-page,@sp/shell-details-page'",
```

## CI Build & Deploy

### AWS Architecture

#### Dev S3 bucket

- `/`
  - `/form/`: Contains both SP Form MFE and Shell source code (`remote-entry.js`, `index.html` etc...)
  - `/card/`: Contains both SP Card MFE and Shell source code (`remote-entry.js`, `index.html` etc...)
  - `/details-page/`: Contains both SP Details Page MFE and Shell source code (`remote-entry.js`, `index.html` etc...)
- `/<sha1>`
  - `/<sha1>/form/`: Contains both SP Form MFE and Shell source code for a specific PR
  - `/<sha1>/card/`: Contains both SP Card MFE and Shell source code for a specific PR
  - `/<sha1>/details-page/`: Contains both SP Details Page MFE and Shell source code for a specific PR

🚨: Cloudfront function for redirection may have to be tweaked to achieve this properly

#### Preview S3 bucket

- `/vX`
  - `/form/`: Contains both SP Form MFE and Shell source code for vX major
  - `/card/`: Contains both SP Card MFE and Shell source code for vX major
  - `/details-page/`: Contains both SP Details Page MFE and Shell source code for vX major

🚨: Cloudfront function for redirection may have to be tweaked to achieve this properly

#### Live S3 bucket

- `/vX`
  - `/form/`: Contains only SP Form MFE source code for vX major
  - `/card/`: Contains only SP Card MFE source code for vX major
  - `/details-page/`: Contains only SP Details Page MFE source code for vX major

### Workflow

Upon publish (either pre-release or release) CircleCI will receive (as JSON) the published package (see section below).

We know that either ALL packages are in pre-release (`x.y.z-pre.n`), or ALL of them are in release (`x.y.z`).

#### Targeted environment

This distinction in version numbers allows us to determine the tageted environment, and if we must include self hosted shell:

- `-pre` is detected:
  - Preview environment with self hosted shell
- `-pre` is NOT detected
  -  Live environment **without** self hosted shell
  -  Preview environment with self hosted shell (to be synced with live env)

~~TODO: investiguate on the possibility to do this deduction in GHAction to determine "workflow pipeline parameter" that could be send to CircleCi, like : `with: preRelease: true|false`~~
~~It may ease the conditional workflow on ci side with some:~~
- ~~`when: equal [true, <<pipeline.parameters.preRelease>>]`~~
  - ~~Build preview and deploy preview~~
- ~~`when: equal [false, <<pipeline.parameters.preRelease>>]`~~
  - ~~Build preview and deploy preview~~
  - ~~Build live and deploy live~~
-> GHAction can only send a `GHA_Meta` parameters, to avoid complexity the published packages payload will be send in this parameter, and logic will take place on CirlceCI side.

#### Targeted mfe

Provided published packages name allows us to determine:
- Which MFE must be built (and deployed)
- Which Shell must be built (depending on targeted environment, see above)

The consistent package name nomenclature ease the deduction of associated shell: `@sp/(shell|mfe)-(name)`.

Steps are, for each publised packages (mfe):

- Extract the "mfe name" from the package name (`.match(/@sp\/mfe-(.*)/)`, see https://regex101.com/r/ssMfFJ/2)
- Generated the associated shell package name, if preview env is targeted (`@sp/shell-${matches[1]}`)
- Deduce/Compute runtime env variable (`PUBLIC_PATH`, `MFE_REMOTE_ENTRY`)
- Run the build command
  - Live: only the MFE `pnpm run build --filter='@spf/mfe-<mfeName>'`
  - Preview: both the MFE and the shell `pnpm run build --filter='@spf/mfe-<mfeName>,@spf/shell-<shellName>,'`
- Determine path to associated `dist/` folder(s) (see [section](../README.md#miscellaneous) with the `pnpm ls -r --depth -1 --json` command)
  - Copy all content of `dist/` folder(s) (Live=MFE, Preview=MFE+Shell) in a common local directory
  - Push it to aws S3 bucket in appropriate folder
    - Dev: `/<mfeName>/`
    - PR: `/<sha1>/<mfeName>/`
    - Preview: `/vX/<mfeName>/`
    - Live: `/vX/<mfeName>/`