
import 'package:intl/intl.dart';

class DateFormatting{

  static formatCommentDate(DateTime dateTime){
    return DateFormat('dd/MM/yyyy, hh:mm a').format(dateTime);
  }
}