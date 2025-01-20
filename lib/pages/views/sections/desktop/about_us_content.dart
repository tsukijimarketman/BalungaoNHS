import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutUsContent extends StatefulWidget {
  const AboutUsContent({super.key});

  @override
  State<AboutUsContent> createState() => _AboutUsContentState();
}

class _AboutUsContentState extends State<AboutUsContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: const Color.fromARGB(88, 173, 173, 173),
      child: Container(
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.width / 9,
          left: MediaQuery.of(context).size.width / 17,
          right: MediaQuery.of(context).size.width / 17,
          bottom: MediaQuery.of(context).size.width / 20,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(255, 235, 235, 235),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      image: DecorationImage(
                        image: AssetImage("assets/webnhs.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: Color(0x6565f058)
                          .withOpacity(0.3), // Blend color with opacity
                    ),
                  ),
                ],
              ),
              width: MediaQuery.of(context).size.width,
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Balungao National High School",
                      style: TextStyle(
                          fontFamily: "B",
                          fontSize: 30,
                          color: Color(0xFF03b97c)),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "“ The Filipino youth must emerge as valued and respected participant in the global community, equipped with competitive work skills and possessing a deep sense of national identity”…such was the closing statement of then President Fidel V. Ramos during the opening of the 1995 Educators’ Congress at Baguio City on May 15-19, 1995. President Gloria Macapagal Arroyo mentioned that a stone is worthless unless it becomes part of an edifice. President Benigno C. Aquino III reiterates time and again the vital role of the youth towards national development.",
                    style: TextStyle(fontFamily: "R", fontSize: 18),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Today, the Balungao National High School, twenty-two (22) year after its founding, is slowly gaining recognition as an educational institution in this part of our province. Originally composed, in 1997, of 250 students housed in a 5 room building and manned by an Principal and 8 faculty members, the school, now on its 28th year of operations is comprised of 1428 students, a Principal IV,1 Asst.SHS Principal II, 4 department heads, 58 strong and able faculty members, 4 administrative officers, 1 School Nurse, and 4 security guards.",
                    style: TextStyle(fontFamily: "R", fontSize: 18),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Ever inspired by the above challenge, not withstanding the disparity in the ratio of teachers from a vis a vis the great number of students, the school continues in its fulfillment of its mission of preparing the youth for their future roles as responsible adults. Despite the numerous problems which the school is undergoing, with the school still wanting in so many facilities, the school personnel, with Mrs. Rachel T. Pande, Principal IV, at the helm, holding the reins of the Administration, take the stand of solidarity and commitment in their effort to propel the BALUNGAO NATIONAL HIGH SCHOOL upward and wiggle it out of its humble beginnings.",
                    style: TextStyle(fontFamily: "R", fontSize: 18),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "With full support from the government and the community, BETTER DAYS ARE YET TO COME, MORE ACCOMPLISHMENTS ARE YET TO BE ADDED TO BNHS GLORIES!!!",
                    style: TextStyle(fontFamily: "M", fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  color: Color(0xFFA1f9D0)),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.school,
                                color: Color(0xFF002f24),
                                size: 70,
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Our Graduates",
                                      style: TextStyle(
                                        fontFamily: "B",
                                        fontSize: 17,
                                        color: Color(0xFF002f24),
                                      ),
                                    ),
                                    Text(
                                      "Join our community of successful graduates and unlock your potential.",
                                      style: TextStyle(
                                        fontFamily: "R",
                                        fontSize: 14,
                                        color: Color(0xFF002f24),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_filled_sharp,
                                color: Color(0xFF002f24),
                                size: 70,
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Flexible Schedules",
                                      style: TextStyle(
                                        fontFamily: "B",
                                        fontSize: 17,
                                        color: Color(0xFF002f24),
                                      ),
                                    ),
                                    Text(
                                      "Choose the schedule that fits your lifestyle and achieve your academic.",
                                      style: TextStyle(
                                        fontFamily: "R",
                                        fontSize: 14,
                                        color: Color(0xFF002f24),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.groups_2,
                                color: Color(0xFF002f24),
                                size: 70,
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Dedicated Staff",
                                      style: TextStyle(
                                        fontFamily: "B",
                                        fontSize: 17,
                                        color: Color(0xFF002f24),
                                      ),
                                    ),
                                    Text(
                                      "Join our community of successful graduates and unlock your potential.",
                                      style: TextStyle(
                                        fontFamily: "R",
                                        fontSize: 14,
                                        color: Color(0xFF002f24),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Divider(),
                    SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: Text(
                        "Reviews and Testimonials",
                        style: TextStyle(
                          fontFamily: "B",
                          fontSize: 25,
                          color: Color(0xFF002f24),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 350,
                          height: 350,
                          padding: EdgeInsets.all(20),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.format_quote_rounded,
                                color: Color(0xFF002f24),
                                size: 50,
                              ),
                              Text(
                                "As a parent, I couldn’t have asked for a better school for my children. Balungao National High School not only excels in academics but also focuses on shaping students into responsible individuals. The teachers go above and beyond, ensuring every child gets the attention they deserve. My son’s confidence and love for learning have grown immensely since joining BNHS, and I’m proud to see him thriving both in and out of the classroom",
                                style: TextStyle(
                                  fontFamily: "R",
                                  fontSize: 13,
                                  color: Color(0xFF002f24),
                                ),
                              ),
                              Spacer(),
                              Text(
                                "— Maria Santos, Proud Parent",
                                style: TextStyle(
                                  fontFamily: "B",
                                  fontSize: 15,
                                  color: Color(0xFF002f24),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          width: 350,
                          height: 350,
                          padding: EdgeInsets.all(20),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.format_quote_rounded,
                                color: Color(0xFF002f24),
                                size: 50,
                              ),
                              Text(
                                "Balungao National High School was the foundation of my dreams. The lessons I learned within its halls extended far beyond the classroom, instilling values of perseverance and hard work. The support from my teachers gave me the confidence to pursue a degree in engineering, and today, I am living my dream as a project manager at a top construction firm. I will always carry the legacy of BNHS with me.",
                                style: TextStyle(
                                  fontFamily: "R",
                                  fontSize: 13,
                                  color: Color(0xFF002f24),
                                ),
                              ),
                              Spacer(),
                              Text(
                                "— Engr. Mark dela Cruz, Class of 2012",
                                style: TextStyle(
                                  fontFamily: "B",
                                  fontSize: 15,
                                  color: Color(0xFF002f24),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          width: 350,
                          height: 350,
                          padding: EdgeInsets.all(20),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.format_quote_rounded,
                                color: Color(0xFF002f24),
                                size: 50,
                              ),
                              Text(
                                "Balungao National High School is more than just an institution—it’s a pillar of our community. Over the years, it has consistently produced outstanding graduates who contribute significantly to our town’s growth. From its innovative programs to its dedication to student success, BNHS is a school we’re all proud to have in Balungao. It truly embodies excellence in education.",
                                style: TextStyle(
                                  fontFamily: "R",
                                  fontSize: 13,
                                  color: Color(0xFF002f24),
                                ),
                              ),
                              Spacer(),
                              Text(
                                "— Mayor Alejandro Ramos, Balungao",
                                style: TextStyle(
                                  fontFamily: "B",
                                  fontSize: 15,
                                  color: Color(0xFF002f24),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
