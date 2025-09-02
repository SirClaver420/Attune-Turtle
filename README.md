# Attune Turtle

An attunement tracking addon for [Turtle WoW](https://turtle-wow.org), helping players track their progress through dungeon keys and raid attunement chains.

## Who am I

I am but a simple man trying something new while playing one of my favorite games: World of Warcraft. 
I am working on this totally by myself, in my own free time after work and I'm by no means affiliated in any way with either TurtleWoW or Blizzard.
I liked the official addon while playing SoD a few years ago and was surprised nobody has ported it to TWoW so I thougt I'd try to do it myself.
Any suggestions and help is much appreciated.

## Features / What I am Aiming for

Basically I am trying to recreate [the official Attune addon](https://www.curseforge.com/wow/addons/attune) made by CixiDelmont over on CurseForge.

What I want Attune-Turtle to do:
- Track dungeon key requirements and steps
- Track additional/optional requirements like the mallet quest chain for Zul'Farrak
- View raid attunement chains and progress  
- Step-by-step quest and item guidance
- Minimap icon for easy access
- Persistent progress tracking
- Optimized for Turtle WoW

## Features / What Attune-Turtle can actually do right now

This is the very first release of this addon. It is still very naked but I wanted to show the community that I am dedicated on creating a great and working replica of the official version.

What is working now if you decide to install Attune-Turtle:
- Minimapbutton works and shows the overall progress on completion when hovering over it, clicking opens the main window
- /attune command opens the main window
- main window is moveable and closeable via "X", "Close" or the "Esc"-button.
- left panel clickable options
- right panel shows information and is scrollable

## Features / What are the immediate next steps for me

The first important thing for me is to start with one entry to get a feeling about what exactly I want this addon to do and how it should do it.

I will start with Zul'Farrak and to keep it simple I will explain my vision with an example:
I want (the addon) to
- log in and be able to open Attunements via command or the minimap button. (Done.)
- make items, quests and such hoverable / clickable
- be able to click on Zul'Farrak on the left panel to get more information.
- show information about the dungeon, location, level requirement etc.
- show me the goal (Acquire the Mallet of Zul'Farrak to be able to summon the last boss.)
- show me the benefits of acquiring the mallet (Loot from Gahz'rilla and quest rewards like the riding carrot.) but also tell me that only one group member really needs to have it.
- show me the first step: Obtain "Sacred Mallet" from a mob called "Qiaga the Keeper" atop the Altar of Zul in the Hinterlands (with coordinates or maybe even something clickable to show on map).
- tell me that she is an elite mob and can be difficult to kill her alone (if your character is in that level range) so I might better find another person or two to group up
- show me the second step: Use the mallet at the other location at the altar to create the "Mallet of Zul'Farrak"
- tell that with the now acquired item I can summon the last boss in Zul'Farrak and that I am done
- either track the progress automatically or make it so I can click a checkmark for every step I already did
- show in the list on the left that Zul'Farrak is "done"
			
All with clickable items, quests and links to wowhead etc.

If you have any suggestions feel free to DM me on discord.
Just add me there (SirClaver#1050) and I will try to answer as soon as possible!

Thank you for your interest. 

## Installation

1. **Download the latest release** from the [Releases page](../../releases)
2. Extract to your `World of Warcraft\Interface\AddOns\` folder
3. Restart WoW or reload UI with `/reload`
4. Type `/attune` to open or click the minimap icon

## Usage

- `/attune` - Open the main interface
- `/attune debug` - Toggle debug mode
- `/attune reset` - Reset minimap icon position
- `/at` - Alternative command

For more commands, see the [Turtle WoW Console Commands](https://turtle-wow.fandom.com/wiki/Console_Commands) reference.

## Supported Content

### Dungeons / Keys
- **[Maraudon](https://turtle-wow.fandom.com/wiki/Maraudon) Scepter** (Level 46-55)
- **[Zul'Farrak](https://turtle-wow.fandom.com/wiki/Zul'Farrak) Mallet** (Level 44-54)
- **[Scholomance](https://turtle-wow.fandom.com/wiki/Scholomance) Key** (Level 58-60)
- **[Upper Blackrock Spire](https://turtle-wow.fandom.com/wiki/Upper_Blackrock_Spire) Key** (Level 55-60)
- **[Dire Maul](https://turtle-wow.fandom.com/wiki/Dire_Maul) Key** (Level 55-60)

### Raid Attunements
- **[Molten Core](https://turtle-wow.fandom.com/wiki/Molten_Core)** (Level 60)
- **[Onyxia's Lair](https://turtle-wow.fandom.com/wiki/Onyxia%27s_Lair)** (Level 60)
- **[Blackwing Lair](https://turtle-wow.fandom.com/wiki/Blackwing_Lair)** (Level 60)
- **[Naxxramas](https://turtle-wow.fandom.com/wiki/Naxxramas)** (Level 60)

## Technical Details

**Built with:**
- [Ace3 framework](http://www.wowace.com/wiki/Ace3) for reliability and compatibility
- [LibDataBroker](http://www.wowace.com/wiki/LibDataBroker-1.1) for minimap integration
- Custom scrolling system optimized for vanilla WoW
- SavedVariables for persistent progress tracking

**Supported Client:** [Turtle WoW](https://turtle-wow.org) Version 1.18.0 
**Dependencies:** None (all libraries included)

## Development

### API References
- [Turtle WoW API Functions](https://turtle-wow.fandom.com/wiki/API_Functions)
- [Turtle WoW API Events](https://turtle-wow.fandom.com/wiki/API_Events)
- [Turtle WoW API Types](https://turtle-wow.fandom.com/wiki/API_Types)
- [Turtle WoW Slash Commands](https://turtle-wow.fandom.com/wiki/Slash_commands)

### Contributing
1. Fork this repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Version History

### v1.0.0 (Current)
- **🎉 FIRST OFFICIAL RELEASE! 🎉**
- Complete UI implementation with working scrolling
- Minimap icon integration with LibDBIcon
- Ace3 library integration for enhanced functionality
- Persistent data storage with SavedVariables
- Welcome landing page with feature overview
- Level-ordered content organization
- Support for all major dungeon keys and raid attunements
- Professional interface matching original Attune style

## Support & Feedback

- **Issues:** [Report bugs or request features](../../issues)
- **Discussions:** [Community discussions](../../discussions) (if enabled)
- **Turtle WoW Discord:** Join the official [Turtle WoW Discord](https://discord.gg/turtle-wow)

## Credits

- **Author:** [SirClaver420](https://github.com/SirClaver420)
- **Libraries:** LibStub, AceCore-3.0, CallbackHandler-1.0, AceHook-3.0, LibDataBroker-1.1, LibDBIcon-1.0
- **Inspired by:** Original [Attune addon](https://www.curseforge.com/wow/addons/attune) by CixiDelmont
- **Server:** [Turtle WoW](https://turtle-wow.org)

## License

This addon is released under the [MIT License](LICENSE) - see the LICENSE file for details.

---

### Quick Links
- **[Download Latest Release](../../releases/latest)** 📥
- **[Report an Issue](../../issues/new)** 🐛
- **[View Source Code](../../)** 💻
- **[Turtle WoW Homepage](https://turtle-wow.org)** 🐢


*Happy raiding, adventurers!* ⚔️


