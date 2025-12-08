import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../../services/api_service.dart';
import '../../models/message_model.dart';
import '../../config/base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'video_page.dart';



class ChatPage extends StatefulWidget {
  final int chatId;
  final int idTeknisi;
  ChatPage({required this.chatId, required this.idTeknisi});


  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<MessageModel> messages = [];
  TextEditingController controller = TextEditingController();
  final picker = ImagePicker();
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  int myId = 0;
  String myName = "";
  String myRole = "";

  String? otherPhone;
  String? otherName;
  int? otherUserId;

  String formatDateLabel(String dateString) {
    final dt = DateTime.parse(dateString);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return "Hari ini";
    if (diff == 1) return "Kemarin";

    // kalau masih dalam minggu yang sama → tampilkan nama hari
    if (diff < 7) {
      return DateFormat('EEEE', 'id_ID').format(dt); // Senin, Selasa, ...
    }

    // sisanya pake tanggal normal
    return DateFormat('dd MMM yyyy').format(dt);
  }


  final ScrollController scrollController = ScrollController();

    Future<void> deleteMessage(int idMessage) async {
      print("=== MULAI DELETE PESAN ===");
      print("ID MESSAGE: $idMessage");
      print("ENDPOINT: /chat/message/$idMessage");

      final res = await ApiService.delete("/chat/message/$idMessage");

      print("HASIL DELETE SERVER: $res");

      final statusCode = res['statusCode'] as int?;
      final data = res['data'];

      if (statusCode == 200) {
        print("DELETE BERHASIL, hapus dari list...");
        setState(() {
          messages.removeWhere((m) => m.idMessage == idMessage);
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Pesan dihapus")));
      } else {
        print("❌ DELETE GAGAL");
        print("STATUS CODE: $statusCode");
        print("DATA: $data");

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Gagal menghapus pesan")));
      }

      print("=== SELESAI DELETE ===");
    }




  void confirmDelete(MessageModel m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Hapus pesan?"),
        content: Text("Pesan ini akan dihapus."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              deleteMessage(m.idMessage);
              Navigator.pop(context);
            },
            child: Text(
              "Hapus",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  } 


late Future<void> _localeInit;

@override
void initState() {
  super.initState();
  _localeInit = initializeDateFormatting('id_ID', null).then((_) {
    Intl.defaultLocale = 'id_ID';
  });
    loadUser();
    loadMessages();
    setupRealtime();
    loadOtherUser();
}
  


  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    String? userJson = prefs.getString('user');

    if (userJson != null) {
      final user = jsonDecode(userJson);

      setState(() {
        myId = user['id_user'];
        myName = user['nama'];
        myRole = (user['role'] ?? "").toString().toLowerCase();
      });

      print("USER LOGIN -> ID: $myId | ROLE: $myRole");
    }
  }




  Future<void> loadOtherUser() async {
    final res = await ApiService.get('/chat/${widget.chatId}/detail');

    print("DETAIL CHAT: $res");

    if (!mounted) return;

    // ambil isi sebenarnya dari API
    final body = res['data'];

    if (body != null && body['status'] == true) {
      final data = body['data'];

      setState(() {
        otherUserId = data['other_id'];
        otherPhone  = data['other_phone'];
        otherName   = data['other_name'];

        print("LAWAN CHAT -> ID: $otherUserId | HP: $otherPhone");
      });
    } else {
      print("GAGAL AMBIL LAWAN CHAT: ${body?['message']}");
    }
  }



  Future<void> callOtherUser() async {
    if (otherPhone == null || otherPhone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nomor lawan chat tidak tersedia")),
      );
      return;
    }

    final Uri uri = Uri.parse("tel:$otherPhone");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tidak dapat membuka telepon")),
      );
    }
  }


  Future<void> setupRealtime() async {
    await pusher.init(
      apiKey: '01cf58de43745499fa3f',
      cluster: 'ap1',
      onEvent: (event) {
        print("event: ${event.data}");
      },
    );

    await pusher.connect();

    await pusher.subscribe(
      channelName: "private-chat.${widget.chatId}",
      onEvent: (event) {
        if (event.data == null) return;

        final payload = jsonDecode(event.data.toString());

        final msg = MessageModel.fromJson(payload['message']);

        setState(() => messages.add(msg));
      },
    );

  }

  Future<void> loadMessages() async {
    final res = await ApiService.get('/chat/${widget.chatId}/messages');

    if (res['statusCode'] == 200 && res['data'] != null) {
      final data = res['data']['messages'] as List;
      

      setState(() {
        Future.delayed(Duration(milliseconds: 200), scrollToBottom);
        messages = data.map((e) => MessageModel.fromJson(e)).toList();
      });
    }
  }

  void scrollToBottom() {
    if (!scrollController.hasClients) return;

    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }


  

  Future<void> sendText() async {
    final nowLabel = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final text = controller.text.trim();
    if (text.isEmpty) return;

    // ✅ buat pesan sementara (dummy)
    final tempMessage = MessageModel(
      idMessage: DateTime.now().millisecondsSinceEpoch * -1, // id fake biar unik
      senderUserId: myId,
      senderTeknisiId: null,
      message: text,
      type: "text",
      createdAt: nowLabel,

    );

    // ✅ langsung insert ke list biar bubble muncul
    setState(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
      messages.add(tempMessage);
      controller.clear();
    });

    // ✅ scroll otomatis ke bawah
    Future.delayed(Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        Future.delayed(Duration(milliseconds: 100), scrollToBottom);
      }
    });

    // ✅ kirim ke server
    final res = await ApiService.post(
      endpoint: '/chat/send',
      data: {
        "id_chat": widget.chatId,
        "message": text,
      },
    );

    if (res['statusCode'] != 200) {
      print("❌ Gagal mengirim pesan ke server");
    }
  }




  Future<void> sendFile() async {
    final nowLabel = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final picked = await picker.pickMedia();
    if (picked == null) return;

    final fileSize = await picked.length();

    if (fileSize > 30 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ukuran file maksimal 30MB")),
      );
      return;
    }

    final isVideo = picked.mimeType?.contains("video") ?? false;

    // ✅ buat message sementara
    final tempMessage = MessageModel(
      idMessage: DateTime.now().millisecondsSinceEpoch * -1,
      senderUserId: myId,
      message: null,
      type: isVideo ? "video" : "image",
      fileUrl: picked.path, // local path dulu
      thumbnailUrl: isVideo ? null : picked.path,
      createdAt: nowLabel,
    );

    setState(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());

      messages.add(tempMessage);
    });

    // ✅ kirim ke server
    final fd = FormData.fromMap({
      "id_chat": widget.chatId,
      "file": await MultipartFile.fromFile(picked.path),
    });

    final res = await ApiService.postMultipart('/chat/send', fd);

    if (res['statusCode'] != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengirim file")),
      );
    }
  }

  String prettyDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch(_) {
      return iso;
    }
  }


  Map<String, List<MessageModel>> groupByDate(List<MessageModel> msgs) {
    Map<String, List<MessageModel>> result = {};
    for (var m in msgs) {
      final created = m.createdAt ?? "";
      String key;
      // coba parse ke DateTime, kalau gagal fallback ke substring/jadi kosong
      try {
        final dt = DateTime.parse(created);
        key = DateFormat('yyyy-MM-dd').format(dt);
      } catch (_) {
        key = (created.length >= 10) ? created.substring(0, 10) : created;
      }
      result.putIfAbsent(key, () => []);
      result[key]!.add(m);
    }
    return result;
  }

  String prettyTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }



  Widget dateDivider(String d) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Divider()),
          SizedBox(width: 8),
          Text(
            d,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          SizedBox(width: 8),
          Expanded(child: Divider()),
        ],
      ),
    );
  }



  @override
  void dispose() {
    pusher.unsubscribe(channelName: "private-chat.${widget.chatId}");
    pusher.disconnect();

    super.dispose();
  }

  Widget bubble(MessageModel m) {
    final isMe = (m.senderUserId == myId);
    final maxWidth = MediaQuery.of(context).size.width * 0.7;

    return GestureDetector(
      onLongPress: m.senderUserId == myId
        ? () => confirmDelete(m)
        : null,
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isMe ? Color(0xFF0C4481) : Color(0xFFE8ECEF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 2),
                bottomRight: Radius.circular(isMe ? 2 : 18),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [

              GestureDetector(
                onLongPress: () {
                  confirmDelete(m);
                },
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    // elemen-elemen lain (image/video/text/time)
                  ]
                ),

              ),


              /// ✅ IMAGE VIEW
              if (m.type == "image" && m.fileUrl != null)
              GestureDetector(
                onTap: () async {
                  final uri = Uri.parse(m.fileUrl!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: m.fileUrl!.startsWith("http")
                      ? Image.network(m.fileUrl!, fit: BoxFit.cover)
                      : Image.file(File(m.fileUrl!), fit: BoxFit.cover),
                ),
              ),



              /// ✅ VIDEO PREVIEW
              if (m.type == "video" && m.fileUrl != null)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoPage(url: m.fileUrl!),
                    ),
                  );
                },
                child: Container(
                  width: 200,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black12,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (m.thumbnailUrl != null && m.thumbnailUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            m.thumbnailUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),

                      const Icon(
                        Icons.play_circle_fill,
                        size: 60,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),




              /// ✅ TEXT
              if (m.message != null && m.message!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    m.message!,
                    style: TextStyle(
                      fontSize: 15,
                      color: isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                ),

              SizedBox(height: 5),

              /// ✅ TIME
                Text(
                  prettyTime(m.createdAt ?? ""),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _localeInit,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // Tampilkan loading dulu sampai locale siap
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Locale sudah siap, build UI normal
        final grouped = groupByDate(messages).entries.toList()
          ..sort((a, b) => b.key.compareTo(a.key));

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF0C4481),
            foregroundColor: Color.fromARGB(255, 232, 232, 233),
            elevation: 0,
            titleSpacing: 0,
            title: Row(
              children: [
                SizedBox(width: 10),
                CircleAvatar(radius: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherName ?? "Memuat...",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Online",
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.call, color: Colors.white),
                onPressed: callOtherUser,
              ),
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: Colors.white),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                itemBuilder: (context) => [
                  PopupMenuItem(child: Text("Tampilkan Profil")),
                  PopupMenuItem(child: Text("Laporkan pengguna ini")),
                  PopupMenuItem(child: Text("Butuh bantuan?")),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: scrollController,
                  reverse: true,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  children: grouped.map((g) {
                    return Column(
                      children: [
                        dateDivider(formatDateLabel(g.key)),
                        ...g.value.map((m) => bubble(m)).toList(),
                      ],
                    );
                  }).toList(),
                ),
              ),
              // 🔥 INPUT CHAT
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.attach_file, color: Colors.grey),
                    onPressed: sendFile,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      margin: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Ketik pesanmu disini",
                        ),
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFF0C4481),
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: sendText,
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

