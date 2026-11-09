# How h0 built Bar Drawer

h0 (a coding-agent harness) running Claude Opus 5.5 (claude-opus-5-5), fitting `omarchy-v4`, in a sandbox holding a copy of an Omarchy 4 home directory. It was sent the idea below, then, after each reply, the same automatic checks ran; when one failed, the next prompt was written from a fixed template from what the check printed, the way a person pastes back an error. Nobody edited its files. The protocol is in the omarchy-h0-builds repository.

| prompt | what was sent | turns | prompt tokens | output tokens | cost | minutes | checks after it |
|---|---|---|---|---|---|---|---|
| 1 | the idea | 54 | 4,770,342 | 57,877 | $2.82 | 9.6 | all pass |
| **all** | | **54** | | | **$2.82** | **9.6** | |

## Prompt 1

```text
Build me an Omarchy shell plugin that tidies my top bar: a drawer button that, when I click it, opens a panel holding the bar widgets I've chosen to tuck away, so the bar only shows the essentials. I want to choose which widgets go in the drawer in shell.json.
```

54 turns, $2.82, 577 s. Stop: `end_turn`.

Checks after it:

- ✓ `found`: .config/omarchy/plugins/parker.drawer
- ✓ `validate`
- ✓ `loads`: plugin parker.drawer  (~/.config/omarchy/plugins/parker.drawer)
- ✓ `switched-on`: id parker.drawer
- ✓ `configurable`: read from the code and the preview

<details><summary>h0's reply</summary>

I built the drawer plugin, `parker.drawer`, and added it to your bar. All the offline checks pass, but I couldn't try the opened drawer on a real desktop. Please test it before relying on it.

**How it works**
- A chevron button (󰅀) sits at the start of your right section. Clicking it opens a small strip under the button holding your tucked-away widgets.
- You choose the contents in `shell.json` under the drawer's `items`:
  ```json
  { "id": "parker.drawer",
    "items": ["omarchy.weather", "omarchy.keyboard-layout", "omarchy.agents", "omarchy.monitor"] }
  ```
  An item can be just an id, or a full entry with its settings, like `{ "id": "omarchy.clock", "format": "HH:mm" }`. To tuck a widget away, move its entry from `bar.layout` into `items`. A mistyped id shows up in the drawer as `? the-id` rather than disappearing.
- Widgets in the drawer can open their own panels without closing the drawer. Settings they save, like the clock's format cycle, are written back into their `items` entry.
- The drawer closes when you click the button again, press Esc, click elsewhere, or open another bar panel. To bind it to a key: `omarchy-shell shell toggle parker.drawer '{}'`.

**What I changed in your bar** (backup: `.config/omarchy/shell.json.bak.1794263593`)
- I moved weather and keyboard-layout (from the center) and agents and monitor (from the right) into the drawer. That was my pick, so adjust `items` to taste.
- Update notices (`system-update`) stay in the bar so you still see when updates are available.

**Limitations**
- Omarchy doesn't let a plugin widget display other widgets directly, so the drawer loads them from their own files and passes them a stand-in bar. A few things only the built-in bar provides don't work for widgets inside the drawer:
  - keyboard shortcuts that open one specific widget's panel
  - the volume/brightness pop-up when you scroll
  - the media section of the audio panel

  This is why I left audio, network, bluetooth and power in the bar.
- Widgets in the drawer only start running the first time you open it (weather, for example, loads then).

**Testing**
- The build check passes: valid JSON, Omarchy's plugin validator, and the bar button loads and draws offscreen.
- In a separate offscreen test, the drawer contents loaded five real stock widgets with their settings applied (the clock drew `15:32` in `HH:mm` format), and the typo placeholder appeared. That test was temporary and I deleted it.
- The panel itself can't be drawn without a running desktop, so these are untested: where the strip appears, click-outside closing, widget panels opening from inside the drawer, and tooltips. I wrote that code to follow how Omarchy's own panels work.

**Please try on your desktop** (the shell reloads by itself; `omarchy-shell shell rescanPlugins` forces it):
1. Click 󰅀: the strip should appear under the button.
2. Click the monitor widget inside it: its panel should open below the strip and the drawer should stay open.
3. Click on the desktop: the monitor panel should close, then a second click should close the drawer.

If anything looks off, tell me what you see. There's a README in `.config/omarchy/plugins/parker.drawer/`.

</details>

Every tool call and its result: [SESSION.md](SESSION.md). The hash-chained trace: [session/trace.jsonl](session/trace.jsonl).
