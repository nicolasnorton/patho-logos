import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patho_logos/view_model.dart';
import 'package:patho_logos/models/analysis_result.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark Slate
      appBar: AppBar(
        title: Text('PATHO-LOGOS', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Consumer<AppViewModel>(
        builder: (context, vm, child) {
          // Responsive layout: Row on generic large screens, Column on smaller
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 4, child: _InputPanel(vm: vm)),
                        Expanded(flex: 6, child: _ResultsPanel(vm: vm)),
                      ],
                    ),
                  ),
                );
              } else {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _InputPanel(vm: vm),
                      Divider(color: Colors.white.withOpacity(0.1), height: 1),
                      // Ensure results panel takes some height or wraps content
                      _ResultsPanel(vm: vm),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class _InputPanel extends StatelessWidget {
  final AppViewModel vm;
  const _InputPanel({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader("INPUT MODE: MULTIMODAL"),
          const SizedBox(height: 20),
          
          // Image Input
          _buildInputCard(
            context,
            title: "VISUAL DATA (Microscopy/Blots)",
            child: vm.hasImage
                ? Column(
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: MemoryImage(vm.imageBytes!),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(vm.imageName ?? 'Image', overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70))),
                          IconButton(onPressed: vm.clearImage, icon: const Icon(Icons.delete, color: Colors.orangeAccent)),
                        ],
                      )
                    ],
                  )
                : InkWell(
                    onTap: vm.isLoading ? null : vm.pickImage,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white.withOpacity(0.05),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_photo_alternate_outlined, color: Colors.cyanAccent, size: 32),
                            SizedBox(height: 8),
                            Text("Upload Image", style: TextStyle(color: Colors.cyanAccent)),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          
          // Text Input
          _buildInputCard(
            context,
            title: "CLINICAL CONTEXT / DATA",
            child: TextField(
              controller: vm.textController,
              onChanged: vm.updateText,
              maxLines: 8,
              style: GoogleFonts.firaCode(fontSize: 13, color: Colors.white70),
              decoration: InputDecoration(
                hintText: "Enter RNA-seq data, patient history, or lab protocols here...",
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          // Analyze Button
          ElevatedButton(
            onPressed: vm.isLoading ? null : vm.analyze,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: vm.isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : Text("INITIATE CHAIN-OF-VERIFICATION", style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
          if (vm.error != null)
             Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.redAccent.withOpacity(0.5))),
               child: Text("ERROR: ${vm.error}", style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
             ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.jetBrainsMono(color: Colors.cyanAccent, fontSize: 12, letterSpacing: 1.5),
    );
  }

  Widget _buildInputCard(BuildContext context, {required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _ResultsPanel extends StatelessWidget {
  final AppViewModel vm;
  const _ResultsPanel({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      color: const Color(0xFF0B1221),
      child: vm.result == null && !vm.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.science, size: 64, color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 16),
                  Text("AWAITING INPUT STREAMS", style: GoogleFonts.jetBrainsMono(color: Colors.white24, letterSpacing: 2)),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (vm.isLoading) ...[
                    Text("PROCESSING...", style: GoogleFonts.jetBrainsMono(color: Colors.cyanAccent, fontSize: 12, letterSpacing: 1.5)),
                    const SizedBox(height: 20),
                    const LinearProgressIndicator(color: Colors.cyanAccent, backgroundColor: Colors.white10),
                    const SizedBox(height: 20),
                    _buildLoadingSkeleton(),
                  ],
                  if (vm.result != null) _buildResultsView(context, vm.result!),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 40, width: 200, color: Colors.white10),
        const SizedBox(height: 20),
        Container(height: 100, width: double.infinity, color: Colors.white10),
        const SizedBox(height: 20),
        Container(height: 20, width: 100, color: Colors.white10),
        const SizedBox(height: 10),
        Container(height: 200, width: double.infinity, color: Colors.white10),
      ],
    );
  }

  Widget _buildResultsView(BuildContext context, AnalysisResult result) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.greenAccent)),
                child: Text(result.status.toUpperCase(), style: GoogleFonts.jetBrainsMono(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              Text("CONFIDENCE: ${(result.confidenceScore * 100).toStringAsFixed(1)}%", style: GoogleFonts.jetBrainsMono(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 30),

          // Detected Conflict
          if (result.detectedConflict.isNotEmpty && result.detectedConflict != "None") ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                border: Border(left: BorderSide(color: Colors.orangeAccent, width: 4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("⚠ DISCORDANCE DETECTED", style: GoogleFonts.jetBrainsMono(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(result.detectedConflict, style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],

          // Winning Hypothesis
          Text("DIAGNOSTIC CONCLUSION", style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 10),
          Text(
            result.winningHypothesis,
            style: GoogleFonts.lora(fontSize: 28, color: Colors.white, height: 1.3),
          ),
          const SizedBox(height: 40),

          // Visual Features Grid
          Text("IDENTIFIED FEATURES", style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: result.visualFeatures.map((f) => Chip(
              backgroundColor: Colors.white.withOpacity(0.05),
              label: Text(f, style: const TextStyle(color: Colors.cyanAccent)),
              side: BorderSide.none,
            )).toList(),
          ),
          const SizedBox(height: 40),

          // Reasoning Trace
          Text("CHAIN-OF-VERIFICATION TRACE", style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              result.reasoningTrace,
              style: GoogleFonts.firaCode(color: Colors.white60, fontSize: 13, height: 1.6),
            ),
          ),
          const SizedBox(height: 40),

          // Recommendation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.cyanAccent.withOpacity(0.1), Colors.transparent]),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.recommend, color: Colors.cyanAccent),
                    const SizedBox(width: 8),
                    Text("RECOMMENDED ACTION", style: GoogleFonts.jetBrainsMono(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(result.recommendedAction, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
