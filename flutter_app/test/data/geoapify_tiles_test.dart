import 'package:amperly/data/geoapify/geoapify_tiles.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('style is read from the vector and raster URL shapes', () {
    expect(
      GeoapifyMapConfig.styleNameFromStyleUrl(
        'https://maps.geoapify.com/v1/styles/osm-bright/style.json',
      ),
      'osm-bright',
    );
    expect(
      GeoapifyMapConfig.styleNameFromStyleUrl(
        r'https://maps.geoapify.com/v1/tile/klokantech-basic/{z}/{x}/{y}.png',
      ),
      'klokantech-basic',
    );
  });

  test('missing or unrecognised style URLs use the default style', () {
    expect(GeoapifyMapConfig.styleNameFromStyleUrl(null), 'osm-bright');
    expect(GeoapifyMapConfig.styleNameFromStyleUrl(''), 'osm-bright');
    expect(
      GeoapifyMapConfig.styleNameFromStyleUrl(
        'https://maps.geoapify.com/v1/styles/style.json',
      ),
      'osm-bright',
    );
    expect(
      GeoapifyMapConfig.styleNameFromStyleUrl(
        'https://maps.geoapify.com/v1/styles/Not_A_Style/style.json',
      ),
      'osm-bright',
    );
  });

  test('a blank key means the map is not configured', () {
    expect(GeoapifyMapConfig.from(styleUrl: '', apiKey: ''), isNull);
    expect(GeoapifyMapConfig.from(styleUrl: '', apiKey: '   '), isNull);
  });

  test('the tile template points at Geoapify and never OSM tile servers', () {
    final GeoapifyMapConfig? config = GeoapifyMapConfig.from(
      styleUrl: 'https://maps.geoapify.com/v1/styles/osm-bright/style.json',
      apiKey: ' test-key ',
    );

    expect(config, isNotNull);
    expect(config!.isConfigured, isTrue);
    expect(config.apiKey, 'test-key');
    expect(
      config.tileUrlTemplate,
      'https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png'
      '?apiKey=test-key',
    );
    expect(config.tileUrlTemplate, isNot(contains('openstreetmap.org')));
  });

  test('the key is encoded inside the tile URL', () {
    final GeoapifyMapConfig? config = GeoapifyMapConfig.from(
      styleUrl: '',
      apiKey: 'a+b&c',
    );

    expect(config, isNotNull);
    expect(config!.style, GeoapifyMapConfig.defaultStyle);
    expect(config.tileUrlTemplate, contains('apiKey=a%2Bb%26c'));
  });
}
