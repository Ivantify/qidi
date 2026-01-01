# QIDI Q2 + QIDI Box + Spoolman (Fluidd) — Slot-based spool tracking

This project makes Spoolman filament usage tracking reliable on **QIDI Q2 + QIDI Box** by tying Spoolman spools to **physical Box slots**, not to tools.

✅ Designed for **Qidi Studio**  
✅ Also works with **Orca and other slicers**  
✅ Should also work with **Qidi Plus4 + Qidi Box** and other Box'ed printers

---

## What this solves

With QIDI BOX installed on QIDI Q2, the printer maintains a dynamic mapping from tools to box slots.

Qidi Studio / the printer may change these values per job or session (sometimes unexpectedly).  
If you assign Spoolman spools directly to **T0..T3**, it can look like your spools “swap” or “randomize”.

**Solution:**  
Assign spools to **physical slots** instead:

- `BOX1_SLOT1..BOX1_SLOT4` represent **physical Box slots 1..4**
- `T0..T3` dynamically select the correct "slot to tool" assignment by reading the current mapping

This keeps tracking correct even if QIDI changes tool <> slot mapping behind the scenes.

---

## Safety / “please don’t do this” notes

You *can* do dangerous things like editing `saved_variables.cfg` manually while the printer is running.

- Will it work? Sometimes.
- Is it a good idea? No.
- Why? You can break tool/slot logic mid-print and cause failed loads, runouts, or worse.

If you insist, do it only when idle and take a backup first. (You’ve been warned.)

---

## Prerequisites

- Klipper + Moonraker + Fluidd access (available on Q2 / Plus4 out of the box)
- Spoolman installed and visible in Fluidd (Dashboard > Adjust Dashboard Layout > check Spoolman)
- Spoolman macros available in Klipper:
    - `SET_ACTIVE_SPOOL`
    - `CLEAR_ACTIVE_SPOOL`

If you don’t have these commands, include `spool_macros.cfg` into `printer.cfg` (see instructions below).

---

## Install

### Step 1 — Add the config file
In Fluidd:
1. Open **Configuration**
2. Create a new file named: `spoolman_qidi_box1.cfg`
3. Paste the contents from [`spoolman_qidi_box1.cfg`](./spoolman_qidi_box1.cfg)
4. Save
4. If `SET_ACTIVE_SPOOL` and `CLEAR_ACTIVE_SPOOL` macros are not available - create a new file named: `spool_macros.cfg` and paste the contents from [`spool_macros.cfg`](./spool_macros.cfg), then Save.

### Step 2 — Include the file in the correct order
In Fluidd, open `printer.cfg` and ensure the include order is:

1. `box.cfg` (QIDI vendor file that defines the Box behavior)
2. `spoolman_qidi_box1.cfg` (this project’s overrides)
3. `spool_macros.cfg` (optionally - if needed)

Example:

```ini
[include box.cfg]
[include spoolman_qidi_box1.cfg]
[include spool_macros.cfg]
```

If your includes are split across multiple files, the rule is the same: box.cfg must load first, then this project file after it.

### Step 3 — Restart Klipper

In Fluidd console:

`RESTART`

---

## Add Spoolman to Fluidd Dashboard

1. Fluidd → Dashboard → Adjust Dashboard Layout → Add `Spoolman`
2. Add `Macros`
3. Save layout
4. Hard refresh (Ctrl+F5)

Tip: Pin CHEATSHEET_BOX1 in the Macros card.

---

## Daily workflow
### Assign spools to physical slots (in Spoolman UI)

1. Fluidd → Spoolman → Change Spool:
2. Select BOX1_SLOT1 → choose spool physically loaded in Slot 1
3. Select BOX1_SLOT2 → Slot 2
4. Select BOX1_SLOT3 → Slot 3
5. Select BOX1_SLOT4 → Slot 4

Do NOT assign spools to T0..T3 in Spoolman (they shouldn't show up until you have them cached previously in `saved_variables.cfg`)

### Print normally (Qidi Studio)

* No slicer changes required. Keep your stock profiles.
* When the printer executes T0/T1/T2/T3:
    * We read value_tN (what slot that tool points to right now)
    * We set Spoolman active spool to whatever is assigned to that slot
    * Spool usage is tracked correctly

---

## Verification / Debug

### Quick status

Run in Fluidd console:

`CHEATSHEET_BOX1`

It prints slot / tool / spool dependency

---

## Persistence across restarts

Fluidd auto-saves selections for macros with `variable_spool_id`.
This project restores only the slot selector macros on startup:

`BOX1_SLOT1..BOX1_SLOT4`

Tools (T0..T3) are intentionally not restored from old tool-based keys.

---

## Extending to multiple Qidi Boxes (future)

This project is structured to scale:

* `spoolman_qidi_box1.cfg`
* `spoolman_qidi_box2.cfg` (future)
* etc.

The pattern:

BOX2_SLOT1..4 (Box2 physical slots)

Tools T4..T7 map to value_t4..value_t7