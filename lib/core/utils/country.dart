/// ISO country from an E.164 phone number. Mirrors
/// functions/src/lib/country.ts; unknown prefixes are "OTHER".
const _prefixes = [
  ('+977', 'NP'),
  ('+971', 'AE'),
  ('+966', 'SA'),
  ('+974', 'QA'),
  ('+965', 'KW'),
  ('+968', 'OM'),
  ('+973', 'BH'),
  ('+91', 'IN'),
  ('+65', 'SG'),
  ('+60', 'MY'),
  ('+44', 'GB'),
  ('+61', 'AU'),
  ('+64', 'NZ'),
  ('+1', 'US'),
]; // longest prefixes first

String countryFromPhone(String? phone) {
  final p = (phone ?? '').replaceAll(' ', '');
  for (final (prefix, cc) in _prefixes) {
    if (p.startsWith(prefix)) return cc;
  }
  return 'OTHER';
}

bool feedMatchesCountry(List<String> countryCodes, String country) =>
    countryCodes.contains('ALL') || countryCodes.contains(country);
