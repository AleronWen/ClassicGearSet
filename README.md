# ClassicGearSet

A World of Warcraft Classic addon to manage your character's gear.

## Usage

In the chatbox:
- `/cgs` or `/cgs help` to show the user manual
- `/cgs list` to list saved gear sets
- `/cgs macro <true|false>` to enable or disable creation/update of weapon swap macro on save. Note that the macro is never deleted on gear set deletion.
- `/cgs save <gear name>` to save the gear set (the gear name may contain spaces)
- `/cgs load <gear name>` to load the gear set
- `/cgs delete <gear name>` to delete the gear set

To avoid typing the ClassicGearSet load command I recommand to create macro for each set.

```
/cgs load awesome
```

**What the **** does the weapon swap macro thing ?**

When weapon swap macro handling is actived a macro named *\<gear name\>_cgs* is created or updated.
Example of macro:

```
#showtooltip
/equipslot 16 Black Water Hammer
/equipslot 17 Honed Stiletto of the Monkey
```

if you play a warrior or a druid you can modify the macro to change your stance like:

```
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
- v1.1.0 beta1 **[current]**: add weapon swap macro handling
- v2.0.0: The gear sets are manageable from the character panl

## Acknowledgments

This addon is inspired by [EquipmentSets](https://www.curseforge.com/wow/addons/equipmentsets) by [Fr0stwing](https://www.curseforge.com/members/fr0stwing/projects). EquipmentSets works well and covers most of my needs but I wanted to know how it was working and maybe add some features.
So this is not realy a fork as I plan to rewrite all the code but without EquipmentSets this addon would not exist.

## Contributors

Miself, Teuz (not my real name of course...) and people from my WoW Classic guild that have tested this thing.

## License

This project is under MIT License
