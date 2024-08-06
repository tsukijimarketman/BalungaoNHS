import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pbma_portal/pages/views/mobile_view.dart';

class ForgotPassMobileview extends StatefulWidget {
  final VoidCallback closeforgotpassCallback;
  const ForgotPassMobileview({super.key, required this.closeforgotpassCallback});

  @override
  State<ForgotPassMobileview> createState() => _ForgotPassMobileviewState();
}

class _ForgotPassMobileviewState extends State<ForgotPassMobileview> {
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => MobileView()
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
    return Center(
      child: Container(
        width: screenWidth / 1.2,
        height: screenHeight / 1.2,
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
        child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topRight,
                        child: IconButton(onPressed: widget.closeforgotpassCallback, 
                        icon: Icon(Icons.close_outlined)),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 80),
                          child: Image.asset(
                            'assets/PBMA.png',
                            width: screenWidth / 2,
                            height: screenHeight / 2.5,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 52.0),
                          child: Text(
                            'Password Recovery',
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                       Container(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 52.0),
                          child: Text(
                            'Please the Email Address you Provided on Enrollment Form',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: screenHeight / 14,
                        width: screenWidth / 1.44,
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
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: screenHeight / 14,
                        width: screenWidth / 1.44,
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )),
                      ),
                      
                    ],
                  ),
      ),
    );
  }
}
