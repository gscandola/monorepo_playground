# Monorepo playground

This repository aims to find a solution for a Monorepository which will contains several MFEs / White labels Appplications (WLApps) which are related to the same topic.

These MFEs/WLApps will be deployed on the same AWS Account (depending on targeted environment) and one (or more) self-hosted shell must exists to allow local developement and QA.

Each MFEs/WLApps will have their proper lifecycle (release).

# Release workflow

Will be based on changesets and customized Github Action to handle pre-release / release mode.

See dedicated [release workflow documentation](./docs/release-workflow.md).

# Local dev and CI workflow (build & deploy)

- Idea 1: [Polymorphic shell](./docs/idea-1-polymorphic.md)
- Idea 2: [Pairing shells](./docs/idea-2-pairing.md)
- Idea 3: [Samples shells](./docs/idea-3-samples.md)

# Remaining questions / things to do

- See if it's possible to put automatically the ticket number (from branch naming) in the changeset summary text.
- Look to work done on Gemini repository to handle changesets in renovate Pull Requests (see associated GHAction workflow)
- Harmonize remote-entry file page (later later, when it will be really decided)
  - `/assets/{apps,mfes}/{identifier}/{version}/{client,server}/remoteEntry.js`
- Ask to Ayoub about identifiers in mfe/apps url (convention etc)
- Ask to Ayoub for the wording "samples" or "shells" for Idea 3

# Miscellaneous

## Output examples of changesets publish action

`publishedPackages` from GH Action output.

### Pre-Release
```
[{"name":"pkg-c","version":"0.0.2-pre.3"}]
```

### Release

```
[{"name":"pkg-a","version":"0.3.0"}]
```

## How to match a package name and its path ?

(Not sure we we have to use it, it's put here just to not lost it).

Use NPM to get a listing of packagename and their path : `pnpm ls -r --depth -1 --json`
The "depth -1" do the trick display only projects. Useful in a monorepo. Lists all projects in a monorepon example :

```
[
  {
    "path": "/Users/gscandola/meilleursagents/five_percents/monorepo_playground",
    "private": true
  },
  {
    "name": "pkg-a",
    "version": "0.1.0",
    "path": "/Users/gscandola/meilleursagents/five_percents/monorepo_playground/packages/pkg-a",
    "private": true
  },
  {
    "name": "pkg-b",
    "version": "0.1.0-pre.0",
    "path": "/Users/gscandola/meilleursagents/five_percents/monorepo_playground/packages/pkg-b",
    "private": true
  },
  {
    "name": "pkg-c",
    "version": "0.0.2-pre.2",
    "path": "/Users/gscandola/meilleursagents/five_percents/monorepo_playground/packages/pkg-c",
    "private": true
  }
]
```

## How to deal potential real npm packages (lib) we want to share ?

- Use path to differentiates apps and real npm packages:
  - `/apps/` = wl app with self hosted shell
  - `/packages/`
    - `private: true` : nothing to publish, package is private (consumed from the workspace)
    - `private: false` (or missing): invoke publish command from the package (we don't care where it is published, but probably Code Artifact)
