# Maps migration: Google Maps Platform → MapLibre + Geoapify (OpenStreetMap data)

This build no longer uses the Google Maps Platform for anything. The map is drawn by **MapLibre
Native**, and the map style, the address search and the road routes come from **Geoapify**, which
serves OpenStreetMap data.

## What changed

| Concern | Before | After |
|---|---|---|
| Map rendering | Google Maps SDK for Android (`play-services-maps`) | **MapLibre Native for Android** (`org.maplibre.gl:android-sdk`), rendering a Geoapify vector style |
| Base map data | Google | **OpenStreetMap contributors**, via Geoapify's tiles and style |
| Destination / address search | Google Places SDK (`places`) | **Geoapify autocomplete** over HTTPS (`core/places/PlacesAutocomplete`) |
| Reverse geocoding (a map tap → address) | Google Geocoding API | **Geoapify reverse geocoding** (`core/places/GeoapifyGeocoder`) |
| Routing | Google Directions API | **Geoapify routing** (`core/routing/GeoapifyRoutingClient`) |
| Drive time | Google `duration_in_traffic` | Geoapify `time`; **no live traffic**, so `durationInTrafficMinutes` is 0 and the planner's labelled estimate is used |
| Route geometry | Google encoded polyline | GeoJSON `LineString` / `MultiLineString` (**longitude first**) |
| Navigation session | `GoogleNavigationProvider` | `GeoapifyNavigationProvider` (same `NavigationProvider` interface) |
| Configuration | `GOOGLE_MAPS_API_KEY` + manifest meta-data | `GEOAPIFY_API_KEY` (+ optional `MAP_STYLE_URL`) through `BuildConfig`; **no manifest entry** |
| Location fixes | `play-services-location` | unchanged — still `play-services-location`, which is free and unrelated to maps billing |

Deleted: `GoogleConfig`, `GoogleGeocoder`, `GoogleDirectionsClient`, `GoogleNavigationProvider`,
`Polyline` (and its test), plus the `play-services-maps` and `places` dependencies. Added:
`MapConfig`, `GeoapifyGeocoder`, `GeoapifyPlaceParser`, `GeoapifyRoutingClient`,
`GeoapifyNavigationProvider`, `GeoapifyErrors`, `RequestSequence`, `RouteCache`, `RequestThrottle`.

Unchanged on purpose: `RoutePlan.routeProvider` (now written as `"GEOAPIFY"`) and
`RoutePlan.googlePlaceId` (now holds the Geoapify `place_id`). No Room migration was needed, and the
field names are documented as historical in the entity.

## Configuration

```properties
# local.properties (gitignored) or an environment variable of the same name
GEOAPIFY_API_KEY=your_key_here
# Optional. Any MapLibre-compatible style URL; ?apiKey=… is appended at runtime.
MAP_STYLE_URL=https://maps.geoapify.com/v1/styles/osm-bright/style.json
```

Blank key ⇒ `MapConfig.isConfigured()` is false, the build prints a warning, and every map screen
shows the `map_setup_required` notice instead of a blank map.

## Request budget

The free plan is finite, so the clients are deliberately conservative:

- **Autocomplete** searches only after a 300 ms pause and at least three characters, at most five
  results, and ignores any answer that a newer keystroke has superseded (a request token).
- **Reverse geocoding** is cached in memory by coordinate rounded to four decimals, so nudging a pin
  does not spend a credit per tap.
- **Routing** is cached in memory for ten minutes (about 20 entries, keyed by mode and coordinates
  rounded to four decimals) and paced at four request starts per second.

## Licensing notes (not optional)

- **Map data is © OpenStreetMap contributors**, available under the Open Database License (ODbL).
  The attribution "Map data © OpenStreetMap contributors" must stay visible; MapLibre's own
  attribution control is left enabled and the planner screen also shows the plain-text credit
  (`strings.xml` → `map_attribution`).
- **The Geoapify free plan is for limited commercial use and requires attribution**
  ("Powered by Geoapify"). It also has a daily credit cap and a per-second request limit. A
  commercial launch needs a paid plan or an equivalent arrangement.
- **Do not use `tile.openstreetmap.org` from the shipped app.** The OpenStreetMap Foundation's tile
  servers are not a free content delivery network and their usage policy forbids this app pulling
  tiles from them. This build never requests that host: the style, the tiles and the API calls all
  go to `*.geoapify.com` over HTTPS.
- **The API key ships inside the APK.** It is required in the URL of the style and the API calls, so
  it can be extracted. The free plan's daily cap bounds the exposure; a server-side proxy is the
  proper hardening and is out of scope for this build (see `SECURITY_REVIEW.md`).

## Voice guidance

Nothing is spoken. Spoken turn-by-turn guidance needs a licensed navigation SDK and an audio-focus
policy this build does not ship, and the screens say so instead of pretending. The audio-guidance
flags on `GeoapifyNavigationProvider` are already modelled, so such an SDK can be added behind the
same `NavigationProvider` interface.
