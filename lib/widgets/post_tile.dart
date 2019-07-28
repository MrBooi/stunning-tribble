
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/custom_image.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile(this.post);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print('full version of post'),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
