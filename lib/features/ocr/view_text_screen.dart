import 'package:flutter/material.dart';

class ViewTextScreen extends StatefulWidget {
  final List<String> extractedTexts;
  final int initialPage;

  const ViewTextScreen({
    super.key,
    required this.extractedTexts,
    this.initialPage = 0,
  });

  @override
  State<ViewTextScreen> createState() => _ViewTextScreenState();
}

class _ViewTextScreenState extends State<ViewTextScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page ${_currentPage + 1} of ${widget.extractedTexts.length}'),
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[200],
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.extractedTexts.length,
          onPageChanged: (page) {
            setState(() {
              _currentPage = page;
            });
          },
          itemBuilder: (context, index) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  widget.extractedTexts[index],
                  style: const TextStyle(
                    fontSize: 16.0,
                    height: 1.5,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
