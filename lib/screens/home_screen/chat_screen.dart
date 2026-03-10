import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dummyChats = [
      {"name": "Chronogram Team", "message": "Welcome to Chronogram! Let’s build something amazing 🚀", "time": "Just now", "unread": 1},
      {"name": "Aditya", "message": "Spring backend APIs are ready. Please review once.", "time": "2m", "unread": 2},
      {"name": "Atul", "message": "I found a small bug in registration flow. Sharing details.", "time": "1h", "unread": 0},
      {"name": "Anand", "message": "Flutter UI for registration is completed.", "time": "3h", "unread": 0},
      {"name": "Manish", "message": "Sunil told me about your app — looks impressive!", "time": "5h", "unread": 1},
  {"name": "Priyanka", "message": "Please ensure all modules are reviewed before the final release.", "time": "1d", "unread": 0},
      {"name": "Sunil", "message": "Good progress team. Let’s close pending tasks today.", "time": "1d", "unread": 0}
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("Chat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
      ),
      body: Column(
        children: [
          /// Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xff121212),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: const TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search users...",
                  hintStyle: TextStyle(color: Colors.white38),
                  prefixIcon: Icon(Icons.search, color: Colors.white38, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          
          const Divider(color: Colors.white12, height: 1),

          /// Chat List
          Expanded(
            child: ListView.separated(
              itemCount: dummyChats.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 1),
              itemBuilder: (context, index) {
                final chat = dummyChats[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  leading: Stack(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.orange, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(chat["name"]),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                        ),
                      )
                    ],
                  ),
                  title: Text(
                    chat["name"],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      chat["message"],
                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        chat["time"],
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                      const SizedBox(height: 6),
                      if (chat["unread"] > 0)
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "${chat["unread"]}",
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        )
                      else
                        const SizedBox(height: 20, width: 20, child: Icon(Icons.chevron_right, color: Colors.white38, size: 18)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "U";
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
