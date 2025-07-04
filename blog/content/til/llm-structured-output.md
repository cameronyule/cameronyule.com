---
title: "LLM Structured Output"
date: 2025-07-04T15:15:57+01:00
draft: false
tags: ["til", "ai", "python"]
categories: []
---
While integrating an LLM into a [Python application](https://github.com/cameronyule/bookmark-organiser), I realised that their default response format of unstructured text wasn't always practical. This led me to discover that most current models and tooling support requesting structured output, such as JSON. For example, see [Google Gemini structured output support](https://ai.google.dev/gemini-api/docs/structured-output).

The tool I'm using for LLM integration &mdash; the [Python API](https://llm.datasette.io/en/stable/python-api.html) of Simon Willison's excellent [llm](https://github.com/simonw/llm) library &mdash; has support for structured output via [schemas](https://llm.datasette.io/en/stable/schemas.html), however the [llm-mlx](https://github.com/simonw/llm-mlx) plugin I was using for local model access did not. ([MLX](https://github.com/ml-explore/mlx) is an Apple framework for running models on Apple Silicon, typically giving higher performance.)

The solution was to migrate to [llm-ollama](https://github.com/taketwo/llm-ollama) for local model access, which [integrates](https://github.com/taketwo/llm-ollama?tab=readme-ov-file#json-schemas) with Ollama's built-in [structured output support](https://ollama.com/blog/structured-outputs). The trade-off with this change is reduced performance at inference time, but in practice this hasn't been an issue for my use case.

Here's a quick example integration in Python:

```python
import llm, json
from pydantic import BaseModel

text = """
[SNIP]
"""

class SuggestedTags(BaseModel):
    tags: list[str]

model = llm.get_model("gemma3:12b-it-qat")

prompt = (
    "Based on the following text, suggest relevant tags to assist future information retrieval."
    "Use lowercase letters only, no numbers."
    "Use single words only (e.g. ai, health, networking, photography)."
    "Return at most 5 tags."
     f"{text}"
)

response = model.prompt(prompt, schema=SuggestedTags)
response_text = response.text()
tags = json.loads(response_text)

print(response_text)
```

Which yielded the following output from [gemma3:12b-it-qat](https://ollama.com/library/gemma3:12b-it-qat):

```json
{
  "tags": [
    "ai",
    "docs",
    "agents",
    "engineering",
    "llm"
  ]
}
``` 
