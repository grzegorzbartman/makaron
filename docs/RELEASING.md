# Releasing Makaron

Releases are git tags (`vX.Y.Z`). There are no build artifacts - installs and
updates are git-based, and `makaron-update` on the default `stable` channel
resets to the latest `v*` tag.

## Preconditions

- CI is green on `main`.
- The tagged commit contains the channel-aware `makaron-update` (never tag a
  commit older than that mechanism - stable users reset to the tag would
  receive an updater that no longer understands channels).

## Semver policy

- **patch** - bug fixes only.
- **minor** - new features, new `makaron.conf` variables, new migrations.
- **major** - breaking changes to user config or anything requiring manual
  steps after update.

## Cutting a release

```bash
gh release create v0.1.0 --target main --generate-notes
```

`--generate-notes` builds the changelog from squash-merged PR titles.

Verify:

```bash
git fetch --tags
git tag -l 'v*' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1
```

Then run `makaron-update` on an installed machine - it should report the new
tag as the target, and "Already up to date" on a second run.
