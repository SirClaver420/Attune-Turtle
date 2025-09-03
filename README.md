# Attune Turtle

An attunement tracking addon for [Turtle WoW](https://turtle-wow.org), helping players track their progress through dungeon keys and raid attunement chains.

## About the Project

Hey there! 👋 I'm just a regular player who decided to try making their first WoW addon. I have zero experience with addon development - I literally started from "what is Lua?" and "how do WoW addons even work?" 

I loved the original Attune addon during Season of Discovery and when I couldn't find anything similar for Turtle WoW, I thought... "I wonder if I could make one myself?" Spoiler alert: it's way harder than I expected, but also way more fun!

I'm learning everything as I go - from basic Lua scripting to WoW's API to how GitHub works. Every single feature that works in this addon represents me googling "how to..." and probably breaking my code several times before figuring it out. 

I'm working on this in my spare time after work, just for the love of the game and the Turtle WoW community. I'm not affiliated with anyone official - just a player who got curious and decided to dive into the deep end of addon development!

**What this means for you:** I'm doing my best, but I'm definitely learning as I go. If you find bugs or have suggestions, please be patient with this noob developer! I'm committed to making this work, even if it takes me a while to figure things out. 😅

## Target Features (What I'm Building Toward)

I'm recreating [the official Attune addon](https://www.curseforge.com/wow/addons/attune) by CixiDelmont, optimized for Turtle WoW.

**Vision for Attune-Turtle:**
- Track dungeon key requirements and steps
- Track additional/optional requirements (like the Zul'Farrak mallet quest chain)
- View raid attunement chains and progress  
- Step-by-step quest and item guidance with clickable links
- Minimap icon for easy access
- Persistent progress tracking
- Automatic quest completion detection
- Character-specific progress
- Export/Import functionality

## Current Features (v1.0.0)

![Attune Turtle Interface](https://i.imgur.com/nYhBzVA.png)
*Current interface showing the landing page and navigation*

This is the first release! It's still basic, but demonstrates my commitment to creating a great replica of the official version.

**What works right now:**
- ✅ Minimap button with completion progress tooltip
- ✅ `/attune` command opens the main window
- ✅ Moveable main window (closeable via X, Close button, or ESC)
- ✅ Clickable left panel navigation
- ✅ Scrollable right panel with detailed information
- ✅ Professional UI matching the original Attune style
- ✅ All major dungeon keys and raid attunements listed

## Development Roadmap

### 🎯 Phase 1: Foundation (v1.0.0) ✅ **COMPLETE**
- [x] Basic UI framework
- [x] Minimap integration
- [x] Navigation system
- [x] Scrollable content area
- [x] Professional styling

### 🚀 Phase 2: First Implementation (v1.1.0) - **IN PROGRESS**
- [ ] **Zul'Farrak Mallet System** (Primary Focus)
  - [ ] Interactive step-by-step guide
  - [ ] Clickable quest/item links to Turtle WoW database
  - [ ] Location coordinates and map integration
  - [ ] Difficulty warnings and group recommendations
  - [ ] Progress tracking (manual checkboxes initially)
- [ ] Enhanced debug system
- [ ] Version display in UI

### 🔧 Phase 3: Core Functionality (v1.2.0)
- [ ] **Automatic Quest Detection**
  - [ ] Hook quest completion events
  - [ ] Automatic step completion
  - [ ] Real-time progress updates
- [ ] **All Dungeon Keys Implementation**
  - [ ] Scholomance Key chain
  - [ ] UBRS Key (Seal of Ascension)
  - [ ] Dire Maul Key
  - [ ] Maraudon Scepter

### ⚔️ Phase 4: Raid Attunements (v1.3.0)
- [ ] Molten Core attunement
- [ ] Onyxia attunement (Alliance & Horde)
- [ ] Blackwing Lair attunement
- [ ] Naxxramas attunement

### 🎨 Phase 5: Enhanced Features (v1.4.0)
- [ ] Character-specific progress
- [ ] Alt tracking and overview
- [ ] Custom notes system
- [ ] Progress sharing/export
- [ ] Achievement-style notifications
- [ ] Improved tooltips with rich information

### 🔮 Phase 6: Advanced Features (v2.0.0)
- [ ] Integration with Turtle WoW-specific content
- [ ] Guild progression tracking
- [ ] Statistics and analytics
- [ ] Custom attunement definitions
- [ ] API for other addons

## My Vision: Zul'Farrak Example

Here's exactly what I want the addon to do, using Zul'Farrak as an example:

1. **Click Zul'Farrak** in the left panel → Show detailed information
2. **Show dungeon details**: Location, level requirement, overview
3. **Explain the goal**: Acquire the Mallet of Zul'Farrak to summon Gahz'rilla
4. **List benefits**: Gahz'rilla loot, quest rewards (like the Carrot on a Stick), note that only one group member needs the mallet
5. **Step 1**: Obtain "Sacred Mallet" from Qiaga the Keeper at the Altar of Zul (Hinterlands) - with coordinates
6. **Warning**: She's elite and difficult to solo - recommend grouping
7. **Step 2**: Use the Sacred Mallet at the altar to create the "Mallet of Zul'Farrak"
8. **Completion**: Use the mallet in Zul'Farrak to summon the final boss
9. **Progress tracking**: Either automatic detection or manual checkboxes
10. **Visual feedback**: Show completion status in the left panel

All with clickable items, quests, and links to the Turtle WoW database!

## Installation

1. **Download the latest release** from the [Releases page](../../releases)
2. Extract to your `World of Warcraft\Interface\AddOns\` folder
3. Rename the folder to `Attune-Turtle` (if needed)
4. Restart WoW or reload UI with `/reload`
5. Type `/attune` to open or click the minimap icon

## Usage

- `/attune` - Open the main interface
- `/attune debug` - Toggle debug mode (shows detailed development information)
- `/attune reset` - Reset minimap icon position
- `/at` - Alternative command

For more commands, see the [Turtle WoW Console Commands](https://turtle-wow.fandom.com/wiki/Console_Commands) reference.

## Supported Content

### Dungeons / Keys
- **[Maraudon](https://turtle-wow.fandom.com/wiki/Maraudon) Scepter** (Level 46-55)
- **[Zul'Farrak](https://turtle-wow.fandom.com/wiki/Zul_Farrak) Mallet** (Level 44-54) 🚀 *Next Implementation*
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

### Learning Resources I'm Using
- [Turtle WoW API Functions](https://turtle-wow.fandom.com/wiki/API_Functions) - Still figuring these out!
- [Turtle WoW API Events](https://turtle-wow.fandom.com/wiki/API_Events) - Learning which events to hook
- [WoW Programming: A Guide and Reference](https://www.google.com/search?q=wow+addon+programming+guide) - My bible
- **Stack Overflow** - Where I go when I'm completely lost (which is often!)

### For Fellow Beginners
If you're also new to addon development and want to contribute or learn:
- Start small - even fixing typos or improving documentation helps!
- Don't be afraid to ask questions in Issues
- Check out the code comments - I try to explain what I'm learning as I go

### For Experienced Developers
I know my code probably isn't perfect (or even good!), but I'm learning. If you see something that could be improved, please:
- Be gentle with feedback - remember I'm new to this! 
- Explain the "why" behind suggestions so I can learn
- Feel free to submit PRs if you want to help directly

### Contributing
Whether you're a seasoned developer or another curious beginner:
1. Fork this repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

**New developer tip:** Don't be intimidated by the GitHub workflow - I had to learn it too!

## Version History

### v1.0.0 (Current) - December 2024
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
- **Discord:** **SirClaver#1050** for suggestions and feedback
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
