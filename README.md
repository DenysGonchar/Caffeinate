# Caffeinate

A tiny native macOS menu bar app for the built-in `caffeinate` command.
Requires macOS 13 or later. No third-party dependencies or Xcode project.

## Build and run

With Apple's Command Line Tools installed (`xcode-select --install`):

```sh
./build.sh
open build/Caffeinate.app
```

You can also copy `build/Caffeinate.app` into Applications.

The build generates the application icon from the menu bar's filled cup SF Symbol,
using `scripts/GenerateIcon.swift` with no additional tools.

Click the cup icon near the clock:

- **Keep Mac awake** prevents idle system sleep (`caffeinate -i`).
- **Keep display awake** also prevents idle display sleep (`-d`). Available while keeping the Mac awake.
- **Quit** releases the sleep assertions and exits.

The cup fills while enabled. The app starts disabled and has no Dock icon.
Display preference is retained only for the current session. These options do
not prevent manual sleep or guarantee operation with a laptop lid closed.
The caffeinate process is tied to the app's PID so its assertions are released
if the app exits unexpectedly.

## Start automatically at login

1. Copy `build/Caffeinate.app` into **Applications**.
2. Open **System Settings → General → Login Items & Extensions**
   (called **Login Items** on some macOS versions).
3. Under **Open at Login**, click **+** and select **Caffeinate**.

The cup will appear in the menu bar after you log in. **Keep Mac awake** starts
turned off; enable it from the menu when needed.
