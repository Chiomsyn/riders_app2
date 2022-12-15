import 'package:flutter/material.dart';

class StarsWidget extends StatelessWidget {
  final int numberOfStars;
  const StarsWidget({Key? key, required this.numberOfStars}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch(numberOfStars){
      case 0:
        return getStarIcons(0);
      case 1:
        return getStarIcons(1);
      case 2:
        return getStarIcons(2);
      case 3:
        return getStarIcons(3);
      case 4:
        return getStarIcons(4);
      default:
        return getStarIcons(5);
    }
  }

 Widget getStarIcons(number){
    List<Widget> wid = [];
    for(int i=0; i<5; i++){
      if(i >= number){
        wid.add(Icon(Icons.star, color: Colors.grey.withOpacity(0.4)));
      }else{
        wid.add(const Icon(Icons.star, color: Colors.amber));
      }

    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: wid
    );
  }
}
