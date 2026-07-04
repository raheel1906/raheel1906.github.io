## 04.07.2026
- Added `mkdocs.yml` and `requirements-docs.txt` to build the site with mkdocs-material
- Added GitHub Pages deployment workflow (`.github/workflows/deploy-pages.yml`)
- Restructured content into a `collection/` directory, matching the mkdocs `docs_dir`
- Completed draft of "Permanent PIM Eligible Role Assignment with Infrastructure as Code" article
- Added Claude Code skill for reviewing articles (`.claude/skills/review-article`)
- @raheel1906 https://github.com/raheel1906/raheel1906.github.io/pull/4
- <https://github.com/raheel1906/raheel1906.github.io/pull/4>
- Fixed GitHub Pages deploy workflow: restored required `environment` block and removed the conflicting auto-generated `jekyll-gh-pages.yml`
- Added `collection/index.md` as the site homepage, fixing a 404 on the site root
- @raheel1906 https://github.com/raheel1906/raheel1906.github.io/pull/6

## 03.07.2026
- Added .github and nested workflow folder
- Added workflow to verify Changelog is updated on PR
- Added folder under infrastructure as code for iam
- New md file, article for permanent pim role assignment