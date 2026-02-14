# Authority Scoring — {DOMAIN_DESCRIPTION}

## Formula

```
authority_score = (
    source_type_weight     * 0.35
  + recency_weight         * 0.25
  + community_trust_weight * 0.20
  + specificity_weight     * 0.20
)
```

The LLM MUST use this formula. Do NOT editorialize on source quality — compute the score.

---

## Source Type Weight (0.35)

Adapt this table to your domain. Higher weights for authoritative sources,
lower for informal or unreviewed sources.

| Source Type | Weight |
|-------------|--------|
| {PRIMARY_AUTHORITATIVE_SOURCE} (e.g., official docs, peer-reviewed journals) | 1.00 |
| {SECONDARY_AUTHORITATIVE_SOURCE} (e.g., official blogs, technical reports) | 0.85 |
| {VERIFIED_COMMUNITY_SOURCE} (e.g., verified modules, accepted SO answers) | 0.70 |
| {EXPERT_INFORMAL_SOURCE} (e.g., known expert blog, conference talk) | 0.50 |
| {UNVERIFIED_SOURCE} (e.g., unknown blog, forum post) | 0.30 |
| {AI_GENERATED_SOURCE} (e.g., LLM output without citation) | 0.20 |

## Recency Weight (0.25)

Adjust the decay rate for your domain. Fast-moving fields (cloud APIs, ML
frameworks) decay faster. Slow-moving fields (mathematics, established
medicine) decay slower.

```
recency_weight = max(0.20, 1.0 - {DECAY_RATE} * (current_year - last_updated_year))
```

| Domain Speed | Decay Rate | Rationale |
|-------------|-----------|-----------|
| Fast (cloud, APIs, frameworks) | 0.10 | Features change yearly |
| Medium (software practices, guidelines) | 0.07 | Standards evolve over 2-5 years |
| Slow (established science, regulations) | 0.05 | Knowledge is stable over decades |

**Your domain decay rate:** `{DECAY_RATE}`

| Last Updated | Weight (in 2026, rate={DECAY_RATE}) |
|-------------|------|
| 2026 | 1.00 |
| 2025 | {COMPUTED} |
| 2023 | {COMPUTED} |
| 2020 | {COMPUTED} |

## Community Trust Weight (0.20)

| Indicator | Weight |
|-----------|--------|
| {HIGHEST_TRUST_INDICATOR} (e.g., domain governing body, core team member) | 1.00 |
| {HIGH_TRUST_INDICATOR} (e.g., recognized expert, certified professional) | 0.85 |
| {MEDIUM_TRUST_INDICATOR} (e.g., active community contributor) | 0.60 |
| {LOW_TRUST_INDICATOR} (e.g., anonymous contributor) | 0.30 |

## Specificity Weight (0.20)

| Specificity | Weight |
|-------------|--------|
| Exact scenario match | 1.00 |
| Close match (same subfield) | 0.70 |
| General topic match | 0.40 |

---

## Example Computation

Source: {EXAMPLE_SOURCE_DESCRIPTION}

```
source_type   = {VALUE} * 0.35 = {PRODUCT}
recency       = {VALUE} * 0.25 = {PRODUCT}
community     = {VALUE} * 0.20 = {PRODUCT}
specificity   = {VALUE} * 0.20 = {PRODUCT}
                                  -----
authority_score                 = {TOTAL}
```

---

## LLM Boundary

| Action | Allowed? |
|--------|----------|
| Compute authority_score using formula | YES — deterministic |
| Override formula weights | NO — user must approve changes |
| Skip scoring for "obvious" sources | NO — always compute |
| Report score without showing formula inputs | NO — show the breakdown |
