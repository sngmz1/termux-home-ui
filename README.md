# HACK-LOCK · Termux skin

A **simple visual skin** for Termux on Android. It shows the HACK-LOCK
wallpaper as a compact header at the top of the terminal and paints the
terminal black with HACK-LOCK green text, prompt and cursor — that's all.

Termux stays the **real** terminal: `ls`, `cd`, `pwd`, `clear`, `pkg`,
`apt`, `python`, `python3`, `git`, `bash`, `sh`, `nano`, `vim`, `curl`,
`wget`, `ssh`, … all work exactly as before. There is no dashboard, no
browser app, no extra panels, nothing emulated.

```
HACK-LOCK wallpaper header
        ↓
normal Termux terminal (green on black)
```

## INSTALL

Open Termux and run:

```bash
pkg update
pkg install git -y
git clone https://github.com/sngmz1/termux-home-ui.git hacklock
cd hacklock
bash install.sh
```

`install.sh` installs one small package (`chafa`) to display the wallpaper
and does everything else automatically.

Apply the skin right away:

```bash
hacklock
```

Or just open a **new Termux session** — it skins itself automatically.
You can always go back to a fully normal session at any time.

## CUSTOM WALLPAPER

Put your own image here:

```
~/.hacklock/wallpaper.jpg
```

For example:

```bash
cp ~/my-wallpaper.jpg ~/.hacklock/wallpaper.jpg
hacklock
```

The image is displayed as-is, keeping its original aspect ratio (never
stretched).

## CUSTOM GREEN COLOR

Edit the config file:

```bash
nano ~/.hacklock/config/config.sh
```

Change this line:

```bash
HACKLOCK_GREEN="#00ff41"
```

Then run `hacklock` (or open a new session). The same file also lets you
change the header height (`HACKLOCK_HEADER_HEIGHT`) and the branding text
(`HACKLOCK_USER_TEXT`).

## UPDATE

```bash
cd hacklock
git pull
bash update.sh
```

Your custom wallpaper and config are preserved.

## UNINSTALL

```bash
bash ~/.hacklock/uninstall.sh
```

Your Termux, packages and files are untouched. Open a new Termux session
afterwards to see the normal look again.

## FILES

```
hacklock/
├── install.sh
├── uninstall.sh
├── update.sh
├── README.md
├── LICENSE
├── hacklock
├── config/
│   └── config.sh
└── assets/
    └── hacklock-background.jpg
```

## NOTES

- Termux packages used: `git` (clone) and `chafa` (image header). No Python.
- Requires Termux on Android with the built-in terminal app.
- This project only changes the *look* of the terminal. It never blocks,
  replaces or emulates any Termux command.
