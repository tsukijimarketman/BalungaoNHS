import 'package:cloud_firestore/cloud_firestore.dart';

Stream<QuerySnapshot> getNewcomersStudents(
   String selectedLevel, 
   int trackIconState, 
   int gradeLevelIconState, 
   int transfereeIconState, 
   String selectedStrand,
   String? selectedGrade) {
 
 print('Selected Level: $selectedLevel');
  Query query = FirebaseFirestore.instance.collection('users')
   .where('enrollment_status', isEqualTo: 'pending')
   .where('educ_level', isEqualTo: selectedLevel);
  // Grade level filtering based on education level
 if (selectedLevel == 'Senior High School') {
   // Para sa Track
   switch (trackIconState) {
     case 1:
       query = query.where('seniorHigh_Track', isEqualTo: 'Academic Track');
       break;
     case 2:
       query = query.where('seniorHigh_Track', isEqualTo: 'Technical-Vocational-Livelihood (TVL)');
       break;
     default:
       query = query.where('seniorHigh_Track', whereIn: ['Academic Track', 'Technical-Vocational-Livelihood (TVL)']);
   }
    // Grade level for Senior High
   if (gradeLevelIconState == 1) {
     query = query.where('grade_level', isEqualTo: '11');
   } else if (gradeLevelIconState == 2) {
     query = query.where('grade_level', isEqualTo: '12');
   }
    // para sa strand
   if (selectedStrand != 'ALL') {
     switch (selectedStrand) {
       case 'STEM':
         query = query.where('seniorHigh_Strand', isEqualTo: 'Science, Technology, Engineering and Mathematics (STEM)');
         break;
       case 'HUMSS':
         query = query.where('seniorHigh_Strand', isEqualTo: 'Humanities and Social Sciences (HUMSS)');
         break;
       case 'ABM':
         query = query.where('seniorHigh_Strand', isEqualTo: 'Accountancy, Business, and Management (ABM)');
         break;
       case 'ICT':
         query = query.where('seniorHigh_Strand', isEqualTo: 'Information and Communication Technology (ICT)');
         break;
       case 'COOKERY':
         query = query.where('seniorHigh_Strand', isEqualTo: 'Cookery (CO)');
         break;
     }
   }
 } else if (selectedLevel == 'Junior High School') {
   // Grade level filtering for Junior High
   if (selectedGrade != null && selectedGrade != 'All') {
     query = query.where('grade_level', isEqualTo: selectedGrade);
   }
 }
  // para sa transferee
 if (transfereeIconState == 1) {
   query = query.where('transferee', isEqualTo: 'yes');
 } else if (transfereeIconState == 2) {
   query = query.where('transferee', isEqualTo: 'no');
 }
  return query.snapshots();

}

Stream<QuerySnapshot> getReEnrolledStudents(String selectedLevel, 
   int trackIconState, 
   int gradeLevelIconState, 
   int transfereeIconState, 
   String selectedStrand,
   String? selectedGrade) {
  Query query = FirebaseFirestore.instance.collection('users')
    .where('enrollment_status', isEqualTo: 'reEnrollSubmitted')
    .where('educ_level', isEqualTo: selectedLevel);

   if (selectedLevel == 'Senior High School') {
   // Para sa Track
   switch (trackIconState) {
     case 1:
       query = query.where('seniorHigh_Track', isEqualTo: 'Academic Track');
       break;
     case 2:
       query = query.where('seniorHigh_Track', isEqualTo: 'Technical-Vocational-Livelihood (TVL)');
       break;
     default:
       query = query.where('seniorHigh_Track', whereIn: ['Academic Track', 'Technical-Vocational-Livelihood (TVL)']);
   }
    // Grade level for Senior High
   if (gradeLevelIconState == 1) {
     query = query.where('grade_level', isEqualTo: '11');
   } else if (gradeLevelIconState == 2) {
     query = query.where('grade_level', isEqualTo: '12');
   }
    // para sa strand
   if (selectedStrand != 'ALL') {
     switch (selectedStrand) {
       case 'STEM':
         query = query.where('seniorHigh_Strand', isEqualTo: 'Science, Technology, Engineering and Mathematics (STEM)');
         break;
       case 'HUMSS':
         query = query.where('seniorHigh_Strand', isEqualTo: 'Humanities and Social Sciences (HUMSS)');
         break;
       case 'ABM':
         query = query.where('seniorHigh_Strand', isEqualTo: 'Accountancy, Business, and Management (ABM)');
         break;
       case 'ICT':
         query = query.where('seniorHigh_Strand', isEqualTo: 'Information and Communication Technology (ICT)');
         break;
       case 'COOKERY':
         query = query.where('seniorHigh_Strand', isEqualTo: 'Cookery (CO)');
         break;
     }
   }
 } else if (selectedLevel == 'Junior High School') {
   // Grade level filtering for Junior High
   if (selectedGrade != null && selectedGrade != 'All') {
     query = query.where('grade_level', isEqualTo: selectedGrade);
   }
 }
  // para sa transferee
 if (transfereeIconState == 1) {
   query = query.where('transferee', isEqualTo: 'yes');
 } else if (transfereeIconState == 2) {
   query = query.where('transferee', isEqualTo: 'no');
 }
  return query.snapshots();

}