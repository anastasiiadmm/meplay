class Channel {
  String name, url;

  Channel(this.name, this.url);
}


class User {
  String token;
  String refreshToken;
  int id;

  User(this.token, this.refreshToken, this.id);
}
