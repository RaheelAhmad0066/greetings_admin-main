import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:greetings_admin/constants/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greetings_admin/models/events.dart';
import 'package:greetings_admin/models/religions.dart';
import 'package:greetings_admin/screens/quote_screen.dart';
import 'package:greetings_admin/state/quoteState.dart';
import 'package:greetings_admin/state/religionstate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _eventController = TextEditingController();
  String _selectedTag = 'All'; // Default selected tag
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchReligions();
  }

  List<Widget> itemPhotosWidgetList = <Widget>[];
  List<Widget> itemEventWidgetList = <Widget>[];

  final ImagePicker _picker = ImagePicker();
  File? file;
  XFile? photo;
  List<XFile> itemImagesList = <XFile>[];
  String downloadUrl = '';
  bool uploading = false;
  String religion = '';

  addImage(bool isEvent) {
    if (isEvent) {
      itemEventWidgetList.add(
        Padding(
          padding: const EdgeInsets.all(1.0),
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Container(
              height: 100,
              child: kIsWeb
                  ? Image.network(
                      File(photo!.path).path,
                      fit: BoxFit.contain,
                    )
                  : Image.file(
                      File(photo!.path),
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ),
      );
    } else {
      itemPhotosWidgetList.add(
        Padding(
          padding: const EdgeInsets.all(1.0),
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Container(
              height: 100,
              child: kIsWeb
                  ? Image.network(
                      File(photo!.path).path,
                      fit: BoxFit.contain,
                    )
                  : Image.file(
                      File(photo!.path),
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ),
      );
    }
  }

  pickPhotoFromGallery(bool isEvent) async {
    photo = await _picker.pickImage(
        source: ImageSource.gallery, maxHeight: 400, maxWidth: 600);
    if (photo != null) {
      setState(() {
        // itemImagesList = itemImagesList + photo!;
        addImage(isEvent);
      });
    }
  }

  Future upload() async {
    String productId = await uplaodImageAndSaveItemInfo();
    setState(() {
      uploading = false;
    });
  }

  Future<String> uplaodImageAndSaveItemInfo() async {
    setState(() {
      uploading = true;
    });
    PickedFile? pickedFile;
    String? productId = const Uuid().v4();
    // for (int i = 0; i < itemImagesList.length; i++) {
    //   file = File(itemImagesList[i].path);
    //   pickedFile = PickedFile(file!.path);

    //   await uploadImageToStorage(pickedFile, productId);
    // }
    file = File(photo!.path);
    pickedFile = PickedFile(file!.path);
    await uploadImageToStorage(pickedFile, productId);
    return productId;
  }

  uploadImageToStorage(PickedFile? pickedFile, String productId) async {
    String? pId = const Uuid().v4();
    Reference reference = FirebaseStorage.instance
        .ref()
        .child('Pictures/${DateTime.now().toString()}');
    await reference.putData(
      await pickedFile!.readAsBytes(),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    String value = await reference.getDownloadURL();
    downloadUrl = value;
    return downloadUrl;
  }

  fetchReligions() {
    Provider.of<ReligionEventsProvider>(context, listen: false)
        .fetchReligions();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final religionModal = Provider.of<ReligionEventsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Greeting - Religions',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: religionModal.religions.length,
              itemBuilder: (BuildContext context, int index) {
                if (kDebugMode) {
                  print(religionModal.religions.length.toString());
                }
                final religion = religionModal.religions[index];
                return Padding(
                  padding: const EdgeInsets.only(
                      top: 0, bottom: 0, right: 12, left: 12),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: primaryColor,
                    child: ExpansionTile(
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      leading: ClipRRect(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ), // Leading icon
                      title: Text(
                        religion.name,
                        style:
                            TextStyle(color: Colors.white), // Title text color
                      ),

                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              decoration: BoxDecoration(
                                color: Colors.white60,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16.0),
                                  bottomLeft: Radius.circular(16.0),
                                ),
                              ),
                              width: size.width * 0.3,
                              child: TextField(
                                // style: TextStyle(color: Colors.),
                                controller: _eventController,
                                decoration: InputDecoration(
                                  icon: IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () async {
                                      try {
                                        final body = {
                                          "to":
                                              'cYOSgOcxTsiP2MJUA6tlet:APA91bF1MTd6uwGJMg4Ltq2fbBk8cPGfBLBtMDP6KJzv6Ngqa5aX_Dcz2CXIZ8FMeREwJ9ODHKT55F9Ug3KGUlzTTHtaC_g6JvssZHw3wMkVPWM21mtT_3lTleJS-SpgYbATnTqRhboS',
                                          "notification": {
                                            "title": religion
                                                .name, //our name should be send
                                            "body": _eventController.text,
                                            "android_channel_id": "chats"
                                          },
                                        };

                                        var res = await post(
                                            Uri.parse(
                                                'https://fcm.googleapis.com/fcm/send'),
                                            headers: {
                                              HttpHeaders.contentTypeHeader:
                                                  'application/json',
                                              HttpHeaders.authorizationHeader:
                                                  'AAAAm-pFa00:APA91bElkI7FVI0JspHsbzxrH4ZK1p5FvnlkN5H7xptTMyKmzpPULBLqgHQLNzJ6n-itUMz1_wy9PaA1Z9ruHuf-FyM0auzfcqr0zflQdjrqWERhb_8R4nj43DSgFeutVP1cwRjvyixA'
                                            },
                                            body: jsonEncode(body));
                                        log('Response status: ${res.statusCode}');
                                        log('Response body: ${res.body}');
                                      } catch (e) {}

                                      upload().then((value) {
                                        Event event = Event(
                                          id: '',
                                          name: _eventController.text,
                                          greetingCount: 0,
                                          userCount: 0,
                                          imageUrl: downloadUrl,
                                          religion: religionModal
                                              .religions[index].name,
                                        );
                                        Provider.of<ReligionEventsProvider>(
                                                context,
                                                listen: false)
                                            .addEvent(religion, event);
                                        downloadUrl = '';
                                      });
                                    },
                                  ),
                                  hintText: 'Add New event name',
                                  hintStyle: TextStyle(color: primaryColor),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  color: Colors.white70,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade200,
                                      offset: const Offset(0.0, 0.5),
                                      blurRadius: 30.0,
                                    )
                                  ]),
                              width: 100,
                              height: 100.0,
                              child: Center(
                                  child: itemEventWidgetList.isEmpty
                                      ? Center(
                                          child: MaterialButton(
                                            onPressed: () =>
                                                pickPhotoFromGallery(true),
                                            child: Container(
                                              alignment: Alignment.bottomCenter,
                                              child: Center(
                                                child: Image.network(
                                                  "https://static.thenounproject.com/png/3322766-200.png",
                                                  height: 100.0,
                                                  width: 100.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          height: 200,
                                          child: itemEventWidgetList[0],
                                        )),
                            ),
                          ],
                        ),
                        Consumer<ReligionEventsProvider>(
                          builder: (context, provider, _) {
                            if (provider.religions[index].events.isEmpty) {
                              return Center(
                                child: Text(
                                  'No Events available.',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount:
                                  provider.religions[index].events.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => QuotesScreen(
                                          event: religion.events[index],
                                          religionId: religion.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Divider(),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(religion.events[index].name),
                                            Row(
                                              children: [
                                                Text('Greetings:' +
                                                    religion.events[index]
                                                        .greetingCount
                                                        .toString()),
                                                SizedBox(width: 8),
                                                Text('Users ' +
                                                    religion
                                                        .events[index].userCount
                                                        .toString()),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                      trailing: Text(
                        'User Count: ${religion.count}',
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16), // Tag text color
                      ), // Trailing icon
                    ),
                  ),
                );
              },
            ),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                child: Container(
                  width: size.width * 0.3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Create a New Religion'),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: Colors.white70,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                offset: const Offset(0.0, 0.5),
                                blurRadius: 30.0,
                              )
                            ]),
                        width: 200,
                        height: 200.0,
                        child: Center(
                            child: itemPhotosWidgetList.isEmpty
                                ? Center(
                                    child: MaterialButton(
                                      onPressed: () =>
                                          pickPhotoFromGallery(false),
                                      child: Container(
                                        alignment: Alignment.bottomCenter,
                                        child: Center(
                                          child: Image.network(
                                            "https://static.thenounproject.com/png/3322766-200.png",
                                            height: 100.0,
                                            width: 100.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 200,
                                    child: itemPhotosWidgetList[0],
                                  )),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ButtonStyle(backgroundColor:
                              MaterialStateColor.resolveWith((states) {
                            return primaryColor!;
                          })),
                          onPressed: () {
                            // Handle Save button press, e.g., save the data
                            String name = _nameController.text;
                            upload().then((value) {
                              Religion religion = Religion(
                                id: '',
                                count: 0,
                                name: name,
                                events: [],
                                imageUrl: downloadUrl,
                              );
                              // Add your logic to save the data or perform any other action
                              Provider.of<ReligionEventsProvider>(context,
                                      listen: false)
                                  .createReligion(religion);
                              downloadUrl = '';
                            });
                          },
                          child: Text(
                            'Save',
                            style: TextStyle(color: secondayColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
