# Method Decision Tree — {DOMAIN_DESCRIPTION}

## Level 0: What Are You Trying to Do?

```
Task
├── {TASK_TYPE_1} → Section 1
├── {TASK_TYPE_2} → Section 2
├── {TASK_TYPE_3} → Section 3
└── Ambiguous → Default to {SAFEST_SECTION}, flag for review
```

---

## Section 1: {TASK_TYPE_1}

### Tool/Method Selection

```
{TASK_TYPE_1} Need
├── {CONDITION_A} → {METHOD_A}
├── {CONDITION_B} → {METHOD_B}
├── {CONDITION_C} → {METHOD_C}
└── Default → {DEFAULT_METHOD}
```

### Prerequisites

- {PREREQUISITE_1}
- {PREREQUISITE_2}

### Assumptions Required

- {ASSUMPTION_REF} (from assumption-registry.md)

---

## Section 2: {TASK_TYPE_2}

### Tool/Method Selection

```
{TASK_TYPE_2} Need
├── {CONDITION_A} → {METHOD_A}
├── {CONDITION_B} → {METHOD_B}
└── Default → {DEFAULT_METHOD}
```

### Prerequisites

- {PREREQUISITE_1}

### Assumptions Required

- {ASSUMPTION_REF}

---

## Section 3: {TASK_TYPE_3}

### Tool/Method Selection

```
{TASK_TYPE_3} Need
├── {CONDITION_A} → {METHOD_A}
├── {CONDITION_B} → {METHOD_B}
└── Default → {DEFAULT_METHOD}
```

---

## Cross-Cutting Concerns

### When Multiple Methods Apply

If task falls into more than one section:
1. Identify the primary goal (which section's output is the deliverable?)
2. Use secondary sections as supporting methods
3. Document the routing decision with provenance tag

### Approval Requirements

| Operation | Requires User Approval? |
|-----------|------------------------|
| {READ_ONLY_OPERATION} | No |
| {REVERSIBLE_MUTATION} | No (if following assigned task) |
| {IRREVERSIBLE_MUTATION} | YES |
| {HIGH_IMPACT_OPERATION} | YES — confirm scope |

### Troubleshooting Decision Tree

```
Error
├── {COMMON_ERROR_1} → {DIAGNOSTIC_1}
├── {COMMON_ERROR_2} → {DIAGNOSTIC_2}
├── {COMMON_ERROR_3} → {DIAGNOSTIC_3}
└── Unknown → Gather evidence, check assumption-registry.md for violated assumptions
```
