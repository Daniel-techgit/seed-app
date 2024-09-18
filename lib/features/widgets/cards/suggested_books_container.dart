import 'package:price_app/features/utils/exports.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SuggestedBooksContainer extends StatefulWidget {
  final String category;
  final Function() onArrowPressed;

  const SuggestedBooksContainer({
    super.key,
    required this.category,
    required this.onArrowPressed,
  });

  @override
  _SuggestedBooksContainerState createState() => _SuggestedBooksContainerState();
}

class _SuggestedBooksContainerState extends State<SuggestedBooksContainer> {
  List<BookModel> suggestedBooks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSuggestedBooks();
  }

  Future<void> fetchSuggestedBooks() async {
    setState(() => _isLoading = true);
    try {
      final String apiUrl = widget.category.isNotEmpty
          ? 'https://seedapp.vercel.app/api/suggested?category=${widget.category}'
          : 'https://seedapp.vercel.app/api/suggested';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          suggestedBooks = (data[0] as List).map((book) => BookModel.fromJson(book)).toList();
        });
      } else {
        // Handle error
        print('Failed to load suggested books');
      }
    } catch (e) {
      print('Error fetching suggested books: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: suggestedBooks.isEmpty
              ? const SizedBox(
            height: 120,
            child: Center(child: Text('No suggested books available')),
          )
              : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ...suggestedBooks.map(
                        (book) => GestureDetector(
                      onTap: () {
                        print(book.title);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailsScreen(
                              bookId: book.id,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.network(
                            book.imageUrl,
                            height: 120,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onArrowPressed,
                    icon: const Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}