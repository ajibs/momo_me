const List<String> list = <String>['Personal', 'Business'];

String composeCodeLink(String code, type) {
  if (type == 'Business') {
    return "tel:*182*8*1*$code#";
  }
  return "tel:*182*1*1*$code#";
}
