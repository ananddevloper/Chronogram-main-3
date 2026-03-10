class EmailMask {
  static String maskEmail(String email) {
    if (email.isEmpty || !email.contains("@")) return email;

    List<String> parts = email.split("@");
    String name = parts[0];
    String domain = parts[1];

    // agar name chota hai to mask mat karo
    if (name.length <= 5) return email;

    String firstPart = name.substring(0, 2); // starting show
    String lastPart = name.substring(name.length - 2); // last 2 show

    String stars = "*" * (name.length - 5); // middle mask

    return "$firstPart$stars$lastPart@$domain";
  }
}