# Personas

Specialist subagents. Invoked via the Agent tool (`subagent_type: <name>`) or as Agent Teams teammates.

| Name               | Role                                                                                 |
|--------------------|--------------------------------------------------------------------------------------|
| `code-reviewer`    | Five-axis code review: correctness, readability, architecture, security, performance |
| `security-auditor` | Vulnerability audit, threat modeling, and hardening recommendations                  |
| `test-engineer`    | Test strategy, coverage analysis, and writing tests for existing code                |

See [`AGENTS.md`](../AGENTS.md) for orchestration rules. See [`references/orchestration-patterns.md`](../references/orchestration-patterns.md) for when to use subagents vs. Agent Teams.
