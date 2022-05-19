import 'package:dio/dio.dart';
import 'package:runnin_us/const/dummy.dart';

Future<bool?> EnterWaitingRoomApi(int roomId) async {

  try {
    var dio = await Dio().request(
      'http://runninus-api.befined.com:8000/v1/meet/join',
      data: {"meet_id": roomId, "user_id": 15},
      options: Options(method: 'POST'),
    );

    myEnteredRoom['roomName'] = dio.data['results'][0]['NAME'].toString();
    myEnteredRoom['host'] = dio.data['results'][0]['HOST'].toString();
    myEnteredRoom['latitude'] = dio.data['results'][0]['POINT']['y'].toString();
    myEnteredRoom['longitude'] =
        dio.data['results'][0]['POINT']['x'].toString();
    myEnteredRoom['runningLength'] =
        dio.data['results'][0]['EX_DISTANCE'].toString();
    myEnteredRoom['startTime'] =
        dio.data['results'][0]['EX_START_TIME'].split('.')[0].split('T')[1];
    myEnteredRoom['endTime'] =
        dio.data['results'][0]['EX_END_TIME'].split('.')[0].split('T')[1];
    myEnteredRoom['level'] = dio.data['results'][0]['LEVEL'].toString();
    myEnteredRoom['maxMember'] = dio.data['results'][0]['MAX_NUM'].toString();
    print(myEnteredRoom);

    return dio.data['isSuccess'];
  } catch (e) {
    print(e);
  }
}
