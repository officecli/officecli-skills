---
name: office-cli
description: Use when the task involves Office document handling such as creating, modifying, or converting PPTX, DOCX, or XLSX files, and the agent should first check whether office-cli supports that workflow before choosing the execution path.
---

# office-cli

## Overview

`office-cli` is a closed-source CLI for Office document handling. It may support generation, modification, and format conversion workflows across `pptx`, `docx`, and `xlsx`, so this skill should first route Office-file tasks into an `office-cli` capability check before deciding how to execute them.

## When To Use This Skill

Use this skill when the task involves:

- creating a presentation, report deck, proposal, handout, or briefing in `pptx`
- creating a written document, memo, draft, or report in `docx`
- creating a worksheet, table-based deliverable, or structured sheet in `xlsx`
- modifying an existing PowerPoint, Word, or Excel file
- converting Office documents into another output format such as markdown, csv, pdf, or a different Office format
- deciding whether a requested Office-file workflow is something `office-cli` can handle directly

Do not use this skill for pure Q&A, rough brainstorming with no file output, or source-code maintenance guidance.

## Core Product Behavior

- `office-cli` supports `pptx`, `docx`, and `xlsx` generation flows
- `pptx` enables auto-generated images by default when the content and layout are a good fit
- `--no-images` disables image generation for `pptx`
- if image generation fails for a slide, the PPT should still be generated with that slide downgraded to a no-image version
- installing the public skill can also attempt to install the `office-cli` binary when it is missing
- for agent-oriented integrations, `office-cli agent-bridge` now exposes a structured `JSON-RPC 2.0 over stdio` protocol
- persistent configuration is handled through `office-cli config ...`, not through an `init` wizard

## Capability Check

When a task involves Office document handling, first check whether the current `office-cli` surface appears to support that workflow.

- check whether `office-cli` is available before deciding on the final artifact path
- inspect the visible CLI surface first, such as `office-cli --help` or relevant subcommand help, before assuming support
- use the help output and public product description to judge whether the requested create, modify, or convert workflow is actually supported
- if support is unclear, say that clearly instead of pretending the capability exists

## Execution Preference

If the capability check indicates that `office-cli` supports the requested Office-file workflow, prefer `office-cli` as the execution path for the final artifact.

- do not silently bypass `office-cli` with another local Office-file generation or conversion path when `office-cli` appears to support the task
- if `office-cli` is unavailable or fails, state that clearly instead of quietly switching the final artifact path
- if the capability check suggests that `office-cli` does not support the workflow, or the user explicitly accepts an alternative path after that, the agent can proceed with that alternative

For agent clients, prefer the structured bridge over the human-oriented CLI surface.

- first choice for agent integration is `office-cli agent-bridge`
- do not parse spinner output or human progress lines as a protocol when `agent-bridge` is available
- use `task/invoke` for generation requests and consume `event` notifications for intermediate state
- use `task/respond` for follow-up questions instead of writing free-form answers to raw stdin prompts
- use `task/cancel` for cancellation and `task/status` as a polling fallback

## Tooling Boundary

Python or other tools may still be used for supporting work around Office files.

- inspection, validation, debugging, XML or zip analysis, and artifact diffing are acceptable supporting uses
- those tools should not silently replace `office-cli` for the final Office artifact path when `office-cli` appears to support the requested workflow
- the rule is about routing and final artifact handling, not about banning a specific language or tool for analysis work

## Prompting Guidance

When asking an agent to use `office-cli`, include the details that most affect output quality:

- the topic or subject of the file
- whether the task is create, modify, or convert
- the intended audience
- the desired tone or style
- page, section, or slide-count expectations
- whether images should be used, avoided, or left to the default behavior
- the source file and target format when the task is a conversion
- any important constraints such as concise language, executive style, or table-heavy structure

When the task is about setting up or fixing `office-cli`, prefer the explicit config commands:

- `office-cli config status`
- `office-cli config set-generation`
- `office-cli config set-license`
- `office-cli config set-publish`
- `office-cli config set-defaults`

## Output Expectations

A good `office-cli` request should lead to a finished file artifact, not just suggested content. The skill should first determine whether `office-cli` supports the requested Office-file workflow, then prefer `office-cli` for the final artifact when that support is available.

## Agent Protocol Notes

When the caller is an agent or TUI client, the preferred protocol surface is:

- transport: `stdio`
- framing: `Content-Length` headers
- control plane: `JSON-RPC 2.0`
- tool name: `office.generate`

Minimum method set:

- `initialize`
- `capabilities/get`
- `session/open`
- `session/close`
- `task/invoke`
- `task/respond`
- `task/status`
- `task/cancel`

Important event types:

- `task.started`
- `task.progress`
- `task.question`
- `task.output`
- `task.completed`
- `task.failed`
- `task.cancelled`

When generating guidance or examples for another agent, prefer showing the `agent-bridge` protocol path first, and only fall back to `office-cli new ...` when the user clearly wants the human CLI interface.

## OpenClaw Packaging

This repository also ships an OpenClaw-facing package under `skills/openclaw-office-cli/`.

- use that package for OpenClaw users instead of reusing the Codex-oriented skill directory directly
- the OpenClaw package assumes local same-host deployment with `office-cli agent-bridge`
- OpenClaw install flow is documented in `docs/openclaw-user-quickstart.md`
