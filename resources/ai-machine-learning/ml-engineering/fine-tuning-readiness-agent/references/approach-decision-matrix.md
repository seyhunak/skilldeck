# Approach decision matrix

Map each observed gap to the lever most likely to close it. These are practitioner heuristics, not guarantees; confirm with the eval set.

| Observed gap | Prompting | Retrieval (RAG) | Fine-tuning | Distillation to smaller model | Notes |
|---|---|---|---|---|---|
| Missing domain facts | Weak | Strong | Weak | No | Training rarely teaches facts reliably and cannot cite them |
| Facts change often (prices, policies, inventory) | No | Strong | Poor | No | Retraining cadence cannot keep up |
| Answers must cite sources | Partial | Strong | No | No | Citations need retrieved passages |
| Output format or schema inconsistency | Strong (structured output, examples) | No | Strong | Possible | Try constrained decoding or structured output first |
| Brand voice or writing style | Moderate | No | Strong | Possible | Fine-tuning shines when style is hard to describe but easy to demonstrate |
| Narrow classification with subtle boundaries | Moderate | Partial (similar labeled examples) | Strong | Strong | Needs consistent labels |
| Complex multi-step instructions | Moderate (decomposition) | No | Moderate | Weak | Chaining often beats training |
| Reasoning errors | Moderate (stronger model, decomposition) | No | Weak to moderate | Weak | Usually a model capability limit |
| Latency or cost too high on large model | Partial (shorter prompts) | No | Moderate | Strong | Distill from the large model's outputs, then evaluate |
| Very long prompts needed for every request | Partial (caching) | Partial | Strong | Strong | Training can internalize instructions and examples |
| Safety or refusal behaviour mis-calibrated | Moderate | No | Moderate, risky | Risky | Training can weaken existing safety behaviour; evaluate carefully |

## Data readiness rules of thumb

- Consistency beats volume. Measure agreement on a re-labeled sample before training; disagreement in labels becomes noise in the model.
- Cover the hard cases. A set dominated by easy examples teaches the model what it already does well.
- Keep the eval set out. Deduplicate and check near-duplicates between training and evaluation data.
- Mirror production inputs. Training examples should look like real traffic, including messy formatting.
- Confirm rights. Every source needs documented permission for training use.

## Go/no-go summary

Proceed only when all are true: alternatives documented as insufficient; frozen eval set exists; baseline measured; data audit has no blockers; success threshold agreed in advance; owner accepts retraining and maintenance cost.
