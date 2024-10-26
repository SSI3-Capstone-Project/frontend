import 'package:flutter/material.dart';

class CreatePostOffer extends StatefulWidget {
  const CreatePostOffer({super.key});

  @override
  State<CreatePostOffer> createState() => _CreatePostOfferState();
}

class _CreatePostOfferState extends State<CreatePostOffer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post and Offer'),
      ),
    );
  }
}
