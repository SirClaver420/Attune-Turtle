# Attune-Turtle

## Current Version: `1.0.1`

An addon for Turtle WoW that helps players track their attunement progress for dungeons and raids. This is a custom version inspired by the original [Attune](https://www.curseforge.com/wow/addons/attune) addon, tailored specifically for the Turtle WoW 1.12 client.

---

### Screenshot

![Attune-Turtle Screenshot](https://raw.githubusercontent.com/SirClaver420/Attune-Turtle/main/img/main_window_06092025.png)

---

### A Note from the Author

Hey there! 👋

I'm just a regular player who decided to try making their first WoW addon. Before this, I had zero experience with programming—I literally started from "what is Lua?" and "how do WoW addons even work?"

I loved the original Attune addon during Season of Discovery and was surprised I couldn't find anything similar for Turtle WoW. So, I thought... "I wonder if I could make one myself?" Spoiler alert: it's way harder than I expected, but also way more fun!

I'm learning everything as I go with the help of AI tools like GitHub Copilot, working on this in my spare time after work. This is a passion project for the love of the game and the Turtle WoW community.

**Please Note:** I am not affiliated with the Turtle WoW team, Blizzard, or any official entities whatsoever.

This also means that I'm definitely a noob developer learning as I go. If you find bugs or have suggestions, please be patient! Your feedback, bug reports, and contributions are essential to making this addon great. 😅

- SirClaver#1050 (Discord)

---

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Roadmap](#roadmap)
- [Version History](#version-history)
- [Versioning](#versioning)
- [Contributing](#contributing)
- [Acknowledgements](#acknowledgements)
- [License](#license)

---

## Features

- **Attunement Tracking:** Clear, step-by-step guides for all major attunements.
- **Dungeon & Raid Keys:** Track progress for essential keys like the Mallet of Zul'Farrak, UBRS key, and more.
- **Intuitive UI:** A clean, modern interface to easily view your progress.
- **Minimap Button:** Quick access via a LibDataBroker (LDB) minimap icon.
- **Turtle WoW Specific:** Data and quests are tailored for the Turtle WoW server environment.

---

## Installation

1.  Download the latest version from the [releases page](https://github.com/SirClaver420/Attune-Turtle/releases).
2.  Unzip the downloaded file.
3.  Copy the `Attune-Turtle` folder into your `World of Warcraft\Interface\AddOns` directory.
4.  Restart World of Warcraft.

---

## Usage

-   **Slash Commands:**
    -   `/attune` or `/at`: Toggles the main window.
    -   `/attune help`: Shows a list of available commands.
    -   `/attune version`: Displays the current addon version.
    -   `/attune reset`: Resets the minimap button position.

-   **Minimap Icon:**
    -   **Left-Click:** Toggles the main window.
    -   **Right-Click:** Opens the settings menu (coming soon).

---

## Roadmap

This addon is under active development. The goal is to first build a robust, feature-rich foundation before populating all the attunement data.

### Phase 1: Static UI Foundation (v1.0.1) - ✅ Complete

-   [x] Build a stable, non-resizable UI window.
-   [x] Create the sidebar, content area, and scroll frames.
-   [x] Implement a landing page and basic attunement views.
-   [x] Add a minimap icon and slash commands.
-   [x] Populate with placeholder data for major attunements.

### Phase 2: Advanced Features (Next Up)

The primary focus is on building the core systems that will power the addon.

-   **Dynamic Window:**
    -   🔳 Make the main window resizable and dynamic.
-   **Per-Character Progress:**
    -   🔳 Modify the database (`SavedVariables`) to store attunement progress on a per-character basis.
-   **Automatic Faction Detection:**
    -   🔳 Implement logic to automatically detect the player's faction (Horde/Alliance) to display the correct quest lines.
-   **Automation Engine:**
    -   🔳 Create a system to automatically check for quest completions.
    -   🔳 Add checks for required items in the player's inventory.
    -   🔳 Visually mark steps as "complete" in the UI based on player progress.
-   **Advanced UI Features:**
    -   🔳 Implement rich tooltips that show item/quest details on hover.
    -   🔳 Create a dedicated settings panel for user customization.

### Phase 3: Content & Data Population

Once the foundation is complete, the focus will shift to adding all the specific attunement data.

-   **Data Implementation:**
    -   🔳 Implement step-by-step data for all keys (Mallet of Zul'Farrak, UBRS Key, etc.).
    -   🔳 Implement step-by-step data for all raid attunements (MC, BWL, Naxxramas).
    -   🔳 Add data for custom raids like **Emerald Sanctum**.
    -   🔳 Ensure data for both Horde and Alliance quest chains is complete.

---

## Version History

-   **v1.0.1 (2025-09-06)**
    -   Finalized and polished the static UI layout.
    -   Cleaned up code and added comments across all files.
    -   Improved the addon loading message in chat.
    -   Updated the project roadmap for the next phase of development.
-   **v1.0.0 (2025-09-06)**
    -   Initial release.
    -   Established core UI, data structure, and basic functionality.

---

## Versioning

This project follows a semantic versioning pattern of **MAJOR.MINOR.PATCH**.

-   **MAJOR (1.x.x):** Incremented for massive, potentially incompatible changes or the completion of a major development phase (e.g., the release of automatic progress tracking).
-   **MINOR (x.1.x):** Incremented when new, significant features are added, such as interactive tooltips, database links, or a new attunement section for a custom raid.
-   **PATCH (x.x.1):** Incremented for backwards-compatible bug fixes, text corrections, or other small tweaks.

---

## Contributing

Contributions are welcome! If you find a bug, have a suggestion, or want to contribute code, please open an issue or submit a pull request on the [GitHub repository](https://github.com/SirClaver420/Attune-Turtle).

---

## Acknowledgements

This addon would not have been possible without the incredible work of the addon community and the resources they provide. A special thanks goes to:

-   **CixiDelmont** for creating the original [Attune addon](https://www.curseforge.com/wow/addons/attune), which was the inspiration for this entire project.
-   The authors of the **Ace3 library framework**, whose work provides the stable and powerful foundation for this addon. This includes LibStub, AceCore, AceHook, CallbackHandler, LibDataBroker, and LibDBIcon.
-   The creators of other fantastic Turtle WoW addons like **AtlasLoot** and **pfUI**, which served as invaluable references for learning how to code in this environment.
-   **Wowhead** and the **Turtle WoW Wiki** for being indispensable resources for game data.
-   This project was developed with the assistance of **GitHub Copilot**, which helped guide the development process and write the code.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
