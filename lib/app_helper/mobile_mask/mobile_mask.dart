class MobileMask {
     String maskNumber(String number) {
    // empty me bhi +91 show
    if (number.isEmpty) {
      return "+91 ";
    }

    // typing time
    if (number.length < 10) {
      return "+91 $number";
    }

    // 10 digit complete → mask
    String firstThree = number.substring(0, 3);
    String lastThree = number.substring(number.length - 3);
    return 
    "+91 $firstThree****$lastThree ";
  }
}