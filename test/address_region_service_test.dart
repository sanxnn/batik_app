import 'package:batik_app/models/address_model.dart';
import 'package:batik_app/services/address_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('region requests preserve dotted codes and parse options', () async {
    final paths = <String>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          paths.add(options.path);
          handler.resolve(
            Response(
              requestOptions: options,
              data: {
                'data': [
                  {'code': '31.74.09', 'name': 'Pasar Minggu'},
                ],
              },
            ),
          );
        },
      ),
    );
    final service = AddressService(dio: dio);

    expect((await service.getProvinces()).single.name, 'Pasar Minggu');
    await service.getRegencies('31');
    await service.getDistricts('31.74');
    await service.getVillages('31.74.09');

    expect(paths, [
      '/regions/provinces',
      '/regions/regencies/31',
      '/regions/districts/31.74',
      '/regions/villages/31.74.09',
    ]);
  });

  test('address parses region codes and village', () {
    final address = AddressModel.fromJson({
      'id': 1,
      'province': 'DKI Jakarta',
      'province_code': '31',
      'city': 'Jakarta Selatan',
      'city_code': '31.74',
      'district': 'Pasar Minggu',
      'district_code': '31.74.09',
      'village': 'Pejaten Timur',
      'village_code': '31.74.09.1002',
    });
    expect(address.villageCode, '31.74.09.1002');
    expect(address.provinceCode, '31');
  });
}
