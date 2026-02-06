UseAll set — I appended a Research Paper Starter Pack section and built a ready-to-use scaffold you can download. • Updated cheatsheet: Download Markdown • Changes diff: Download diff • Starter project ZIP: Download the starter pack

What’s in the starter pack • \_quarto.yml preconfigured for a manuscript project, DOCX output, CSL + BibTeX citations, and metadata-files: \[manuscript.yml\]. • manuscript.yml with authors/affiliations/abstract/keywords. • index.qmd that includes section files via Quarto’s {{< include ... >}} shortcode. • sections/ with 01-introduction.qmd, 02-methods.qmd, 03-results.qmd, 04-discussion.qmd. • refs/library.bib with example entries. • csl/new-england-journal-of-medicine.csl placeholder — replace with the real CSL from Zotero’s style repo. • templates/README.md — put your Word journal-reference.docx there and the YAML already points to it.

How to use 1. Unzip into a new folder. 2. Replace the CSL with the real NEJM style (keep the same filename). 3. Drop in your journal-reference.docx (or skip if your journal doesn’t require Word styles). 4. Edit manuscript.yml and the sections/\*.qmd. 5. Render:

quarto render --to docx \# optional: \# quarto render --to pdf

Want me to also add a tiny makefile (e.g., make docx, make pdf) or a GitHub Actions workflow that checks render on push?