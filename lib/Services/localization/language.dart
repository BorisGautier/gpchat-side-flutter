// ignore: todo
//TODO:---- All localizations settings----

class Language {
  final int id;
  final String flag;
  final String name;
  final String languageCode;
  final String languageNameInEnglish;

  Language(this.id, this.flag, this.name, this.languageCode,
      this.languageNameInEnglish);

  static List<Language> languageList() {
    return <Language>[
      Language(1, "🇺🇸", "English", "en", "English"),
      Language(2, "fr", "Français", "fr", "Français"),
    ];
  }
}
