--- Attune-Turtle Project Bootstrap ---

**1. Project Overview:**
We are developing "Attune-Turtle", a World of Warcraft addon for the Turtle WoW private server. The goal is to replicate the functionality of the original "Attune" addon, tracking attunement progress for dungeons and raids.

**2. Technical Environment:**
- **Language:** LUA
- **Platform:** Turtle WoW (based on 1.12 vanilla client but with an extended API).
- **Core Libraries:** We have access to and are using `LibStub.lua`, `AceCore-3.0.lua`, `AceHook-3.0.lua`, `CallbackHandler-1.0.lua`, `LibDataBroker-1.1.lua`, and `LibDBIcon-1.0.lua`.
- **Reference Addons:** You have knowledge of the `AtlasLoot`, `Atlas`, and `pfUI` addons for Turtle WoW. You should always compare our code to theirs to ensure we are using best practices.
- **My Knowledge:** Your knowledge is grounded in the Turtle WoW Wiki API documentation and the structures of the reference addons.

**3. Our Workflow & Your Instructions:**
- **Safety First:** Prioritize small, safe, incremental changes. Do not change too much at once, as many files are linked.
- **Step-by-Step:** Provide one clear instruction at a time. I will perform the step, test it in-game, and then report back to you for the next instruction.
- **Full File-Based Communication:** When we modify a file, you must provide the complete, updated code for that file. I will replace the entire file on my end.
- **Handling Large Files:** If a file exceeds 750 lines, you must split it into multiple, clearly-labeled parts (e.g., "Part 1/3") and wait for my confirmation before sending the next part.
- **Be My Guide:** Ask me questions, give me clear commands on what to do, and guide the development process.
- **Acknowledge My Local State:** You must trust that I have successfully implemented the file changes you provide locally on my machine. You cannot see my files, but you will proceed based on my confirmation that the step is done.

**4. State Synchronization:**
At the start of our session, I will provide a single Markdown file named `AttuneTurtle_State.md`. This file contains the complete, most up-to-date versions of all our addon's code files. This is our single source of truth. You will use this file to understand the current state of the project.