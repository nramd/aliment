import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/models/article_model.dart';

class ArticleDetailPage extends StatefulWidget {
  final String articleId;

  const ArticleDetailPage({
    super.key,
    required this. articleId,
  });

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  bool _isLiked = false;
  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    final article = ArticleData.getById(widget.articleId);

    if (article == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text('Artikel tidak ditemukan'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    final formattedDate = DateFormat('MMMM dd, yyyy').format(article.publishedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    child: const Icon(Icons.arrow_back, color: AppColors.darker),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      article.category,
                      style: const TextStyle(
                        fontFamily: 'Gabarito',
                        fontSize: 18,
                        fontWeight:  FontWeight.bold,
                        color: AppColors.darker,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Image
                    AspectRatio(
                      aspectRatio: 16 / 10,
                      child: Image.network(
                        article. imageUrl,
                        fit:  BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.normal. withOpacity(0.3),
                            child: const Icon(Icons.image, size: 60, color: Colors.white),
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            article.title,
                            style: const TextStyle(
                              fontFamily: 'Gabarito',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darker,
                            ),
                          ),

                          const SizedBox(height:  12),

                          // Meta Info
                          Row(
                            children: [
                              Text(
                                _formatNumber(article.views),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                ' dilihat • $formattedDate',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Author Row
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.normal,
                                child: Text(
                                  article. authorAvatar,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  article.author,
                                  style: const TextStyle(
                                    fontFamily: 'Gabarito',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              // Like Button
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _isLiked = !_isLiked;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:  AppColors.light,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                                    color: _isLiked ? AppColors. normal : Colors.grey,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Save Button
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _isSaved = !_isSaved;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.light,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _isSaved ? Icons.favorite : Icons.favorite_border,
                                    color: _isSaved ? Colors.red : Colors.grey,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Divider
                          Divider(color: Colors.grey[200]),

                          const SizedBox(height: 16),

                          // Article Content
                          _buildContent(article.content),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(String content) {
    final lines = content.split('\n');
    List<Widget> widgets = [];

    for (var line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
      } else if (line.startsWith('## ')) {
        // H2 Heading
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              line.substring(3),
              style: const TextStyle(
                fontFamily:  'Gabarito',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darker,
              ),
            ),
          ),
        );
      } else if (line.startsWith('**') && line.endsWith('**')) {
        // Bold text
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              line.replaceAll('**', ''),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors. darker,
              ),
            ),
          ),
        );
      } else if (line.startsWith('- ')) {
        // List item
        widgets.add(
          Padding(
            padding:  const EdgeInsets.only(left: 8, bottom: 4),
            child:  Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (RegExp(r'^\d+\.  ').hasMatch(line)) {
        // Numbered list
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        );
      } else {
        // Normal paragraph
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child:  Text(
              line,
              style: TextStyle(
                fontSize: 14,
                color:  Colors.grey[700],
                height: 1.6,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}