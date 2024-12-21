import 'package:flutter/material.dart';

class FavoritePosts extends StatefulWidget {
  const FavoritePosts({super.key});

  @override
  State<FavoritePosts> createState() => _FavoritePostsState();
}

class _FavoritePostsState extends State<FavoritePosts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("รายการโปรด"),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(child: Text("data"),
      )
    );
  }
}