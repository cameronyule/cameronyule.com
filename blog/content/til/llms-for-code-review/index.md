---
title: "LLMs for Code Reviews"
date: 2025-07-24T13:46:14+01:00
draft: false
tags: ["til", "ai", "software-engineering", "ci"]
categories: []
---
I've been using LLMs for software development for a few months now, mostly from the command-line using tools such as [Aider](https://aider.chat). Lately I've been investigating asynchronous LLM workflows, and enabled [Gemini Code Assist for GitHub](https://developers.google.com/gemini-code-assist/docs/review-github-code) which reviews pull requests for correctness, efficiency, maintainability and security.

It's still early days, but I've been impressed by the quality and usefulness of the review feedback from Gemini, particularly when working as a solo engineer. In a team environment it appears this type of tooling could catch a non-negligible number of issues as a first pass, offering additional quality control on what we're asking our teammates to review.

Below are some recent examples of automated PR feedback which I've acted upon. These link directly to the comments on the respective GitHub PRs so you can see them in more detail.

### Example 1: Security Improvement

When adding client-side analytics, Gemini correctly identified that I had not used [subresource integrity](https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity). This would mean any changes to the embedded script – even malicious ones – would be instantly propagated. For third-party scripts such as the one I was embedding, pinning a specific version is significantly safer.

{{< figure
  src="gemini-code-review-1.png"
  alt="Gemini Code Assist suggests using subresource integrity on a JavaScript embed"
  link="https://github.com/cameronyule/cameronyule.com/pull/12#discussion_r2228341008"
>}}

### Example 2: Test Coverage

Following a logic change, Gemini correctly noted that I had not updated the corresponding tests. While this type of issue can be caught by existing test coverage tooling, the recommendation by Gemini to use a parameterized test case to ensure multiple HTTP status codes were being exercised was a good one.

{{< figure
  src="gemini-code-review-2.png"
  alt="Gemini Code Assist identifies missing code coverage"
  link="https://github.com/cameronyule/bookmark-organiser/pull/31#discussion_r2217392059"
>}}

### Example 3: Performance Optimisation

This was a case of user error, where I'd mistakenly decorated a Python function as a [Prefect task](https://docs.prefect.io/v3/concepts/tasks). As Gemini notes, this will cause a performance regression due to the bookkeeping overhead associated with Prefect's management of task lifecycles. 

{{< figure
  src="gemini-code-review-3.png"
  alt="Gemini Code Assist PR identifies a performance regression"
  link="https://github.com/cameronyule/bookmark-organiser/pull/31#discussion_r2217411545"
>}}

### Example 4: Test Maintainability

This highlights a common issue when using LLMs for software development: focusing on feature development velocity and not pausing to refactor. I had spotted this issue when reviewing the commit diff, but continued with feature development rather than pausing and correcting the duplication of test setup. Gemini correctly called this out as impacting maintainability, and refactoring was the right thing to do.

{{< figure
  src="gemini-code-review-4.png"
  alt="Gemini Code Assist PR recommends refactoring tests for maintainability"
  link="https://github.com/cameronyule/bookmark-organiser/pull/31#discussion_r2217864164"
>}} 
