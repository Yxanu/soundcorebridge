# Working on this fork

- Read `docs/DEVELOPMENT.md` before changing app or protocol code and
  `docs/FORK_MAINTENANCE.md` before publication or upstream synchronization.
- `origin` is `Yxanu/soundcorebridge`; `upstream` is the original project.
  Do not push to upstream or open an upstream PR without an explicit request.
- Verify with `swift build --product soundcorectl` and
  `swift run --skip-build soundcorectl selftest`. GitHub CI runs offline tests;
  it cannot prove live-device behavior.
- Build/run the native app through `script/build_and_run.sh`. Keep the clean
  temporary staging workaround for File Provider metadata.
- Keep unknown models read-only. Verify model identity, gate every write by
  capability, preserve unrelated settings and require valid device readback.
  Never remove the OTA/iAP2 channel blocks.
- Hardware tests are opt-in; snapshot first and restore the exact original
  settings. Do not contend with another active Bluetooth control client.
- Never stage raw captures, logs, databases, real device identifiers, HearID
  calibration, credentials or private signing keys. Use synthetic fixtures.
  Review the diff and stage named files rather than every workspace file.
- Do not claim audible EQ verification or right-channel readback: firmware
  03.90 omits that channel. Keep the documented limitations accurate.
