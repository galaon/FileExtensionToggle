# File Extension Toggle

한국어 문서는 [README.md](README.md) 를 보십시오.

Toggle Windows Explorer's **"Hide extensions for known file types"** from the right-click menu.
No Folder Options dialog, no Explorer restart — one click.

- The menu item **shows the current state** — `File Extension Toggle ― [Current · ON]`
- The **icon color follows the state** — blue when extensions are shown, gray when hidden
- Switches **silently** (a popup appears only on error)
- **No admin rights** required (writes to `HKCU` only)
- **No Explorer restart** (refreshes via `SHChangeNotify`)
- **UI language follows Windows** — Korean on a Korean display language, English otherwise
- No dependencies beyond what ships with Windows (PowerShell + wscript)

## Layout

```
FileExtensionToggle/
├── Install.bat        ← double-click to install
├── Uninstall.bat      ← double-click to uninstall
├── README.md          ← Korean (default)
├── README.en.md       ← this document
├── LICENSE
├── src/               ← scripts
│   ├── Install.ps1        registers the menu item
│   ├── Uninstall.ps1      removes the menu item
│   ├── ToggleFileExt.ps1  the toggle itself (flip HideFileExt, refresh, update menu)
│   ├── Run-Hidden.vbs     launches the toggle with no console window
│   └── Lang.ps1           Korean / English string table
└── icons/             ← icons
    ├── icon-on.ico        extensions shown (ON) - blue
    ├── icon-off.ico       extensions hidden (OFF) - gray
    └── icon-source.svg    original artwork
```

Day to day you only ever touch `Install.bat` and `Uninstall.bat` in the root.

## Install

**Double-click `Install.bat`.** That's it — no admin rights needed.

The batch file calls PowerShell with `-ExecutionPolicy Bypass`, so you don't have to change
your system's execution policy.

To force a language or set a custom menu name, run the script directly:

```powershell
powershell -ExecutionPolicy Bypass -File ".\src\Install.ps1" -Language en
powershell -ExecutionPolicy Bypass -File ".\src\Install.ps1" -MenuText "Show extensions"
```

Registered under `HKCU` in three places — a folder's empty space, the desktop, and a folder icon.

## Usage

Right-click the desktop or an empty spot in a folder →
**File Extension Toggle ― [Current · OFF]**

- No window appears; it switches immediately.
- Open Explorer windows update **without a manual refresh**.
- Next time you right-click, the label reads **`[Current · ON]`** and the icon has turned blue.

`ON` = extensions visible, `OFF` = extensions hidden.

> **On Windows 11**, registry-based menu items don't appear in the simplified context menu.
> Click **[Show more options]** or press `Shift + F10` to reach the classic menu.

## Uninstall

**Double-click `Uninstall.bat`.** Only the menu item is removed; your extension setting is left as is.

## How it works

One registry value gets flipped:

```
HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
    HideFileExt (DWORD)
        1 = extensions hidden (Windows default)
        0 = extensions shown
```

Then `shell32.dll!SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_FLUSH, ...)` tells open Explorer
windows to refresh. `SHCNF_FLUSH` waits until the notification is actually processed, so the
change lands immediately. Explorer is never killed or restarted, so your open windows survive.

### How the state ends up in the menu

Explorer **re-reads the label and icon from the registry every time the menu opens.** So right
after flipping the value, the toggle script rewrites each menu key's default value as

```
File Extension Toggle ― [Current · ON]
```

and points `Icon` at `icon-on.ico` or `icon-off.ico`. The plain name is kept in `BaseMenuText`
and the chosen language in `LangCode`, so the label is rebuilt consistently every time.
That gets a state-aware menu item without a COM shell-extension DLL.

## Icon

The menu icon is [`heavy-six-point-asterisk` from Pinhead Map Icons](https://icon-sets.iconify.design/pinhead/heavy-six-point-asterisk/),
converted into two multi-size `.ico` files (16 / 20 / 24 / 32 / 48 / 64 / 128 / 256 px).

| File | State | Color |
|------|-------|-------|
| `icon-on.ico` | extensions **shown** (ON) | blue `#0078D4` |
| `icon-off.ico` | extensions **hidden** (OFF) | gray `#808080` |

Both colors were picked to stay legible on light and dark menus.
At install time both files are copied to **`%LOCALAPPDATA%\FileExtensionToggle\icons\`**, and the
menu points at that copy. Moving or deleting the project folder never breaks the menu icon, and the
files sit somewhere you won't disturb by accident. `Uninstall.bat` removes that folder too.

To use your own artwork, replace the two `.ico` files in `icons/` (same names) and run
`Install.bat` again to refresh the copy.

## Notes and limits

- **Moving the folder breaks the menu** — the script path is stored as an absolute path.
  Run `Install.bat` again from the new location (it overwrites the same keys).
  Icons are unaffected: they live in `%LOCALAPPDATA%`.
- If you swap the artwork and the menu still shows the old icon, that's Explorer's icon cache.
  Run `Install.bat` again, or restart Explorer.
- The `[Current · XX]` label and the icon color are refreshed **when you toggle with this tool.**
  Change the setting from Folder Options or another program and the label can briefly disagree
  with reality; one click on the menu puts them back in sync. Tracking it perfectly would require
  a dynamic context-menu handler (a COM DLL).
- Language is decided at install time from your Windows display language and stored per menu item.
  Change your display language and run `Install.bat` again to switch.
- Nothing is shown on success. Errors raise a 6-second popup.

## License

Code in this repository is released under the [MIT License](LICENSE).
Made by 방모씨 (BangMossi).

The icon comes from [Pinhead Map Icons](https://github.com/waysidemapping/pinhead) by Quincy Morgan
and is **CC0 1.0 (public domain)**.
