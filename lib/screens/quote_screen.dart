import 'package:flutter/material.dart';
import 'package:greetings_admin/models/events.dart';
import 'package:greetings_admin/models/quotes.dart';
import 'package:greetings_admin/state/quoteState.dart';
import 'package:greetings_admin/state/religionstate.dart';
import 'package:provider/provider.dart';

class QuotesScreen extends StatefulWidget {
  final Event event;
  final String religionId;
  QuotesScreen({required this.event, required this.religionId});

  @override
  _QuotesScreenState createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  @override
  void initState() {
    super.initState();
    getQuotes();
  }

  getQuotes() {
    Provider.of<QuotesProvider>(context, listen: false)
        .fetchQuotes(widget.event);
  }

  @override
  Widget build(BuildContext context) {
    final quoteProvider = Provider.of<QuotesProvider>(context).quotes;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<QuotesProvider>(
              builder: (context, provider, _) {
                return Text(
                  'Quotes Count: ${Provider.of<QuotesProvider>(context, listen: false).quoteCount.toString()}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: quoteProvider.length,
              itemBuilder: (BuildContext context, int index) {
                print('Qhtoes ' + quoteProvider.length.toString());
                if (quoteProvider.isEmpty) {
                  return Center(
                    child: Text('No quotes available.'),
                  );
                }

                return QuoteItem(quoteProvider[index]);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child:
                QuoteInput(eventName: widget.event.name, event: widget.event),
          ),
        ],
      ),
    );
  }
}

class QuoteItem extends StatelessWidget {
  final Quote quote;

  QuoteItem(this.quote);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(quote.text),
      subtitle: Text('Added: ${quote.timestamp}'),
      // Add additional UI or functionality as needed
    );
  }
}

class QuoteInput extends StatefulWidget {
  final String eventName;
  final Event event;
  QuoteInput({required this.eventName, required this.event});
  @override
  _QuoteInputState createState() => _QuoteInputState();
}

class _QuoteInputState extends State<QuoteInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter a new quote',
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            Quote quote = Quote(
                id: '',
                text: _controller.text,
                timestamp: DateTime.now(),
                event: widget.eventName);
            final provider =
                Provider.of<QuotesProvider>(context, listen: false);
            provider.addQuote(quote, widget.event);
            _controller.clear();
          },
        ),
      ],
    );
  }
}
