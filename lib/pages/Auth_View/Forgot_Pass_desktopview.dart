import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pbma_portal/pages/views/sections/desktop/desktop_view.dart';

class ForgotPassDesktopview extends StatefulWidget {
  final VoidCallback closeforgotpassCallback;
  const ForgotPassDesktopview({super.key, required this.closeforgotpassCallback});

  @override
  State<ForgotPassDesktopview> createState() => _ForgotPassDesktopviewState();
}

class _ForgotPassDesktopviewState extends State<ForgotPassDesktopview> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              content: Text('Password reset Link Sent! Check your Email'),
            );
          });
          Future.delayed(Duration(seconds: 3),() {
          Navigator.push(context, MaterialPageRoute(builder: (context) => DesktopView()
          )
          );
          }
        );
    } on FirebaseAuthException catch (e) {
      print(e);
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              content: Text(e.message.toString()),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close',style: TextStyle(color: Colors.blueAccent),),
                ),
              ],
            );
          }
        );
      }
    }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

        double cardWidth = screenWidth * 0.4;  // 40% of screen width
  double cardHeight = screenHeight * 0.85; // 85% of screen height
  double inputWidth = cardWidth * 0.85;    // 85% of card width
  
    return Center(
       child: Container(
        width: cardWidth,
        height: cardHeight,
        constraints: BoxConstraints(
          minWidth: 400,
          maxWidth: 800,
          minHeight: 600,
          maxHeight: 900,
        ),
        child: Card(
          child: Column(
                      children: [
                        Container(
                          alignment: Alignment.topRight,
                          child: IconButton(onPressed: widget.closeforgotpassCallback, 
                          icon: Icon(Icons.close_outlined)),
                        ),
                        Flexible(
                flex: 2,
                child: Image.asset(
                  'assets/PBMA.png',
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: cardHeight * 0.02),
                          Container(
                width: inputWidth,
                padding: EdgeInsets.symmetric(horizontal: cardWidth * 0.075),
                child: Text(
                  'Password Recovery',
                  style: TextStyle(
                    fontSize: cardWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: cardHeight * 0.02),
                         Container(
                width: inputWidth,
                padding: EdgeInsets.symmetric(horizontal: cardWidth * 0.075),
                child: Text(
                  'Please enter the Email Address you provided on the Enrollment Form',
                  style: TextStyle(
                    fontSize: cardWidth * 0.03,
                  ),
                ),
              ),

              SizedBox(height: cardHeight * 0.04),
                        Container(
                         width: inputWidth,
                height: cardHeight * 0.08,
                          child: CupertinoTextField(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Colors.grey.shade300),
                            controller: _emailController,
                            prefix: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Icon(Icons.email_outlined),
                            ),
                            placeholder: 'Email',
                          ),
                        ),
                      
              SizedBox(height: cardHeight * 0.04),
                        Container(
                           width: inputWidth,
                height: cardHeight * 0.06,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(
                                    Colors.deepPurpleAccent),
                                elevation: MaterialStateProperty.all<double>(5),
                                shape: MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              onPressed: passwordReset,
                              child: Text(
                                'Reset Password',
                                style: TextStyle(
                      fontSize: cardWidth * 0.04,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              )),
                        ),
                                                                  SizedBox(height: cardHeight * 0.02),

                      ],
                    ),
        ),
      ),
    );
  }
}
