import 'package:flutter/material.dart';

class MenuLateral extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:const BoxConstraints(
        maxWidth: 260, 
         ),
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Image.asset('assets/logo_app.png', width: 170, height: 170),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 60, left: 25, right: 25),
              child: Container(
                height: 55,
                child: MaterialButton(
                  onPressed: () {
                    
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), 
                  ),
                  color: const Color(0xFF0049AC), 
                  textColor: Colors.white, 
                  child: const Text(
                      'Intinerário',
                      style: TextStyle(
                        fontSize: 19.0, 
                      ),
                  ),
                ),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 25, right: 25),
              child: Container(
                height: 55,
                child: MaterialButton(
                  onPressed: () {
                    
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), 
                  ),
                  color: const Color(0xFF0049AC), 
                  textColor: Colors.white, 
                  child: const Text(
                      'Entre como adm',
                      style: TextStyle(
                        fontSize: 18.0, 
                      ),
                  ),
                ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
