---
date: '2025-07-15T16:39:32+01:00'
draft: false
title: 'Contributing to Nix'
tags: ["til", "nix", "open-source"]
categories: []
---
I recently made my [first contribution](https://github.com/NixOS/nixpkgs/pull/410209) to [Nixpkgs](https://github.com/NixOS/nixpkgs), the package collection for [NixOS](https://nixos.org), and wanted to document a few notes and learnings from that process. Nix is an ecosystem of tools which together enable reproducible, declarative and reliable systems. It's comprised of a [package manager](https://nix.dev/manual/nix/2.28/) (Nix), a [packages collection](https://nixos.org/manual/nixpkgs/stable/) (Nixpkgs), a [functional language](https://nix.dev/manual/nix/2.28/language/index.html) (Nix expressions), and a [Linux distribution](https://nixos.org/manual/nixos/stable/) built using those tools (NixOS).

Nix first caught my attention while I was researching the concept of [reproducible builds](https://reproducible-builds.org), which enables _verification_ that binaries were created from a specific version of their source. While reproducible builds [offer many benefits](https://reproducible-builds.org/docs/why/), they're also becoming increasingly important in securing the [software supply chain](https://www.ncsc.gov.uk/collection/supply-chain-security). Nix on its own does [not guarantee bit-for-bit reproducibility](https://luj.fr/blog/is-nixos-truly-reproducible.html), but offers the tools to achieve it and reports on the [reproducibility of NixOS](https://reproducible.nixos.org), which is typically [above 99%](https://reproducible.nixos.org/nixos-iso-gnome-runtime/).

My first contribution was a version update for the [mlx Python package](https://github.com/NixOS/nixpkgs/blob/62e0f05ede1da0d54515d4ea8ce9c733f12d9f08/pkgs/development/python-modules/mlx/default.nix#L142). [mlx](https://github.com/ml-explore/mlx) is an open-source array framework from Apple which, when used with Apple's [mlx-lm](https://github.com/ml-explore/mlx-lm), allows large language models to run efficiently by leveraging the unified memory architecture of Apple Silicon. I'd tried to install mlx from Nixpkgs, but encountered a build failure for which there was an open [bug report](https://github.com/NixOS/nixpkgs/issues/349991).

At a high-level, the process was:

* Read the Nix expression language [tutorial](https://nix.dev/tutorials/nix-language.html).
* Read the Nixpkgs [contributors guide](https://github.com/NixOS/nixpkgs/blob/master/pkgs/README.md).
* Read the Nixpkgs [Python documentation](https://nixos.org/manual/nixpkgs/stable/#python).
* Checked out the [Nixpkgs repository](https://github.com/NixOS/nixpkgs).
* Verified the build failures were still occurring.
* Fixed the build failures. This was mostly [updating patches and dependencies](https://github.com/NixOS/nixpkgs/pull/410209/commits/f3edfab1bcc136020889d01ca1bf1cce6212430e), with some refactoring to match current style.
* Followed the [testing guide](https://github.com/NixOS/nixpkgs/blob/master/pkgs/README.md#package-tests). I ensured the [mlx tests](https://github.com/ml-explore/mlx/tree/main/tests) were being run and passing as part of the [check phase](https://nixos.org/manual/nixpkgs/stable/#ssec-check-phase). I also added [passthru tests](https://nixos.org/manual/nixpkgs/stable/#var-passthru-tests) which exercise the [mlx example scripts](https://github.com/ml-explore/mlx/tree/main/examples/python).
* Verified the build now succeeded.
* Verified packages which depended on the mlx package also succeeded, using [nixpkgs-review](https://github.com/Mic92/nixpkgs-review).
* Opened a [pull request](https://github.com/NixOS/nixpkgs/pull/410209) for review.
* Addressed the review feedback, and the change was shipped.

Nix has a reputation – sometimes deserved – for it's difficulty curve, but I found the process of contributing to be both welcoming and well documented.
