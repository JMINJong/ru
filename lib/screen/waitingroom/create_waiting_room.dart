import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:runnin_us/api/create_waiting_room_api.dart';
import 'package:runnin_us/const/color.dart';
import 'package:runnin_us/const/dummy.dart';
import '../../provider/enter_check.dart';

//대기실 생성 화면

List selectedButtonLevel = [1, 2, 3, 4, 5];
List selectedButtonLevel2 = [6, 7, 8, 9, 10];
List maxNumber = [2, 3, 4, 5];

class CreateWaitingRoom extends StatefulWidget {
  const CreateWaitingRoom({Key? key}) : super(key: key);

  @override
  _CreateWaitingRoomState createState() => _CreateWaitingRoomState();
}

class _CreateWaitingRoomState extends State<CreateWaitingRoom> {
  static LatLng defaultLatLng = LatLng(37.435308, 127.138625);
  late LatLng selectedLatLng;
  String selectedDate = '';
  String selectedStartTime = '';
  String selectedEndTime = '';
  int selectedLevel = 0;
  int maxMemberCount = 0;
  int selectedButtonIndex = 0;
  int selectedMaxNumberIndex = 0;
  int today = 200;
  int startHour = 200;
  int startMinute = 200;
  String dateButton = '날짜';
  String startButton = '시작 시간';
  String endButton = '종료 시간';
  Color buttonColorDay = MINT_COLOR;
  Color buttonColorStart = MINT_COLOR;
  Color buttonColorEnd = MINT_COLOR;
  String roomName = '${myPageList[0]['name']} 님의 방';
  double runningLength = 5;

  static CameraPosition initialPosition =
      CameraPosition(target: defaultLatLng, zoom: 15);
  static Circle defaultCircle = Circle(
    circleId: CircleId('circle'),
    radius: 100,
    center: defaultLatLng,
    fillColor: Colors.grey.withOpacity(0.3),
    strokeWidth: 1,
  );
  static Marker defaultMarker =
      Marker(markerId: MarkerId('marker'), position: defaultLatLng);
  late GoogleMapController _controller;
  late EnterCheck _enterCheck;

  @override
  Widget build(BuildContext context) {
    _enterCheck = Provider.of<EnterCheck>(context);
    return renderGmap();
  }

