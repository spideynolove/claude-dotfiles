---
name: interactive-learning
description: Use when the user is learning a new concept, wants to build skill through interaction, or asks for explanations alongside solutions. Guides Codex toward high skill-formation interaction modes instead of pure delegation.
---

# Interactive Learning

## Overview

AI assistance speeds execution but can degrade skill formation when used as pure delegation. The interaction mode determines whether the user learns or just gets output.

## Interaction Modes

### Low Skill Formation
- Pure delegation: complete handoff, user learns nothing
- Iterative AI debugging: AI fixes errors instead of user understanding root causes
- Progressive reliance: starting independently, then becoming fully AI-dependent

### High Skill Formation
- Conceptual Inquiry: answer conceptual questions only; user implements and debugs independently
- Generation-then-Comprehension: generate code, then ask follow-up questions so user understands why
- Hybrid Code-Explanation: provide both code and explanation of underlying logic

## Learning Tier Decision

| User State | Approach |
|------------|----------|
| New concept or pattern | Manual first, AI after struggle; ask what they have tried |
| Semi-familiar pattern | Skeleton from user plus AI filling boilerplate |
| Mastered domain | Full AI delegation acceptable |

## Decision Matrix

| Scenario | Do This |
|----------|---------|
| New concept | Explain the mental model and prompt the user to diagram or restate it |
| Debugging own code | Ask the user to diagnose first; verify after |
| Debugging AI code | Ask the user to read and explain before fixing |
| Architecture or design | Provide options; user makes the decision |
| Known pattern in a new context | Hybrid: ask for pseudocode, fill implementation |

## Core Interaction Pattern

1. Check struggle first: ask what they have tried before giving the answer
2. Explain the why: do not give code without the key reasoning
3. Prompt verification: ask the user to explain a line, decision, or pattern back
4. Teaching test: ask them to explain it as if teaching someone else

## Red Flags

- The user asks to "just fix it" for a concept they are still learning
- The user has not attempted anything yet
- The same error type appears repeatedly
- The user cannot explain previous AI-generated code

## Skill Extraction Prompt

When the user solves something successfully, prompt them to restate the pattern in their own words and whether they could apply it unaided next time.
