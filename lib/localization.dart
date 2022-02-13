import 'package:auto_localized/annotations.dart';

@AutoLocalized(
  convertToCamelCase: true,
  generateGetterMethods: true,
  onBlankValueStrategy: OnBlankValueStrategy.error,
  locales: [
    AutoLocalizedLocale(
      languageCode: 'en',
      translationsFiles: ['lang/en.json'],
    ),
    AutoLocalizedLocale(
      languageCode: 'fi',
      translationsFiles: ['lang/fi.json'],
    ),
    AutoLocalizedLocale(
      languageCode: 'sv',
      translationsFiles: ['lang/sv.json'],
    ),
  ],
)
class $Langs {}
