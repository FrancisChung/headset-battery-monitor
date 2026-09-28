# Headset Battery Monitor

A Windows notification-area application for monitoring the HyperX Cloud II Wireless and Logitech G933 through HeadsetControl.

Implementation is in progress. The application expects a pinned Windows build of `headsetcontrol.exe` beside `HeadsetBatteryMonitor.exe`; an advanced custom path will be supported for compatibility testing. HeadsetControl is not currently checked into this repository.

The platform-neutral parser and settings tests can be run with:

```shell
dotnet test tests/HeadsetBatteryMonitor.Tests/HeadsetBatteryMonitor.Tests.csproj -m:1
```

The WinForms shell targets `net10.0-windows` and must be hardware-tested on the intended Windows 10 machine. See [the design and implementation plan](Docs/Headset_Battery_Monitor_Design_and_Implementation.md).

Windows installer scaffolding is documented in [installer/README.md](installer/README.md). A release installer requires a separately supplied and verified Windows x64 `headsetcontrol.exe` plus its required GPL materials.
