List phoneNumberVariantsList({
  String? phonenumber,
  String? countrycode,
}) {
  List list = [
    '+${countrycode!.substring(1)}$phonenumber',
    '+${countrycode.substring(1)}-$phonenumber',
    '${countrycode.substring(1)}-$phonenumber',
    '${countrycode.substring(1)}$phonenumber',
    '0${countrycode.substring(1)}$phonenumber',
    '0$phonenumber',
    '$phonenumber',
    '+$phonenumber',
    '+${countrycode.substring(1)}--$phonenumber',
    '00$phonenumber',
    '00${countrycode.substring(1)}$phonenumber',
    '+${countrycode.substring(1)}-0$phonenumber',
    '+${countrycode.substring(1)}0$phonenumber',
    '${countrycode.substring(1)}0$phonenumber',
  ];
  return list;
}
