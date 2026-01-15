# LLM Documentation: Patho-Logos

This document outlines the **System Role**, **Prompt Engineering**, and **Data Schema** used to power the Patho-Logos Clinical Reasoning Engine.

## Model
*   **Model**: `gemini-1.5-flash`
*   **Temperature**: Standard (Optimized for reasoning precision)
*   **Response Format**: JSON

## System Role: The "Chain-of-Verification"
Patho-Logos does not simply "chat". It follows a rigid internal cognitive protocol to minimize hallucination and handle conflicting data.

### 1. The Protocol
The model is instructed to follow these phases before outputting a result:

*   **PHASE 1: INDEPENDENT ANALYSIS**
    *   Analyze Visuals (Morphology, Staining) independently.
    *   Analyze Data (Genomics, History) independently.
    *   **Conflict Detection**: Explicitly state if inputs contradict (e.g., Benign Image vs. Malignant Data).

*   **PHASE 2: HYPOTHESIS GENERATION**
    *   Generate 3 competing theories (Clinical, Molecular, Technical Error).

*   **PHASE 3: VERIFICATION & SELECTION**
    *   Score each hypothesis based on evidence.
    *   Select the winner.

### 2. The System Prompt
```text
SYSTEM ROLE: PATHO-LOGOS (Tier-1 Clinical Reasoning Engine)
You are Patho-Logos, an advanced biological reasoning agent designed to solve "Discordant Data" problems...
...
REASONING PROTOCOL (CHAIN-OF-VERIFICATION)
...
OUTPUT FORMAT
{
  "status": "Success",
  "detected_conflict": "...",
  "visual_features": [...],
  "winning_hypothesis": "...",
  "confidence_score": 0.00,
  "reasoning_trace": "...",
  "recommended_action": "..."
}
```
*(See `lib/services/gemini_service.dart` for the full raw string)*

## Input/Output

### Input
The model accepts multimodal prompts:
*   **Image**: `image/jpeg`, `image/png` (Microscopy, Gels, Structures).
*   **Text**: Contextual clinical data.

### Output Schema (JSON)
The application strictly parses this JSON structure:

```json
{
  "status": "Success | Error",
  "detected_conflict": "String description of the mismatch",
  "visual_features": ["List", "of", "observed", "features"],
  "winning_hypothesis": "The final diagnostic conclusion",
  "confidence_score": 0.95,
  "reasoning_trace": "Explanation of the logic path taken",
  "recommended_action": "Next clinical or experimental step"
}
```
