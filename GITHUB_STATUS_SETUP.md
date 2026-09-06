# GitHub event status publishing

## What

Each tracked source repository contains `.github/workflows/publish-dashboard-status.yml`.
On a push to `main` or `master`, it writes only the repository name, the UTC update time,
and the fixed state `updated` to this repository's public `public_status.json`.

No source path, branch name, commit SHA, commit message, author, token, or local working-tree
state is published.

## Setup

Create a fine-grained GitHub personal access token with **Contents: Read and write** access only
to `sirlinh88/projects-dashboard`. Store that token as the Actions secret
`PROJECTS_DASHBOARD_PUSH_TOKEN` in each source repository that has the workflow.

The token must not be added to a file, workflow text, issue, or commit.

After adding the secret, use **Actions → Publish public dashboard status → Run workflow** once
in each repository to seed the public status; future `main` or `master` pushes update it
automatically.

## Caveats

The public dashboard reflects remote GitHub events only. It cannot and must not reveal
uncommitted changes on a local computer.
