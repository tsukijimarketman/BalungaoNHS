import 'package:cloud_firestore/cloud_firestore.dart';

Stream<QuerySnapshot> getFilteredStudents(int trackIconState, int gradeLevelIconState, int transfereeIconState, String selectedStrand) {
  Query query = FirebaseFirestore.instance.collection('users')
    .where('enrollment_status', isEqualTo: 'approved');

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
  // para sa grade level
  if (gradeLevelIconState == 1) {
    query = query.where('grade_level', isEqualTo: '11');
  } else if (gradeLevelIconState == 2) {
    query = query.where('grade_level', isEqualTo: '12');
  } else {
    // Mag Show ang 11 at 12
  }
  // para sa transferee
  if (transfereeIconState == 1) {
    query = query.where('transferee', isEqualTo: 'yes');
  } else if (transfereeIconState == 2) {
    query = query.where('transferee', isEqualTo: 'no');
  } else {
    // Mag Show and yes at no
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
      case 'HE':
        query = query.where('seniorHigh_Strand', isEqualTo: 'Home Economics (HE)');
        break;
      case 'IA':
        query = query.where('seniorHigh_Strand', isEqualTo: 'Industrial Arts (IA)');
        break;
    }
  }

  return query.snapshots();
}

Stream<QuerySnapshot> getNewcomersStudents(int trackIconState, int gradeLevelIconState, int transfereeIconState, String selectedStrand) {
  Query query = FirebaseFirestore.instance.collection('users')
    .where('enrollment_status', isEqualTo: 'pending');

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
  // para sa grade level
  if (gradeLevelIconState == 1) {
    query = query.where('grade_level', isEqualTo: '11');
  } else if (gradeLevelIconState == 2) {
    query = query.where('grade_level', isEqualTo: '12');
  } else {
    // Mag Show ang 11 at 12
  }
  // para sa transferee
  if (transfereeIconState == 1) {
    query = query.where('transferee', isEqualTo: 'yes');
  } else if (transfereeIconState == 2) {
    query = query.where('transferee', isEqualTo: 'no');
  } else {
    // Mag Show and yes at no
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
      case 'HE':
        query = query.where('seniorHigh_Strand', isEqualTo: 'Home Economics (HE)');
        break;
      case 'IA':
        query = query.where('seniorHigh_Strand', isEqualTo: 'Industrial Arts (IA)');
        break;
    }
  }

  return query.snapshots();
}

Stream<QuerySnapshot> getReEnrolledStudents(int trackIconState, int gradeLevelIconState, int transfereeIconState, String selectedStrand) {
  Query query = FirebaseFirestore.instance.collection('users')
    .where('enrollment_status', isEqualTo: 'reEnrollSubmitted');

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
  // para sa grade level
  if (gradeLevelIconState == 1) {
    query = query.where('grade_level', isEqualTo: '11');
  } else if (gradeLevelIconState == 2) {
    query = query.where('grade_level', isEqualTo: '12');
  } else {
    // Mag Show ang 11 at 12
  }
  // para sa transferee
  if (transfereeIconState == 1) {
    query = query.where('transferee', isEqualTo: 'yes');
  } else if (transfereeIconState == 2) {
    query = query.where('transferee', isEqualTo: 'no');
  } else {
    // Mag Show and yes at no
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
      case 'HE':
        query = query.where('seniorHigh_Strand', isEqualTo: 'Home Economics (HE)');
        break;
      case 'IA':
        query = query.where('seniorHigh_Strand', isEqualTo: 'Industrial Arts (IA)');
        break;
    }
  }

  return query.snapshots();
}