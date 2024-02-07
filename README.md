- ~~Updated default branch from `main` to `develop`~~
  - Must be abandoned, does not fit our workflow

## Output examples of changesets publish action

`publishedPackages` from GH Action output.

### Release
```
[{"name":"pkg-c","version":"0.0.2-pre.3"}]
```


### Pre-Release

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

