import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/models/document_type.dart';
import '../../core/theme/app_theme.dart';
import 'bloc/smart_assistant_bloc.dart';

class SmartAssistantWidget extends StatefulWidget {
  final String documentText;

  const SmartAssistantWidget({
    super.key,
    required this.documentText,
  });

  @override
  State<SmartAssistantWidget> createState() => _SmartAssistantWidgetState();
}

class _SmartAssistantWidgetState extends State<SmartAssistantWidget>
    with TickerProviderStateMixin {
  final TextEditingController _queryController = TextEditingController();
  final List<QueryResponse> _queryHistory = [];
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Automatically analyze document when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SmartAssistantBloc>().add(AnalyzeDocument(widget.documentText));
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDarkMode),
          const Divider(height: 1),
          _buildContent(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Assistant',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  'AI-powered document analysis',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    return BlocConsumer<SmartAssistantBloc, SmartAssistantState>(
      listener: (context, state) {
        if (state is SmartAssistantQueryResponse) {
          setState(() {
            _queryHistory.add(QueryResponse(state.query, state.response));
          });
          _queryController.clear();
        }
      },
      builder: (context, state) {
        if (state is SmartAssistantAnalyzing) {
          return _buildAnalyzingState(isDarkMode);
        }

        if (state is SmartAssistantAnalysisComplete) {
          return _buildAnalysisComplete(state.analysis, isDarkMode);
        }

        if (state is SmartAssistantError) {
          return _buildErrorState(state.message, isDarkMode);
        }

        return _buildInitialState(isDarkMode);
      },
    );
  }

  Widget _buildAnalyzingState(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircularProgressIndicator(color: AppTheme.primaryGreen),
          const SizedBox(height: 16),
          Text(
            'Analyzing document...',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisComplete(SmartAnalysis analysis, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDocumentTypeCard(analysis, isDarkMode),
          const SizedBox(height: 16),
          _buildQuickFacts(analysis, isDarkMode),
          const SizedBox(height: 16),
          _buildSuggestedQuestions(analysis, isDarkMode),
          const SizedBox(height: 16),
          _buildQueryHistory(isDarkMode),
          _buildQueryInput(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildDocumentTypeCard(SmartAnalysis analysis, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Text(
            analysis.documentType.icon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  analysis.documentType.displayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  'Confidence: ${(analysis.confidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFacts(SmartAnalysis analysis, bool isDarkMode) {
    if (analysis.quickFacts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Facts',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ...analysis.quickFacts.entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppTheme.accentBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                    children: [
                      TextSpan(
                        text: '${entry.key}: ',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: entry.value),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildSuggestedQuestions(SmartAnalysis analysis, bool isDarkMode) {
    if (analysis.suggestedQuestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggested Questions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: analysis.suggestedQuestions.take(3).map((question) {
            return GestureDetector(
              onTap: () => _askQuestion(question),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.accentBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  question,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.accentBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQueryHistory(bool isDarkMode) {
    if (_queryHistory.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conversation',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _queryHistory.length,
            itemBuilder: (context, index) {
              final item = _queryHistory[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.query,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? Colors.grey[800] 
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.response,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildQueryInput(bool isDarkMode) {
    return BlocBuilder<SmartAssistantBloc, SmartAssistantState>(
      builder: (context, state) {
        final isProcessing = state is SmartAssistantProcessingQuery;
        
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: _queryController,
                enabled: !isProcessing,
                decoration: InputDecoration(
                  hintText: 'Ask a question about this document...',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primaryGreen),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                onSubmitted: isProcessing ? null : _askQuestion,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: isProcessing ? null : () => _askQuestion(_queryController.text),
                icon: isProcessing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState(String message, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        'Ready to analyze document...',
        style: TextStyle(
          fontSize: 16,
          color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
        ),
      ),
    );
  }

  void _askQuestion(String question) {
    if (question.trim().isEmpty) return;
    
    context.read<SmartAssistantBloc>().add(ProcessFollowUpQuery(question.trim()));
  }
}

class QueryResponse {
  final String query;
  final String response;

  QueryResponse(this.query, this.response);
}