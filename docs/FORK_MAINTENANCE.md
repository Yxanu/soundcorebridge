# Liberty 5 macOS fork

- Fork: https://github.com/Yxanu/soundcorebridge
- Upstream: https://github.com/mervin008/soundcorebridge
- Maintained branch: `main`
- License: original MIT license retained; original authorship and history retained.
- Related experimental Rust port: https://github.com/Yxanu/OpenSCQ30

The fork integrates the read-only A3957 profile, vendor-service discovery,
verified listening-mode controls, File Provider-safe app staging and Liberty 5
equalizer support. The original development branches remain available for
review; `main` contains the integrated implementation.

## Verification

```sh
swift build --product soundcorectl
swift run --skip-build soundcorectl selftest
bash -n script/build_and_run.sh make-app.sh
```

CI builds and self-tests on a macOS runner, without Bluetooth access. Dependabot
proposes GitHub Actions updates weekly; updates are not auto-merged. Real-device
evidence and its limits are documented in `../TRIAL_RESULTS.txt` and
`protocol-map.md`. CI passing is not another hardware test.

Use `./script/build_and_run.sh` to launch the app locally. The archive is a
local ad-hoc-signed development build, not a notarized release. Keep `build/`,
hardware snapshots and logs private. In particular, EQ snapshots contain HearID
calibration even when they contain no device address.

## Ongoing changes

Create a focused branch from `main`, implement and self-test the change, then
open a pull request against **this fork**. Use its Issues for fork bugs. Preserve
upstream attribution; Homebrew and download links for the original app are not
installation instructions for this fork.

## Upstream synchronization

Configure the remotes once (local clones already use this arrangement):

```sh
git remote add upstream https://github.com/mervin008/soundcorebridge.git
git remote set-url --push upstream DISABLED
git config remote.pushDefault origin
```

With a clean worktree:

```sh
git fetch upstream
git switch -c maintenance/upstream-sync main
git merge upstream/main
swift build --product soundcorectl
swift run --skip-build soundcorectl selftest
git push -u origin maintenance/upstream-sync
```

Review the synchronization in a fork PR. Never overwrite upstream, force-push
published history as a routine update, copy personal diagnostics into fixtures,
or infer new hardware support from a successful build. An upstream contribution
is a separate reviewed step, not an automatic side effect of maintaining this fork.
