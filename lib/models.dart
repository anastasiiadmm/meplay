class Channel {
  int id;
  String name;
  String url;
  int number;
  bool locked;
  String logo;

  Channel({this.id, this.name, this.url, this.number, this.locked, this.logo});
  
  Channel.fromJson(Map<String, dynamic> data) {
    this.id = data['id'];
    this.name = data['name'];
    this.url = data['url'];
    this.number = data['number'];
    this.locked = data['locked'];
    this.logo = data['logo'];
  }
}


class User {
  String phone;
  String password;
  String token;
  String refreshToken;
  int id;

  User({this.phone, this.password, this.token, this.refreshToken, this.id});

  User.fromJson(Map<String, dynamic> data) {
    this.id = data['id'];
  }
}
