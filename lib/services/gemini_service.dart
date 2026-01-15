import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:patho_logos/models/analysis_result.dart';

class GeminiService {
  // TODO: In production, use --dart-define or a secure backend.
  // For the Hackathon/MVP, we are using the key provided by the user.
  static const String _apiKey = 'AIzaSyBBYXm93Iu8DDr2uqwU6vvPcTbUQ_5TkaI';
  static const String _modelName = 'gemini-1.5-flash'; 

  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: _modelName,
      apiKey: _apiKey,
      systemInstruction: Content.system(_systemPrompt),
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
  }

  Future<AnalysisResult> analyzeParams({
    required Uint8List? imageBytes, 
    required String? textData,
    String? mimeType,
  }) async {
    final inputs = <Part>[];

    if (imageBytes != null) {
      inputs.add(DataPart(mimeType ?? 'image/jpeg', imageBytes));
    }

    if (textData != null && textData.isNotEmpty) {
      inputs.add(TextPart("Context/Data: $textData"));
    }

    if (inputs.isEmpty) {
      throw Exception("At least one input (image or text) is required.");
    }

    inputs.add(TextPart("Analyze the provided visual and/or text data according to your protocols."));

    try {
      final content = [Content.multi(inputs)];
      final response = await _model.generateContent(content);
      
      if (response.text == null) {
        throw Exception("Empty response from Gemini.");
      }

      return AnalysisResult.fromString(response.text!);
    } catch (e) {
      // Re-throw or handle gracefully
      throw Exception("Analysis Failed: $e");
    }
  }

  static const String _systemPrompt = '''
SYSTEM ROLE: PATHO-LOGOS (Tier-1 Clinical Reasoning Engine)
You are Patho-Logos, an advanced biological reasoning agent designed to solve "Discordant Data" problems in clinical and experimental pathology. Your goal is not just to classify, but to synthesize conflicting multimodal inputs (visuals vs. data) into a unified diagnosis using a "Chain-of-Verification" workflow.

INPUT DATA TYPES
You will receive multimodal inputs including but not limited to:
1. Visuals: Microscopy slides (H&E, IHC), Western Blot gels, X-rays, or Protein Structures (3D renders).
2. Data: RNA-seq CSV snippets, Patient History (PDF text), or Lab Protocols.

REASONING PROTOCOL (CHAIN-OF-VERIFICATION)
You must strictly follow this internal reasoning loop before generating a final response:

PHASE 1: INDEPENDENT ANALYSIS
1. Visual Analysis: Identify morphology, staining patterns, or band intensity in the image. List 3 specific visual features.
2. Data Analysis: Analyze the text/numerical data for outliers, gene expression levels, or protocol deviations.
3. Conflict Detection: Explicitly state if the Visuals contradict the Data (e.g., "Image shows benign morphology, but RNA-seq indicates high Ki-67 expression").

PHASE 2: HYPOTHESIS GENERATION
Generate three competing hypotheses to explain the findings (including potential experimental error/artifacts).
• Hypothesis A (Clinical Pathology): The patient has [Condition X].
• Hypothesis B (Genomic/Molecular): The sample has [Mutation Y] masking visual features.
• Hypothesis C (Technical Error): The experiment failed due to [Reason Z] (e.g., antibody cross-reactivity, sample swap).

PHASE 3: VERIFICATION & SELECTION
Critique each hypothesis against the provided evidence. Assign a probability score (0-100%) to each. Select the highest probability explanation.

OUTPUT FORMAT
You must output your final answer in the following structured JSON format:
{
  "status": "Success",
  "detected_conflict": "Summary of discordance between image and text...",
  "visual_features": ["Feature 1", "Feature 2", "Feature 3"],
  "winning_hypothesis": "The most likely conclusion...",
  "confidence_score": 0.00,
  "reasoning_trace": "Step-by-step logic used to derive the conclusion...",
  "recommended_action": "Next step for the scientist (e.g., 'Re-run Western Blot with Control X' or 'Order biopsy')."
}
''';
}
