import 'package:flutter/material.dart';

import '../examples/examples.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("rail")),
      body: SafeArea(
        child: ListView.separated(
          itemBuilder: (context, index) => _ExampleListTile(examples[index]),
          separatorBuilder: (context, index) => const Divider(height: 0),
          itemCount: examples.length,
        ),
      ),
    );
  }
}

class _ExampleListTile extends StatelessWidget {
  final Example example;

  const _ExampleListTile(this.example);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(example.name),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => example.widget)),
    );
  }
}
