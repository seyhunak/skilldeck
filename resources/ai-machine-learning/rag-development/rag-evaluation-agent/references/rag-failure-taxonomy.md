# RAG failure taxonomy

Assign each failing query to the **earliest** stage that broke. Later stages cannot be blamed for content they never received.

| Code | Stage | Failure | Typical evidence | First fixes to try |
|---|---|---|---|---|
| I1 | Ingestion | Answer not in corpus | No chunk contains the fact; source document missing or excluded | Add source, fix crawler or connector filters |
| I2 | Ingestion | Parsing loss | Tables, headers, or PDF columns garbled in chunk text | Better parser, layout-aware extraction |
| I3 | Chunking | Answer split across chunks | Fact spans a boundary; neither chunk answers alone | Structure-aware splitting, overlap, parent-document retrieval |
| I4 | Chunking | Chunk lacks context | Chunk says "it" or "this plan" with no entity name | Prepend document title and section path to chunk text |
| R1 | Retrieval | Vocabulary mismatch | Query uses synonyms or acronyms absent from gold chunk; gold rank far below k | Hybrid lexical plus vector search, query rewriting |
| R2 | Retrieval | Exact-term miss | Product codes, IDs, error strings not matched by dense retrieval | Add BM25 or keyword leg, metadata filter |
| R3 | Retrieval | Wrong filter or scope | Tenant, version, or date filter excluded the gold chunk | Fix filter logic, test filter selectivity |
| R4 | Retrieval | Near-duplicate crowding | Top-k filled with copies of one document | Deduplicate, diversify (MMR) |
| K1 | Reranking | Gold demoted | Gold in top-50 before rerank, outside top-k after | Evaluate reranker on labeled pairs, adjust k |
| C1 | Context | Truncated out | Gold retrieved but dropped by token budget | Reorder by relevance, compress, raise budget |
| C2 | Context | Buried in noise | Gold present among many irrelevant chunks; low context precision | Lower k after rerank, relevance threshold |
| G1 | Generation | Unfaithful claim | Answer asserts something the context does not support | Grounding instruction, citation requirement, smaller claims |
| G2 | Generation | Ignored evidence | Gold in context, answer contradicts or omits it | Put evidence nearer the question, quote-then-answer prompting |
| G3 | Generation | Failed abstention | No gold context, model answered anyway | Explicit abstention rule and evaluation of it |
| G4 | Generation | Over-abstention | Gold present, model refused | Loosen abstention wording, check context formatting |
| Q1 | Query | Ambiguous or out of scope | Reasonable people disagree on the right answer | Clarifying-question behaviour; relabel or remove |

## Attribution rules

1. If the gold chunk is not in the index, the category is I1 to I4 regardless of what the generator did.
2. If it is indexed but not in the top-N candidate list, use R1 to R4.
3. If it is a candidate but not in the final top-k, use K1.
4. If it is in the top-k but not in the final prompt, use C1; if present but surrounded by noise and ignored, consider C2 versus G2 by checking context precision.
5. Only when the gold content reached the prompt can the failure be G1, G2, or G4.
6. Record one primary code per query. Add a secondary code only when two independent fixes would both be required.
