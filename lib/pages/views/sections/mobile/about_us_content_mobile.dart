import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutUsContentMobile extends StatefulWidget {
  const AboutUsContentMobile({super.key});

  @override
  State<AboutUsContentMobile> createState() => _AboutUsContentMobileState();
}

class _AboutUsContentMobileState extends State<AboutUsContentMobile> {
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
                        image: AssetImage("assets/mnhs2.jpg"),
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                          child: Text(
                        "Welcome to the largest school in Region 1,",
                        style: TextStyle(
                            color: Color(0xFF002f24),
                            fontFamily: "B",
                            fontSize: 25),
                      )),
                      Center(
                          child: Text(
                        "MANGALDAN NATIONAL HIGH SCHOOL",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: "BL",
                            fontSize: 55),
                      )),
                    ],
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
                  Text(
                    "The Story of Mangaldan National High School",
                    style: TextStyle(
                        fontFamily: "B",
                        fontSize: 25,
                        color: Color(0xFF03b97c)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Nestled in the heart of Mangaldan, Pangasinan, Mangaldan National High School (MNHS) stands as a beacon of learning and progress. With a history deeply rooted in the community, the school has grown from humble beginnings to become one of the most respected institutions in the region.",
                    style: TextStyle(fontFamily: "R", fontSize: 18),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "The Early Years",
                    style: TextStyle(
                        fontFamily: "B",
                        fontSize: 25,
                        color: Color(0xFF03b97c)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Mangaldan National High School was established in the mid-20th century, at a time when access to secondary education in rural areas was limited. The local government and community leaders recognized the pressing need for a high school to serve the youth of Mangaldan and its neighboring barangays. Driven by their shared vision of providing quality education, they worked tirelessly to secure funding, land, and resources for the school's construction. \n\nIn its first year, the school opened its doors to a small group of eager students, housed in modest classrooms made of wood and bamboo. The founding principal, a passionate educator, led a handful of dedicated teachers who were determined to provide a holistic education despite limited resources. Their commitment laid the foundation for the school's enduring legacy.",
                    style: TextStyle(fontFamily: "R", fontSize: 18),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Growth and Expansion",
                    style: TextStyle(
                        fontFamily: "B",
                        fontSize: 25,
                        color: Color(0xFF03b97c)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "As the years passed, Mangaldan National High School grew in both size and reputation. Enrollment steadily increased, prompting the construction of additional classrooms and facilities. By the 1980s, the school had transitioned to more modern infrastructure, with permanent buildings and expanded amenities, including a library, science laboratories, and a multi-purpose hall. \n\nThe school’s curriculum evolved to meet the changing needs of the times. Specialized programs in science, mathematics, and the arts were introduced, reflecting the school’s commitment to fostering well-rounded students. The dedication of its teachers and the enthusiasm of its students brought recognition not only within Pangasinan but also at the national level.The school’s curriculum evolved to meet the changing needs of the times. Specialized programs in science, mathematics, and the arts were introduced, reflecting the school’s commitment to fostering well-rounded students. The dedication of its teachers and the enthusiasm of its students brought recognition not only within Pangasinan but also at the national level.",
                    style: TextStyle(fontFamily: "R", fontSize: 18),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Endeavors and Achievements",
                    style: TextStyle(
                        fontFamily: "B",
                        fontSize: 25,
                        color: Color(0xFF03b97c)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Mangaldan National High School has always been more than just a place of academic learning. It has been a hub of cultural, athletic, and social endeavors. The school’s dance troupe and choir have won accolades in regional and national competitions, showcasing the rich talent of its students. Meanwhile, the school’s athletes have consistently brought home trophies in events such as track and field, basketball, and volleyball.\n\nIn recent years, the school has embraced technological advancements, integrating information and communication technology (ICT) into its teaching methods. The addition of computer laboratories and internet access has prepared students for the demands of the 21st century. Moreover, the school’s active participation in environmental programs and community outreach initiatives highlights its commitment to social responsibility.",
                    style: TextStyle(fontFamily: "R", fontSize: 18),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Challenges and Resilience",
                    style: TextStyle(
                        fontFamily: "B",
                        fontSize: 25,
                        color: Color(0xFF03b97c)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Like any institution, Mangaldan National High School has faced its share of challenges. Natural calamities, such as typhoons and floods, have tested the school’s resilience. However, the spirit of bayanihan—the Filipino tradition of communal unity—has always prevailed. Parents, teachers, students, and local officials have come together time and again to rebuild and improve the school, turning challenges into opportunities for growth.\n\nThe COVID-19 pandemic was another test of the school’s adaptability. With face-to-face classes suspended, MNHS quickly shifted to online and modular learning modalities. Teachers underwent training to deliver lessons virtually, and the community rallied to provide students with the tools they needed to continue their education.",
                    style: TextStyle(fontFamily: "R", fontSize: 18),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Looking to the Future",
                    style: TextStyle(
                        fontFamily: "B",
                        fontSize: 25,
                        color: Color(0xFF03b97c)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Today, Mangaldan National High School stands as a pillar of excellence and opportunity. It offers a wide array of strands under the Senior High School curriculum, catering to diverse interests and career paths—from Science, Technology, Engineering, and Mathematics (STEM) to Humanities and Social Sciences (HUMSS), and Technical-Vocational-Livelihood (TVL) tracks. The school’s alumni have gone on to excel in various fields, from medicine and engineering to education and public service, serving as living proof of MNHS’s transformative power.\n\nAs it looks to the future, Mangaldan National High School remains committed to its mission of nurturing young minds, fostering innovation, and building character. Guided by its core values of Mastery, Nurturing, Honor, and Service, MNHS continues to inspire hope and ambition in the hearts of its students and the community it serves.\n\nMangaldan National High School is more than just an institution; it is a legacy of learning, a source of pride, and a symbol of what a united community can achieve. The story of MNHS is not just its past but the bright futures it continues to create.",
                    style: TextStyle(fontFamily: "R", fontSize: 18),
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
                                "As a parent, I couldn’t have asked for a better school for my children. Mangaldan National High School not only excels in academics but also focuses on shaping students into responsible individuals. The teachers go above and beyond, ensuring every child gets the attention they deserve. My son’s confidence and love for learning have grown immensely since joining MNHS, and I’m proud to see him thriving both in and out of the classroom",
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
                                "Mangaldan National High School was the foundation of my dreams. The lessons I learned within its halls extended far beyond the classroom, instilling values of perseverance and hard work. The support from my teachers gave me the confidence to pursue a degree in engineering, and today, I am living my dream as a project manager at a top construction firm. I will always carry the legacy of MNHS with me.",
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
                                "Mangaldan National High School is more than just an institution—it’s a pillar of our community. Over the years, it has consistently produced outstanding graduates who contribute significantly to our town’s growth. From its innovative programs to its dedication to student success, MNHS is a school we’re all proud to have in Mangaldan. It truly embodies excellence in education.",
                                style: TextStyle(
                                  fontFamily: "R",
                                  fontSize: 13,
                                  color: Color(0xFF002f24),
                                ),
                              ),
                              Spacer(),
                              Text(
                                "— Mayor Alejandro Ramos, Mangaldan",
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
