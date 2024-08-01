import 'package:flutter/material.dart';
import 'package:pbma_portal/pages/enrollment_form.dart';

class TacMobileView extends StatefulWidget {
  final VoidCallback closeTAC;

  const TacMobileView({super.key, required this.closeTAC});

  @override
  State<TacMobileView> createState() => _TacMobileViewState();
}

class _TacMobileViewState extends State<TacMobileView> {
  bool _isChecked = false;

  void _onContinuePressed() {
    if (_isChecked) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EnrollmentForm()),
      );
    } else {
      widget.closeTAC();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Center(
      child: Container(
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10)
        ),
        child: Card(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      onPressed: widget.closeTAC,
                      icon: Icon(Icons.close_outlined)),
                ),
                Text(
                  'Terms and Conditions',
                  style: TextStyle(fontFamily: "B", fontSize: 25),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                    child: Text(
                      '     1. Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum',
                      style: TextStyle(fontFamily: "B", fontSize: 14),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                    child: Text(
                      '     2. Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum',
                      style: TextStyle(fontFamily: "B", fontSize: 14),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                    child: Text(
                      '     3. Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum',
                      style: TextStyle(fontFamily: "B", fontSize: 14),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                    child: Text(
                      '     4. Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum',
                      style: TextStyle(fontFamily: "B", fontSize: 14),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                    child: Text(
                      '     5. Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum',
                      style: TextStyle(fontFamily: "B", fontSize: 14),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                    child: Text(
                      '     6. Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum',
                      style: TextStyle(fontFamily: "B", fontSize: 14),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                    child: Text(
                      '     7. Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum',
                      style: TextStyle(fontFamily: "B", fontSize: 14),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                    child: Text(
                      '     8. Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum',
                      style: TextStyle(fontFamily: "B", fontSize: 14),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                    child: Text(
                      '     9. Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum',
                      style: TextStyle(fontFamily: "B", fontSize: 14),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                    child: Text(
                      '     10. Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum',
                      style: TextStyle(fontFamily: "B", fontSize: 14),
                    )),
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: Colors.blueAccent,
                        checkColor: Colors.white,
                        value: _isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            _isChecked = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          'I agree to the terms and conditions',
                          style: TextStyle(fontFamily: "B", fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: screenWidth / 3,
                  height: screenHeight / 20,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            Colors.deepPurpleAccent),
                        elevation: WidgetStateProperty.all<double>(5),
                        shape: WidgetStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    onPressed: _onContinuePressed,
                    child: Text('Continue',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),),
                  ),
                ),
                SizedBox(height: screenHeight / 30,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