  Widget renderGmap() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height - kToolbarHeight - 160,
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: MINT_COLOR, width: 2),
                ),
                // height: MediaQuery.of(context).size.height - kToolbarHeight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 16,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                roomName = value;
                              });
                            },
                            decoration: InputDecoration(
                              label: Text(roomName),
                            ),
                            maxLength: 10,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 3 - 30,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: buttonColorDay,
                              ),
                              onPressed: () {
                                Future<DateTime?> sD = showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 7,
                                  ),
                                );
                                sD.then(
                                  (value) => setState(
                                    () {
                                      if (value == null) {
                                        dateButton = '날짜';
                                      } else {
                                        buttonColorDay = PINK_COLOR;
                                        dateButton =
                                            value.toString().split(' ')[0];
                                        selectedDate = value.toString();
                                        today = value.day;
                                      }
                                    },
                                  ),
                                );
                              },
                              child: Text(dateButton),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 3 - 30,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: buttonColorStart,
                              ),
                              onPressed: () {
                                Future<TimeOfDay?> sT = showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );

                                sT.then(
                                  (value) {
                                    if (today == 200) {
                                      showToast('날짜를 먼저 선택해주세요.');
                                      return false;
                                    }

                                    if (today == DateTime.now().day) {
                                      if (value!.hour < DateTime.now().hour) {
                                        showToast('시작 시간은 현재 시간보다 빠를 수 없습니다.');
                                        return false;
                                      } else if (value.hour ==
                                          DateTime.now().hour) {
                                        if (value.minute <=
                                            DateTime.now().minute) {
                                          showToast(
                                              '시작 시간은 현재 시간보다 같거나 빠를 수 없습니다.');
                                          return false;
                                        } else {
                                          if (((60 - value.minute) -
                                                      (60 -
                                                          DateTime.now()
                                                              .minute))
                                                  .abs() <
                                              15) {
                                            showToast(
                                                '시작 시간은 현재 시간보다 최소 15분 뒤여야 합니다.');
                                            return false;
                                          }
                                        }
                                      }
                                    }
                                    if (value!.hour ==
                                        DateTime.now().hour + 1) {
                                      if (DateTime.now().minute >= 45) {
                                        int diff = 60 - DateTime.now().minute;
                                        if (value.minute < (15 - diff)) {
                                          showToast(
                                              '시작 시간은 현재 시간보다 최소 15분 뒤여야 합니다.');
                                          return false;
                                        }
                                      }
                                    }

                                    setState(
                                      () {
                                        buttonColorStart = PINK_COLOR;
                                        startButton =
                                            '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
                                        selectedStartTime =
                                            '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

                                        endButton = '종료시간';
                                        selectedEndTime = '';
                                      },
                                    );
                                    startHour = value.hour;
                                    startMinute = value.minute;
                                  },
                                );
                              },
                              child: Text(startButton),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 3 - 30,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: buttonColorEnd,
                              ),
                              onPressed: () {
                                Future<TimeOfDay?> eT = showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );

                                eT.then(
                                  (value) {
                                    if (startHour == 200 ||
                                        startMinute == 200) {
                                      showToast('날짜와 시작 시간을 먼저 선택해주세요.');
                                      return false;
                                    }
                                    if (value!.hour < startHour) {
                                      showToast('종료 시간은 시작 시간보다 빠를 수 없습니다.');
                                      return false;
                                    } else if (value.hour == startHour) {
                                      if (value.minute < startMinute + 15) {
                                        showToast(
                                            '종료 시간은 시작 시간보다 최소 15분 뒤여야 합니다.');
                                        return false;
                                      }
                                    }

                                    if (value.hour == startHour + 1) {
                                      if (startMinute >= 45) {
                                        int diff = 60 - startMinute;
                                        if (value.minute < (15 - diff)) {
                                          showToast(
                                              '종료 시간은 시작 시간보다 최소 15분 뒤여야 합니다.');
                                          return false;
                                        }
                                      }
                                    }

                                    setState(
                                      () {
                                        buttonColorEnd = PINK_COLOR;
                                        endButton =
                                            '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
                                        selectedEndTime =
                                            '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
                                      },
                                    );
                                  },
                                );
                              },
                              child: Text(endButton),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 2 -
                            kToolbarHeight -
                            50,
                        child: FutureBuilder(
                          future: Geolocator.getCurrentPosition(),
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.hasData == false) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            Position position = snapshot.data;
                            defaultLatLng =
                                LatLng(position.latitude, position.longitude);
                            initialPosition =
                                CameraPosition(target: defaultLatLng, zoom: 15);
                            return GoogleMap(
                              myLocationButtonEnabled: false,
                              onMapCreated: (controller) {
                                selectedLatLng = defaultLatLng;
                                setState(() {
                                  _controller = controller;
                                });
                              },
                              initialCameraPosition: initialPosition,
                              circles: {defaultCircle},
                              markers: {defaultMarker},
                              onTap: (LatLng index) {
                                setState(() {
                                  selectedLatLng = index;
                                  _controller.animateCamera(
                                      CameraUpdate.newLatLng(index));
                                  defaultMarker = Marker(
                                      markerId: MarkerId('marker1'),
                                      position: index);
                                  defaultCircle = Circle(
                                    circleId: CircleId('circle1'),
                                    radius: 100,
                                    center: index,
                                    fillColor: Colors.grey.withOpacity(0.3),
                                    strokeWidth: 1,
                                  );
                                });
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: selectedButtonLevel.map(
                                (e) {
                                  bool isChecked = false;
                                  if (selectedButtonIndex == e) {
                                    isChecked = true;
                                  }
                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: isChecked
                                            ? PINK_COLOR
                                            : MINT_COLOR),
                                    onPressed: () {
                                      setState(() {
                                        selectedButtonIndex = e;
                                        selectedLevel = e;
                                      });
                                    },
                                    child: Text('Lv $e'),
                                  );
                                },
                              ).toList()),
                          SizedBox(
                            height: 16,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: selectedButtonLevel2.map(
                                (e) {
                                  bool isChecked = false;
                                  if (selectedButtonIndex == e) {
                                    isChecked = true;
                                  }
                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: isChecked
                                            ? PINK_COLOR
                                            : MINT_COLOR),
                                    onPressed: () {
                                      setState(() {
                                        selectedButtonIndex = e;
                                        selectedLevel = e;
                                      });
                                    },
                                    child: Text('Lv $e'),
                                  );
                                },
                              ).toList()),
                          SizedBox(
                            height: 16,
                          ),
                          Column(
                            children: [
                              Text(
                                '${runningLength.toString().split('.')[0]} km',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '1 km',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Expanded(
                                    child: Slider(
                                      inactiveColor: MINT_COLOR,
                                      activeColor: PINK_COLOR,
                                      value: runningLength,
                                      onChanged: (value) {
                                        setState(() {
                                          runningLength = value;
                                        });
                                      },
                                      min: 1,
                                      max: 50,
                                    ),
                                  ),
                                  Text(
                                    '50 km',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: maxNumber.map(
                                (e) {
                                  bool isChecked = false;
                                  if (selectedMaxNumberIndex == e) {
                                    isChecked = true;
                                  }
                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary:
                                            isChecked ? PINK_COLOR : MINT_COLOR,
                                        shape: CircleBorder(),
                                        minimumSize: Size(55, 55)),
                                    onPressed: () {
                                      setState(() {
                                        selectedMaxNumberIndex = e;
                                        maxMemberCount = e;
                                      });
                                    },
                                    child: Text('정원 $e'),
                                  );
                                },
                              ).toList()),
                          SizedBox(
                            height: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  _enterCheck.CancelCreateRoom();
                },
                style: ElevatedButton.styleFrom(
                    primary: PINK_COLOR, minimumSize: Size(75, 37)),
                child: Text('취소'),
              ),
              ElevatedButton(
                onPressed: () async{
                  if (selectedEndTime == '' ||
                      selectedStartTime == '' ||
                      selectedDate == '') {
                    showToast('사유 : 생성 날짜를 선택해 주세요.');
                  } else if (selectedLevel == '' || maxMemberCount == '') {
                    showToast('사유 : 생성 옵션을 선택해 주세요.');
                  } else {
                    bool? isCreated=await CreateWaitingRoomApi(
                        roomName,
                        myPageList[0]['uid'],
                        selectedLatLng.latitude,
                        selectedLatLng.longitude,
                        maxMemberCount,
                        runningLength.round(),
                        selectedDate,
                        selectedStartTime,
                        selectedEndTime,
                        selectedLevel);
                    print(isCreated);

                    if(isCreated==true){

                      myEnteredRoom['roomName'] = roomName;
                      myEnteredRoom['host'] = myPageList[0]['name'];
                      myEnteredRoom['latitude'] =
                          selectedLatLng.latitude.toString();
                      myEnteredRoom['longitude'] =
                          selectedLatLng.longitude.toString();
                      myEnteredRoom['startTime'] = selectedStartTime;
                      myEnteredRoom['endTime'] = selectedEndTime;
                      myEnteredRoom['level'] = selectedLevel.toString();
                      myEnteredRoom['maxMember'] = maxMemberCount.toString();
                      myEnteredRoom['runningLength'] =
                      runningLength.toString().split('.')[0];

                      _enterCheck.CreateRoom();
                    }else{
                      print('생성실패');

                    }

                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: MINT_COLOR,
                ),
                child: Text('방 생성'),
              ),
            ],
          )
        ],
      ),
    );
  }

  showToast(String index) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('생성 실패'),
          content: Text(
            index,
            textAlign: TextAlign.center,
          ),
          actions: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(primary: PINK_COLOR),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'))
          ],
        );
      },
    );
  }
}
