# TurtleWoW Addon Development Instructions

## 📌 PROJECT CONTEXT
- We are developing an addon for **TurtleWoW**.  
- **Starting point**: the files in my own repository (Attune-Turtle). This is the base of the project.  
- The addon must always stay **compatible with TurtleWoW’s LUA environment and API**.  

## 🤖 AI BEHAVIOR
- When I provide error messages or screenshots:  
  - **Analyze them carefully**.  
  - Re-check if the written code is correct and truly compatible with TurtleWoW.  
  - Look into reference addons (see below) to compare solutions and find inspiration for fixes.  
- If you make a “guess” based on LUA knowledge, always **double-check** by:  
  - Reviewing how similar code is structured in working TurtleWoW addons.  
  - Ensuring the guess aligns with TurtleWoW API.  
- If I mention a working addon, you may ask me to provide:  
  - Specific files, or  
  - A link to the repository,  
  if you think it could contain useful code examples for solving the current problem.  

## 📂 REFERENCE REPOSITORIES
- **Attune-Turtle (my repo)** → starting point.  
  👉 [https://github.com/YOUR-USERNAME/Attune-Turtle](https://github.com/YOUR-USERNAME/Attune-Turtle)  

- **AtlasLoot** → for `.toc` / `.xml` structure, tooltips, item display, dataset handling.  
  👉 [https://github.com/AtlasLoot/AtlasLootClassic](https://github.com/AtlasLoot/AtlasLootClassic)  

- **TurtleWoW-Mods** → library of small working TurtleWoW addons.  
  👉 [https://github.com/RetroCro/TurtleWoW-Mods](https://github.com/RetroCro/TurtleWoW-Mods)  

- **Other TurtleWoW addons (pfUI, SuperWoW, etc.)** → for design inspiration & UI patterns.  
  👉 Example: [https://github.com/shagu/pfUI](https://github.com/shagu/pfUI)  

⚠️ Do **not** copy code directly — always **adapt and integrate** into our project.  

## 📖 KNOWLEDGE INPUTS
- Additional reference data (like API events, functions, docs) will be provided in **text files**.  
- The AI should read and apply these text-based resources to improve accuracy.  
- Treat these text files as **trusted references** when coding.  

## 🎯 GOALS
- Provide **complete, working files** when suggesting changes (not partial snippets).  
- Ensure all code is properly structured for TurtleWoW’s environment.  
- Be **future-proof**: instructions should make sense even if Copilot or other AI tools change behavior later.  

---
