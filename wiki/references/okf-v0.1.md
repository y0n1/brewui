---
type: Reference
title: Open Knowledge Format (OKF) v0.1
description: Canonical OKF v0.1 specification this wiki targets for conformance.
resource: https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md
tags: [okf, specification, reference]
timestamp: 2026-07-10T00:00:00Z
---

# Open Knowledge Format (OKF) v0.1

Vendor-neutral format for representing knowledge as a directory of UTF-8 markdown files with YAML frontmatter. This BrewUI wiki bundle declares `okf_version: "0.1"` in the root [`index.md`](/index.md).

## Conformance checklist (bundle)

1. Every non-reserved `.md` file has parseable YAML frontmatter with a non-empty `type`.
2. Reserved filenames `index.md` and `log.md` follow OKF §6 and §7 when present.
3. Cross-links prefer bundle-absolute paths (`/…`) for in-bundle targets.

## Citations

[1] [okf/SPEC.md (GoogleCloudPlatform/knowledge-catalog)](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
[2] [How the Open Knowledge Format can improve data sharing](https://cloud.google.com/blog/products/data-analytics/how-the-open-knowledge-format-can-improve-data-sharing)
