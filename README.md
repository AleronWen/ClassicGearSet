# ClassicGearSet

A World of Warcraft Classic addon to manage your character's gear.

## Usage

In the chatbox:

- `/cgs` or `/cgs help` to show the user manual
- `/cgs list` to list saved gear sets
- `/cgs macro <true|false>` to enable or disable creation/update of weapon swap macro on save. Note that the macro is never deleted on gear set deletion.
- `/cgs save <gear name>` to save the gear set (the gear name may contain spaces) and set the saved gear as active
- `/cgs load <gear name>` to load the gear set and set the saved gear as active
- `/cgs delete <gear name>` to delete the gear set
- `/cgs cancel` to revert a save or delete made by mistake

Note: the *save* and *load* commands can be used without a `<gear name>` to save/load the active gear (be careful with this feature)

To avoid typing the ClassicGearSet load command I recommand to create macro for each set.

```text
/cgs load awesome
```

**What the **** does the weapon swap macro thing ?**

When weapon swap macro handling is actived a macro named *\<gear name\>_cgs* is created or updated.
Example of macro:

```text
#showtooltip
/equipslot 16 Black Water Hammer
/equipslot 17 Honed Stiletto of the Monkey
```

if you play a warrior or a druid you can modify the macro to change your stance like:

```text
#showtooltip
/cast Defensive Stance
/equipslot 16 Black Water Hammer
/equipslot 17 Honed Stiletto of the Monkey
```

When automatic update modify the macro it searches for the first `/equipslot` occurence and wipe to only replace the weapons.

## Roadmap

- [ ] Save a gear set from the character panel
- [ ] Load a gear set from the character panel
  - [ ] check that a piece of equipment is missing and raise the issue to the player
  - [x] check that there is room in bags prior to unequip
- [x] Having SlashCmdList to load/save/list gears
  - for example `/cgs load gearname` to load the gear set named `gearname`
- [x] Automatic weapon swap macro creation/update on saving gearset

- v1.0.0: Command line addon
- v1.0.1: bug fix
- v1.1.0: add weapon swap macro handling
- v1.2.0: change data saved from item name to item ID to avoid localization problem, also add a cancel command to revert save/delete command
- v1.2.1: minor fix for WoW Classic v1.13.3
- v1.2.2 **[current]**: minor fix for WoW Classic v1.13.4
- v2.0.0: The gear sets are manageable from the character panel

## Acknowledgments

This addon is inspired by [EquipmentSets](https://www.curseforge.com/wow/addons/equipmentsets) by [Fr0stwing](https://www.curseforge.com/members/fr0stwing/projects). EquipmentSets works well and covers most of my needs but I wanted to know how it was working and maybe add some features.
So this is not realy a fork as I plan to rewrite all the code but without EquipmentSets this addon would not exist.

## Contributors

Miself (Aleron Wen) and people from my WoW Classic guild that have tested this thing.

## License

This project is under MIT License
