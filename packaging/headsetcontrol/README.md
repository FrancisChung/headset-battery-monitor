# HeadsetControl packaging input

This directory is intentionally incomplete in source control. Before building a release installer, provide the exact Windows x64 HeadsetControl build verified during the M0 hardware test:

```text
packaging/headsetcontrol/
├── headsetcontrol.exe
├── HeadsetControl-GPL-3.0.txt
└── HeadsetControl-SOURCE.txt
```

`HeadsetControl-SOURCE.txt` must identify the exact bundled version/commit and give recipients a durable way to obtain the complete corresponding source. If the selected distribution method requires hosting or bundling source rather than linking to it, place that material under `source/` and adjust the installer script accordingly. Obtain legal advice for the actual distribution model.

Do not substitute a newer `headsetcontrol.exe` without repeating the JSON compatibility and physical-headset checks described in the implementation plan.

## Obtaining the executable

Use only the [official HeadsetControl releases](https://github.com/Sapd/HeadsetControl/releases) from the `Sapd/HeadsetControl` repository. HeadsetControl's own documentation says Windows users can download either an installer or a portable executable from that page.

1. Choose a tagged stable release that includes the Logitech and HyperX fixes required by this project. Avoid the rolling **Continuous Build** unless a needed fix has not reached a stable release; continuous builds can change without a versioned release process.
2. Expand the release's **Assets** list and download the Windows x86-64 portable executable when available. Its name is normally similar to `headsetcontrol-windows-x86_64.exe`. Rename a copied packaging input to exactly `headsetcontrol.exe`.
3. If that release provides only `headsetcontrol-windows-x86_64-setup.exe`, run the official installer, then locate the installed executable. First try this in PowerShell:

   ```powershell
   (Get-Command headsetcontrol.exe -ErrorAction SilentlyContinue).Source
   ```

   If it is not on `PATH`, search the normal per-user and system application locations:

   ```powershell
   Get-ChildItem `
     $env:LOCALAPPDATA, $env:ProgramFiles, ${env:ProgramFiles(x86)} `
     -Filter headsetcontrol.exe -File -Recurse -ErrorAction SilentlyContinue `
     | Select-Object -ExpandProperty FullName
   ```

4. Verify the release checksum and, where provided, the matching `.asc` GPG signature using the instructions and signing-key fingerprint on the release page. Do not obtain the binary from a third-party download site.
5. Test the exact executable on the target Windows 10 computer before copying it here:

   ```powershell
   .\headsetcontrol.exe -o json
   .\headsetcontrol.exe -b -o json
   ```

   Save redacted results for each headset powered on and off, then both connected together. Confirm the JSON contains the expected `version`, compatible `api_version`, device identities, and plausible battery states.
6. Copy—not move—the verified executable into this directory as `headsetcontrol.exe`.

## Licence and source material

From the same tagged release, obtain the GPLv3 licence and the corresponding source archive. Put the GPL text here as `HeadsetControl-GPL-3.0.txt`. Create `HeadsetControl-SOURCE.txt` recording at least:

```text
HeadsetControl version: <exact tagged version>
Upstream repository: https://github.com/Sapd/HeadsetControl
Release page: https://github.com/Sapd/HeadsetControl/releases/tag/<tag>
Bundled binary SHA-256: <hash of headsetcontrol.exe>
Corresponding source: <durable source URL or bundled-source location>
```

Calculate the hash in PowerShell with:

```powershell
Get-FileHash .\headsetcontrol.exe -Algorithm SHA256
```

This checklist helps preserve provenance, but it is not legal advice. Confirm that the chosen way of offering corresponding source satisfies GPLv3 before distributing the combined installer.
