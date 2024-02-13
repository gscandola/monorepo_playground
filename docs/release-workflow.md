# Release workflow

- Each PullRequest which impact functionalities of on MFE/WLApp will have a dedicated changeset file to indicate
  - The semver number to bump (Major, Minor, Patch)
  - A brief description of what was changed (will be used in Release note and in Changelog file)
- When a PR containing a changeset is merged
  - A "pre-release" Pull Request is created (or updated if already exists), with a summary of changed MFE (version number) and briefs descriptions of the changes
- When the "pre-release" Pull Request is merged
  - pre-release will be created on github (+ tags), with associated changelogs updated
  - related MFE will be deployed on preview env for QA
  - Alongside a "release" Pull Request will be opened to prepare the incoming "live deploy"
- If QA approve pre-release: "release" PR is merged
  - release are created on github (+tags) and associated changekigs are updated
  - related MFE will be deployed on live env AND preview env (to stay sync)
- If QA discover a blocking issue:
  - "release" PR is closed (eventually with a comment indicating which bug was found)
- The whole process (Fix PR creation with changeset, merge etc..) will restart

This process heavily rely on changesets library, its github action and our custom GHAction (see `.github/workflows/changesets.yml`).