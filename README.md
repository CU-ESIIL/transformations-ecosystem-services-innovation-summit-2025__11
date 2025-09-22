# Transformations & Ecosystem Services Innovation Summit 2025 — Team 11

This repository is the public home for the Transformations & Ecosystem Services Innovation Summit 2025 (Team 11) sprint. We use it to coordinate rapid prototyping, share analyses, and publish a lightweight website that documents our progress during and after the summit.

> **New to GitHub?** This README walks through how to update the site, share code, and collaborate without leaving your browser. You can also review the day-by-day prompts inside the `docs/instructions/` folder for a guided sprint workflow.

---

## Quick links

| Purpose | Link |
| --- | --- |
| 🌐 Live site | https://cu-esiil.github.io/transformations-ecosystem-services-innovation-summit-2025__11/ |
| 💻 Repository | https://github.com/CU-ESIIL/transformations-ecosystem-services-innovation-summit-2025__11 |
| 📂 Shared storage | https://de.cyverse.org/data/ds/iplant/home/shared/esiil/Innovation_summit/Group_11/ |
| 📑 Day-by-day prompts | [docs/instructions/](docs/instructions/) |

---

## Repository structure

Think of the repo as a shared digital workspace. Everything important lives in a few predictable places:

* **docs/** – Powers the public-facing website (built with MkDocs). Update these Markdown files to change the site.
* **code/** – Place scripts, notebooks, and utilities that the team wants to reuse.
* **documentation/** – Longer internal notes, planning docs, or extended narratives that do not need to appear on the public site yet.
* **docs/assets/** – Images, GIFs, and downloadable files referenced by the website.
* **workflows/** – GitHub Actions used to build and deploy the site.

Keep filenames descriptive and add short comments or README snippets so others can quickly understand how to run what you create.

---

## Updating the website (no command line required)

1. Open the [`docs/`](docs/) folder and choose the page you want to edit (for example `index.md`).
2. Click the pencil icon (✏️) in the top-right corner of the file view on GitHub.
3. Make your edits. Use Markdown headings, bullet lists, and image embeds (`![alt text](assets/filename.png)`).
4. Scroll to the **Commit changes** box at the bottom of the page, describe what changed (e.g., `Update hero section with data sources`), and press **Commit changes**.
5. Wait ~1 minute, then refresh the live site. The Deploy workflow rebuilds automatically after each commit to `main`.

Need inspiration? Start with:

* `docs/index.md` – homepage overview, hero links, and daily updates
* `docs/instructions/` – sprint prompts for Days 1–3
* `docs/data.md` – catalog datasets, access notes, and licensing
* `docs/project_template.md` – reusable onboarding page with contact info and resources

---

## Sharing code and analysis assets

* Add scripts or notebooks to the [`code/`](code/) directory. Include a docstring or header comment explaining the purpose, key inputs, and expected outputs.
* Version small derived datasets, plots, or tables alongside the code when it makes replication easier.
* For larger files (>50 MB), use the shared CyVerse storage (`Group_11`) and link to them from the site instead of uploading directly to GitHub.
* Summarize how to run important workflows on [`docs/code.md`](docs/code.md) so others can follow along.

---

## Collaborative tips

* Keep edits small and frequent—many short commits are easier to review than one large drop of changes.
* Mention teammates in issues or pull requests with `@username` when you need feedback.
* Use the **Discussions** or **Issues** tabs to log decisions, open questions, and follow-up tasks after the summit.
* If you are new to Git or working from JupyterHub, follow the instructions in [`docs/instructions/link-to-github.md`](docs/instructions/link-to-github.md) and [`docs/instructions/save-to-persistent-storage.md`](docs/instructions/save-to-persistent-storage.md).

Happy building, and let’s document what Team 11 learns during the summit!
