import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as d;
import 'package:provider/provider.dart';
import 'package:runnin_us/const/color.dart';
import 'package:runnin_us/const/dummy.dart';
import 'package:runnin_us/googlemap/create_waiting_room.dart';
import 'package:runnin_us/provider/enter_check.dart';

const TextStyle ts = TextStyle(
  color: Colors.white,
  fontSize: 20,
  fontWeight: FontWeight.w500,
);

class WaitingRoomScreen extends StatefulWidget {
  const WaitingRoomScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  late EnterCheck _enterCheck;
  @override
  Widget build(BuildContext context) {
    _enterCheck = Provider.of<EnterCheck>(context);

    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _enterCheck.EnterCreateRoom();
                  },
                  child: Text('대기실 생성'),
                  style: ElevatedButton.styleFrom(
                    primary: MINT_COLOR,
                  ),
                )
              ],
            ),
          ),
        ),
        Expanded(
          flex: 7,
          child: FutureBuilder(
              future: Geolocator.getCurrentPosition(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData == false) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                LatLng nowLatLng =
                    LatLng(snapshot.data.latitude, snapshot.data.longitude);

                print(nowLatLng);
                return RefreshIndicator(
                  onRefresh: () {
                    setState(() {});
                    return Geolocator.getCurrentPosition();
                  },
                  child: ListView.separated(
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        return renderWaitingRoom(
                          index,
                          nowLatLng,
                        );
                      },
                      separatorBuilder: (context, index) {
                        if (index % 8 == 0 && index != 0) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            child: Text('광고 노출 배너'),
                          );
                        }
                        return SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 30,
                          child: Text(''),
                        );
                      },
                      itemCount: waitingRoom.length),
                );
              }),
        ),
      ],
    );
  }

  renderWaitingRoom(
    int index,
    LatLng data,
  ) {
    final LatLng latlng = LatLng(double.parse(waitingRoom[index]['latitude']),
        double.parse(waitingRoom[index]['longitude']));
    final CameraPosition cp = CameraPosition(target: latlng, zoom: 17);
    final Marker marker =
        Marker(markerId: MarkerId('marker$index'), position: latlng);
    final double distance = d.Distance().as(
        d.LengthUnit.Kilometer,
        d.LatLng(latlng.latitude, latlng.longitude),
        d.LatLng(data.latitude, data.longitude));
    print(latlng);
    print(distance);
    print(marker.markerId);

    return GestureDetector(
      onTap: () {
        //async await 으로 구성
        //인덱스 값 서버 전송
        //인덱스 값 받아옴
        //받아온 인덱스로 대기실 구성
        //출력
        print(enteredWaitingRoom);
        print(enteredWaitingRoom['member'].length);
        print(enteredWaitingRoom['member'].values.toList());
        if (enteredWaitingRoom['member'].length > 3) {
          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                title: Text('입장 실패'),
                content: Text('사유 : 정원이 초과되었습니다.'),
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
        } else if (int.parse(enteredWaitingRoom['level']) >
            int.parse(myPageList[0]['level'])) {
          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                title: Text('입장 실패'),
                content: Text('사유 : 입장 레벨이 너무 높습니다.'),
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
        } else {
          print('입장');
          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                title: Text('대기실 입장'),
                content: Text('입장하시겠습니까?'),
                actions: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: PINK_COLOR),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('취소')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: MINT_COLOR),
                      onPressed: () {
                        _enterCheck.Enter();
                        Navigator.of(context).pop();
                      },
                      child: Text('확인'))
                ],
              );
            },
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: MINT_COLOR.withOpacity(0.7),
        ),
        height: MediaQuery.of(context).size.width / 4,
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: GoogleMap(
                onTap: (value) {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height / 2,
                          child: GoogleMap(
                            initialCameraPosition: cp,
                            markers: {marker},
                          ),
                        );
                      });
                },
                zoomControlsEnabled: false,
                initialCameraPosition: cp,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 3 / 4 - 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      '방장 : ${waitingRoom[index]['host']},',
                      style: ts,
                    ),
                  ),
                  Center(
                    child: Text(
                      '시작시간 : ${waitingRoom[index]['startTime']} ~ 종료시간 : ${waitingRoom[index]['endTime']}',
                      style: ts.copyWith(fontSize: 16),
                    ),
                  ),
                  Center(
                    child: Text(
                      '운동레벨 : ${waitingRoom[index]['level']}',
                      style: ts,
                    ),
                  ),
                  Center(
                    child: Text(
                      '현재 사용자와의 거리 : ${distance}km',
                      style: ts,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}