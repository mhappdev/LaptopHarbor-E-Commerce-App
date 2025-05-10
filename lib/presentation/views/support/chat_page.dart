// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:gradient_borders/box_borders/gradient_box_border.dart';
// import 'package:http/http.dart' as http;

// class ChatPage extends StatefulWidget {
//   static const routeName = '/chat';
//   const ChatPage({super.key});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _chatController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   List<Map<String, dynamic>> _chatHistory = [];
//   Future<void> getAnswer() async {
//     const String apiKey =
//         'AIzaSyBWxcTzcLZUYMXfayibqUngyM6eTtzyyNU'; // Replace with your actual API key
//     final url = Uri.parse(
//         'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey');

//     final headers = {
//       'Content-Type': 'application/json',
//     };

//     List<Map<String, String>> msg = [];
//     for (var i = 0; i < _chatHistory.length; i++) {
//       msg.add({"content": _chatHistory[i]["message"]});
//     }
//     print([msg]);
//     print(msg[0]["content"]);
//     final body = jsonEncode({
//       "contents": [
//         {
//           "parts": [
//             {"text": msg[0]["content"].toString()}
//           ]
//         }
//       ]
//     });
//     final response = await http.post(url, headers: headers, body: body);
//     print(response.body);

//     setState(() {
//       _chatHistory.add({
//         "time": DateTime.now(),
//         "message": json
//             .decode(response.body)["candidates"][0]["content"]["parts"][0]
//                 ["text"]
//             .toString(),
//         "isSender": false,
//       });
//     });

//     _scrollController.jumpTo(
//       _scrollController.position.maxScrollExtent,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Chat",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: Stack(
//         children: [
//           Container(
//             //get max height
//             height: MediaQuery.of(context).size.height - 160,
//             child: ListView.builder(
//               itemCount: _chatHistory.length,
//               shrinkWrap: false,
//               controller: _scrollController,
//               padding: const EdgeInsets.only(top: 10, bottom: 10),
//               physics: const BouncingScrollPhysics(),
//               itemBuilder: (context, index) {
//                 return Container(
//                   padding:
//                       EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
//                   child: Align(
//                     alignment: (_chatHistory[index]["isSender"]
//                         ? Alignment.topRight
//                         : Alignment.topLeft),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.5),
//                             spreadRadius: 2,
//                             blurRadius: 5,
//                             offset: const Offset(0, 3),
//                           ),
//                         ],
//                         color: (_chatHistory[index]["isSender"]
//                             ? Color(0xFFF69170)
//                             : Colors.white),
//                       ),
//                       padding: EdgeInsets.all(16),
//                       child: Text(_chatHistory[index]["message"],
//                           style: TextStyle(
//                               fontSize: 15,
//                               color: _chatHistory[index]["isSender"]
//                                   ? Colors.white
//                                   : Colors.black)),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               height: 60,
//               width: double.infinity,
//               color: Colors.white,
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         border: GradientBoxBorder(
//                           gradient: LinearGradient(
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                               colors: [
//                                 Color(0xFFF69170),
//                                 Color(0xFF7D96E6),
//                               ]),
//                         ),
//                         borderRadius: BorderRadius.all(Radius.circular(50.0)),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child: TextField(
//                           decoration: const InputDecoration(
//                             hintText: "Type a message",
//                             border: InputBorder.none,
//                             contentPadding: EdgeInsets.all(8.0),
//                           ),
//                           controller: _chatController,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 4.0,
//                   ),
//                   MaterialButton(
//                     onPressed: () {},
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(80.0)),
//                     padding: const EdgeInsets.all(0.0),
//                     child: Ink(
//                       decoration: const BoxDecoration(
//                         gradient: LinearGradient(
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                             colors: [
//                               Color(0xFFF69170),
//                               Color(0xFF7D96E6),
//                             ]),
//                         borderRadius: BorderRadius.all(Radius.circular(50.0)),
//                       ),
//                       child: Container(
//                           constraints: const BoxConstraints(
//                               minWidth: 88.0,
//                               minHeight:
//                                   36.0), // min sizes for Material buttons
//                           alignment: Alignment.center,
//                           child: GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   if (_chatController.text.isNotEmpty) {
//                                     _chatHistory.add({
//                                       "time": DateTime.now(),
//                                       "message": _chatController.text,
//                                       "isSender": true,
//                                     });
//                                     getAnswer();
//                                     _chatController.clear();
//                                   }
//                                 });
//                                 _scrollController.jumpTo(
//                                   _scrollController.position.maxScrollExtent,
//                                 );
//                               },
//                               child: const Icon(
//                                 Icons.send,
//                                 color: Colors.white,
//                               ))),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  static const routeName = '/chat';
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _chatHistory = [];
  final Color _primaryColor = const Color(0xff037EEE);
  final Color _secondaryColor = Colors.white;

  Future<void> getAnswer() async {
    const String apiKey =
        'AIzaSyBWxcTzcLZUYMXfayibqUngyM6eTtzyyNU'; // Replace with your actual API key
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey');

    final headers = {
      'Content-Type': 'application/json',
    };

    List<Map<String, String>> msg = [];
    for (var i = 0; i < _chatHistory.length; i++) {
      msg.add({"content": _chatHistory[i]["message"]});
    }
    print([msg]);
    print(msg[0]["content"]);
    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": msg[0]["content"].toString()}
          ]
        }
      ]
    });
    final response = await http.post(url, headers: headers, body: body);
    print(response.body);

    setState(() {
      _chatHistory.add({
        "time": DateTime.now(),
        "message": json
            .decode(response.body)["candidates"][0]["content"]["parts"][0]
                ["text"]
            .toString(),
        "isSender": false,
      });
    });

    _scrollController.jumpTo(
      _scrollController.position.maxScrollExtent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chat Assistant",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primaryColor,
        foregroundColor: _secondaryColor,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
              ),
              child: ListView.builder(
                itemCount: _chatHistory.length,
                shrinkWrap: false,
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 80),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 8,
                        bottom: 8),
                    child: Align(
                      alignment: (_chatHistory[index]["isSender"]
                          ? Alignment.topRight
                          : Alignment.topLeft),
                      child: Column(
                        crossAxisAlignment: _chatHistory[index]["isSender"]
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(_chatHistory[index]["isSender"] ? 16 : 0),
                                topRight: Radius.circular(_chatHistory[index]["isSender"] ? 0 : 16),
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                              color: (_chatHistory[index]["isSender"]
                                  ? _primaryColor
                                  : Colors.white),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                              ),
                        ],),
                            padding: EdgeInsets.all(12),
                            child: Text(
                              _chatHistory[index]["message"],
                              style: TextStyle(
                                fontSize: 15,
                                color: _chatHistory[index]["isSender"]
                                    ? _secondaryColor
                                    : Colors.grey[800],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _chatHistory[index]["time"] != null
                                  ? "${_chatHistory[index]["time"].hour}:${_chatHistory[index]["time"].minute.toString().padLeft(2, '0')}"
                                  : "",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: _secondaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: "Type your message...",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          controller: _chatController,
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          if (_chatController.text.isNotEmpty) {
                            _chatHistory.add({
                              "time": DateTime.now(),
                              "message": _chatController.text,
                              "isSender": true,
                            });
                            getAnswer();
                            _chatController.clear();
                          }
                        });
                        _scrollController.jumpTo(
                          _scrollController.position.maxScrollExtent,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}