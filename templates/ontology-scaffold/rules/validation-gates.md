# Validation Gates — {DOMAIN_DESCRIPTION}

## Validation Status (6-State)

| Status | Meaning | Actionability |
|--------|---------|---------------|
| `unvalidated` | No check attempted | informational only |
| `pending` | Check in progress | informational only |
| `partially_validated` | Some gates passed | provisional (dev/test OK) |
| `validated` | All gates passed | actionable |
| `contextually_validated` | Passed with documented conditions | actionable with caveats |
| `failed` | Gate failed | blocked — investigate |

---

## Gate 1: {GATE_1_NAME} (e.g., Input Verification)

| Check | Criterion | Status if Failed |
|-------|-----------|------------------|
| {CHECK_1} | {PASS_CRITERION} | {failed/partially_validated} |
| {CHECK_2} | {PASS_CRITERION} | {failed/partially_validated} |

---

## Gate 2: {GATE_2_NAME} (e.g., Quality / Correctness)

| Check | Criterion | Status if Failed |
|-------|-----------|------------------|
| {CHECK_1} | {PASS_CRITERION} | {failed/partially_validated} |
| {CHECK_2} | {PASS_CRITERION} | {failed/partially_validated} |

---

## Gate 3: {GATE_3_NAME} (e.g., Safety / Compliance)

| Check | Criterion | Status if Failed |
|-------|-----------|------------------|
| {CHECK_1} | {PASS_CRITERION} | {failed/partially_validated} |
| {CHECK_2} | {PASS_CRITERION} | {failed/partially_validated} |

---

## Gate 4: {GATE_4_NAME} (e.g., Review / Approval)

| Check | Criterion | Status if Failed |
|-------|-----------|------------------|
| {CHECK_1} | {PASS_CRITERION} | {failed/partially_validated} |
| {CHECK_2} | {PASS_CRITERION} | {failed/partially_validated} |

---

## Gate 5: {GATE_5_NAME} (e.g., Post-Completion Verification)

| Check | Criterion | Status if Failed |
|-------|-----------|------------------|
| {CHECK_1} | {PASS_CRITERION} | {failed/contextually_validated} |
| {CHECK_2} | {PASS_CRITERION} | {failed/contextually_validated} |

---

## Composite Validation

Overall status = min(all gates).

### Mode-Specific Requirements

| Context | Minimum Composite Status | Gates Required |
|---------|-------------------------|----------------|
| {LOW_RISK_CONTEXT} (e.g., dev/test, exploration) | `partially_validated` | Gates 1-2 |
| {STANDARD_CONTEXT} (e.g., routine work) | `contextually_validated` | Gates 1-4 |
| {HIGH_RISK_CONTEXT} (e.g., production, publication) | `validated` | All gates |

---

## Degradation Policy

When a gate fails:

1. Record which gate failed and why
2. Check if the failure maps to a known assumption (rules/assumption-registry.md)
3. Determine if the work can proceed at a lower validation status
4. If `failed` on any gate in a high-risk context → STOP and report
5. Document the degraded status in the output's Limitations section
