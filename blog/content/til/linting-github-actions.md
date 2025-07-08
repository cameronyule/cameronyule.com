---
title: "Linting GitHub Actions"
date: 2025-07-08T14:04:47+01:00
draft: false
tags: ["til", "security", "github", "ci"]
categories: []
---
I've recently started using [GitHub Actions](https://github.com/features/actions) – e.g., this website is [published automatically](https://github.com/cameronyule/cameronyule.com/blob/023b5c3266dcb7d1d88cdeed0a5b9c16f0690cd8/.github/workflows/hugo.yaml) to [GitHub Pages](https://pages.github.com) by an action. While they're convenient, I've also read many critical articles, notably from a security perspective. A few recent examples:

* {{<wayback "https://www.wiz.io/blog/github-action-tj-actions-changed-files-supply-chain-attack-cve-2025-30066">}}tj-actions/changed-files supply chain attack{{</wayback>}}
* {{<wayback "https://www.stepsecurity.io/blog/grafana-github-actions-security-incident">}}Grafana Security Incident{{</wayback>}}
* {{<wayback "https://blog.yossarian.net/2025/06/11/github-actions-policies-dumb-bypass">}}Bypassing action policies{{</wayback>}}
* {{<wayback "https://blog.pypi.org/posts/2024-12-11-ultralytics-attack-analysis">}}Supply-chain attack analysis: Ultralytics{{</wayback>}}
* {{<wayback "https://adnanthekhan.com/2024/12/21/cacheract-the-monster-in-your-build-cache/">}}Cacheract: The Monster in your Build Cache{{</wayback>}}
* {{<wayback "https://www.feldera.com/blog/the-pain-that-is-github-actions#:~:text=A%20security%20nightmare">}}The Pain That Is Github Actions{{</wayback>}}
* {{<wayback "https://www.wiz.io/blog/github-actions-security-guide">}}How to Harden GitHub Actions: The Unofficial Guide{{</wayback>}}

There's clearly sharp edges we need to be mindful of when working with actions, so in addition to reading these types of articles, I also looked for tooling which could help. This led me to configure [actionlint](https://github.com/rhysd/actionlint) and [pinact](https://github.com/suzuki-shunsuke/pinact) for my projects which rely on actions.

* actionlint is a static analysis tool for actions which runs basic security tests, such as [flagging potential sources of untrusted input](https://github.com/rhysd/actionlint/blob/v1.7.7/docs/checks.md#script-injection-by-potentially-untrusted-inputs) and [hardcoded credentials](https://github.com/rhysd/actionlint/blob/v1.7.7/docs/checks.md#check-hardcoded-credentials).
* pinact scans actions for dependencies declared using git tags (e.g., `actions/cache@v3.3.1`) and pins these to the commit hash (e.g., `actions/cache@88522a…`). This ensures the version of the action used is immutable, but does not apply to any transitive dependencies. GitHub are working on [Immutable Actions](https://github.com/features/preview/immutable-actions) to fix that, but it's not yet available.

I use [treefmt-nix](https://github.com/numtide/treefmt-nix) to manage all formatting and linting, so could easily add actionlint and pinact to my [treefmt configuration](https://github.com/cameronyule/cameronyule.com/blob/023b5c3266dcb7d1d88cdeed0a5b9c16f0690cd8/internal/nix/treefmt.nix):

```nix
_: {
  programs = {
    actionlint = {
      enable = true;
    };
    pinact = {
      enable = true;
    }
  };
}
```

In addition to actionlint and pinact, I run an additional linter which validates the [configuration of actions](https://github.com/cameronyule/gh-audit/blob/2143c34566af2e972c21d5d7e75d9dda20f23a0c/gh_audit.py#L956) per repository. This ensures the only actions which can run are those [created by GitHub or third parties which I've explicitly allowed](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository#allowing-select-actions-and-reusable-workflows-to-run).

Needless to say, these tools aren't a panacea and care must be taken when working with GitHub Actions not to leak secrets, take mutable dependencies, or allow untrusted sources. But this feels like a good starting point for blunting some of the most painful sharp edges.
