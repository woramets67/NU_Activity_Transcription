const String kVolunteer = 'จิตอาสา';
const String kFacultyActivity = 'กิจกรรมคณะ';
const List<String> kActivityKinds = [kVolunteer, kFacultyActivity];

const String kByQr = 'สแกน QR';
const String kBySupervisor = 'ผู้คุมยืนยันให้';

// กติกา QR
const double kMaxDistance = 200; // เมตร
const int kQrMaxAge = 15; // วินาที
const int kQrChangeEvery = 10; // วินาที

// ใช้ได้แค่ต้นแบบ
const String kQrSecret = 'nuat-273387-secret';

const List<String> kFaculties = [
  'วิทยาศาสตร์',
  'วิศวกรรมศาสตร์',
  'มนุษยศาสตร์',
  'สังคมศาสตร์',
  'บริหารธุรกิจ เศรษฐศาสตร์และการสื่อสาร',
  'เภสัชศาสตร์',
  'พยาบาลศาสตร์',
  'แพทยศาสตร์',
  'สหเวชศาสตร์',
  'ศึกษาศาสตร์',
  'นิติศาสตร์',
  'เกษตรศาสตร์ ทรัพยากรธรรมชาติและสิ่งแวดล้อม',
  'สถาปัตยกรรมศาสตร์ ศิลปะและการออกแบบ',
  'วิทยาศาสตร์การแพทย์',
];
