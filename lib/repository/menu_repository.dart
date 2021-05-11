import 'package:akbmobile/api/api_helper.dart';
import 'package:akbmobile/models/menu_response.dart';

class MenuRepository {
  ApiHelper _helper = ApiHelper();

  Future<MenuResponse> getMenus({int page, String category, String query}) async {
    var url = "menu?page=$page";
    if (category != null) {
      url = url + "&category[]=$category";
    }
    if (query != null) {
      url = url + "&query=$query";
    }
    final response = await _helper.get(url);
    print(response.toString());
    return MenuResponse.fromJson(response['data']);
  }
}