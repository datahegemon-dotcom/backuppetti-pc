# BackupPetti Box — download page

This is the page phone users open on their PC to get the box app.
The app points here: `datahegemon-dotcom.github.io/backuppetti-pc`

## To publish it (free, GitHub Pages — same as the privacy page)

1. On the **datahegemon-dotcom** GitHub account, create a repo named **`backuppetti-pc`**.
2. Upload **`index.html`** from this folder to it.
3. Repo → **Settings → Pages** → Source: `main` branch, `/root` → Save.
4. In a minute it's live at:
   `https://datahegemon-dotcom.github.io/backuppetti-pc/`

## Where the .exe comes from (the Download button)

The green button links to the **latest GitHub Release** of the agent:
`https://github.com/datahegemon-dotcom/backuppetti-pc/releases/latest/download/backuppetti-agent.exe`

So on that same `backuppetti-pc` repo:
1. Build the binaries: (in `backuppettipc/`) `./build.sh` — it writes them to `dist/`.
   Do NOT use a bare `go build` for Windows: the exe must be linked with
   `-H=windowsgui`, or every owner gets a console window they cannot close.
2. Repo → **Releases → Draft a new release** → tag e.g. `v1.0.0`.
3. Attach **`backuppetti-agent.exe`** as a release asset → Publish.

Every future update: build the exe, publish a new release — the button always
serves the newest one automatically. No page edits needed.

## The Windows warning

New unsigned apps trigger "Windows protected your PC" (SmartScreen). The page
already tells users to click **More info → Run anyway**. To remove the warning
later, buy a code-signing certificate (~₹15–30k/yr) — only worth it once there's
revenue.
