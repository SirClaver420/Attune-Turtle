# Attune Turtle

An attunement tracking addon for Turtle WoW, helping players track their progress through dungeon keys and raid attunement chains.

## Features

- Track dungeon key requirements and steps
- View raid attunement chains and progress  
- Step-by-step quest and item guidance
- Minimap icon for easy access
- Persistent progress tracking
- Optimized for Turtle WoW

## Installation

1. Download the latest release
2. Extract to your `World of Warcraft\Interface\AddOns\` folder
3. Restart WoW or reload UI with `/reload`
4. Type `/attune` to open or click the minimap icon

## Usage

- `/attune` - Open the main interface
- `/attune debug` - Toggle debug mode
- `/attune reset` - Reset minimap icon position
- `/at` - Alternative command

## Supported Content

### Dungeons / Keys
- Maraudon Scepter (Level 46-55)
- Zul'Farrak Mallet (Level 44-54)
- Scholomance Key (Level 58-60)
- UBRS Key (Level 55-60)
- Dire Maul Key (Level 55-60)

### Raid Attunements
- Molten Core (Level 60)
- Onyxia's Lair (Level 60)
- Blackwing Lair (Level 60)
- Naxxramas (Level 60)

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

## Technical Details

**Built with:**
- Ace3 framework for reliability and compatibility
- LibDataBroker for minimap integration
- Custom scrolling system optimized for vanilla WoW
- SavedVariables for persistent progress tracking

**Supported Client:** Turtle WoW (1.12.1)
**Dependencies:** None (all libraries included)

## Credits

- **Author:** SirClaver420
- **Libraries:** LibStub, AceCore-3.0, CallbackHandler-1.0, AceHook-3.0, LibDataBroker-1.1, LibDBIcon-1.0
- **Inspired by:** Original Attune addon
- **Server:** Turtle WoW

## License

This addon is released under the MIT License.

## Feedback & Support

Found a bug or have a suggestion? Please create an issue on the GitHub repository!

---

*Happy raiding, adventurers!* ⚔️