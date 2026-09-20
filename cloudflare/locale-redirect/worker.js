// First-visit locale redirect, ahead of the cache.
//
// Cloudflare caches anonymous public pages on exercism.org by URL, so the
// Rails before_action that moves a first-time visitor to their language never
// runs on a cache hit: a hit is served from the edge and the origin is never
// asked. Workers run before the cache lookup, so deciding here is the only
// place the decision is guaranteed to happen on every request.
//
// This mirrors LocaleRouting#redirect_to_preferred_locale! on the website
// (app/controllers/concerns/locale_routing.rb). Rails keeps its copy because
// the Worker is a cache-fronted optimisation rather than the only path to the
// app: direct-to-origin traffic and logged-in requests still go through it.
// The two must agree, which is why both read the locale lists below out of one
// file.

// config/i18n.json is the single source of truth for locale routing, read by
// Rails as well. Wrangler's bundler inlines this import, so what runs at the
// edge is the file that is in the repo at deploy time, and serving a new
// locale is a change to its `served` list alone.
//
// `public_sections` match by prefix and `public_pages` exactly. Both are
// deliberately narrower than the set of locale-prefixed routes: the stateful
// flows (auth, settings, unsubscribe) carry per-user state through the URL,
// and bouncing someone mid-flow risks breaking the flow for no benefit.
//
// `variants` covers the languages that ship more than one content variant,
// where which one a browser gets depends on the region or script in its tag:
// Chromium sends "es-419" directly, Firefox and Safari send country codes
// ("es-CL", "es-AR"), so every non-ES region has to collapse to the Latin
// American variant. A language absent from it collapses to its base.
import config from "../../config/i18n.json" with { type: "json" };

const {
  default: DEFAULT_LOCALE,
  served: SERVED_LOCALES,
  public_sections: PUBLIC_SECTIONS,
  public_pages: PUBLIC_PAGES,
  variants: VARIANTS
} = config;

// Records a locale the visitor chose, as opposed to one we inferred from
// Accept-Language. Mirrors Locale::PREF_COOKIE_NAME.
const PREF_COOKIE_NAME = "_exercism_locale_pref";

// Rails checks cookies.signed[:_exercism_user_id]; a Worker cannot verify the
// signature, so it treats presence as "possibly logged in". That is the same
// test the "skip cache for logged-in users" cache rule already makes, so the
// two agree on who is anonymous.
const USER_COOKIE_NAME = "_exercism_user_id";

// Paths that never render a localizable HTML page. Cheaper to reject here than
// to walk the public-path lists, and it keeps the Worker off the hot paths
// that carry the most traffic.
const SKIP_PREFIXES = ["/api/", "/cable", "/spi/", "/assets/", "/test-runners/", "/i18n/", "/webhooks/"];

/** Read one cookie out of a raw Cookie header. Returns null when absent. */
export function readCookie(cookieHeader, name) {
  if (!cookieHeader) return null;

  for (const part of cookieHeader.split(";")) {
    const eq = part.indexOf("=");
    if (eq === -1) continue;
    if (part.slice(0, eq).trim() !== name) continue;

    const raw = part.slice(eq + 1).trim();
    try {
      return decodeURIComponent(raw);
    } catch {
      return raw;
    }
  }
  return null;
}

/**
 * Resolve one language tag to a served locale, or null.
 *
 * Mirrors Locale::Normalize. An exact (case-normalized) match wins, then the
 * region-collapsed content variant, then the bare language, so "en-GB" lands
 * on "en" and "es-CL" would land on "es-419" once Spanish ships.
 */
export function normalizeLocale(tag, locales = SERVED_LOCALES) {
  if (tag == null) return null;

  const subtags = String(tag).replaceAll("_", "-").split("-");
  const language = subtags[0].toLowerCase();
  if (!language) return null;

  const rest = subtags.slice(1);
  const script = capitalize(rest.find((s) => /^[A-Za-z]{4}$/.test(s)));
  const region = rest.find((s) => /^([A-Za-z]{2}|[0-9]{3})$/.test(s))?.toUpperCase();

  const canonical = region ? `${language}-${region}` : language;
  const config = VARIANTS[language];

  // The variant step only applies once at least one variant of this language
  // is actually served; otherwise "pt" has nowhere to collapse to.
  let variant = null;
  if (config && locales.some((l) => l.startsWith(`${language}-`))) {
    variant =
      (script && config.scripts?.[script]) ||
      (region ? (config.regions[region] ?? config.fallback) : config.bare);
  }

  return [canonical, variant, language].find((l) => l && locales.includes(l)) ?? null;
}

function capitalize(value) {
  return value ? value[0].toUpperCase() + value.slice(1).toLowerCase() : undefined;
}

/**
 * First served locale named by an Accept-Language header, honouring its
 * weighting. Mirrors Locale::FromAcceptLanguage.
 *
 * Each tag is fully resolved before moving on to the next, so a later exact
 * match never leapfrogs an earlier tag that already collapses to something
 * served. Ties keep the header's own order, and q=0 means "not this one".
 */
export function localeFromAcceptLanguage(header, locales = SERVED_LOCALES) {
  if (!header || !header.trim()) return null;

  const tags = header
    .split(",")
    .map((part, index) => {
      const [tag, ...params] = part.split(";").map((s) => s.trim());
      const q = params.find((p) => p.startsWith("q="));
      const quality = q === undefined ? 1 : (Number.parseFloat(q.slice(2)) || 0);
      return { tag, quality, index };
    })
    .filter(({ tag, quality }) => tag && tag !== "*" && quality > 0)
    .sort((a, b) => b.quality - a.quality || a.index - b.index);

  for (const { tag } of tags) {
    const locale = normalizeLocale(tag, locales);
    if (locale) return locale;
  }
  return null;
}

/** The served, non-default locale at the head of a path, or null. */
export function localeFromPath(pathname, locales = SERVED_LOCALES) {
  const segment = pathname.split("/")[1];
  return segment && segment !== DEFAULT_LOCALE && locales.includes(segment) ? segment : null;
}

export function stripLocalePrefix(pathname, locales = SERVED_LOCALES) {
  const locale = localeFromPath(pathname, locales);
  return locale ? pathname.slice(locale.length + 1) || "/" : pathname;
}

function isPublicPath(pathname) {
  if (PUBLIC_PAGES.includes(pathname)) return true;

  return PUBLIC_SECTIONS.some((section) => pathname === section || pathname.startsWith(`${section}/`));
}

/** Whether this request is left alone entirely. */
export function shouldSkip(request, locales = SERVED_LOCALES) {
  if (request.method !== "GET" && request.method !== "HEAD") return true;

  const headers = request.headers;

  // Turbo frame requests return page fragments, and a 302 on one replaces the
  // frame instead of navigating the page. The cache rules exclude them too.
  if (headers.has("Turbo-Frame")) return true;

  // Only navigations. Anything not asking for a document (fetch, XHR, an image)
  // has no locale to be moved to.
  if (!(headers.get("Accept") ?? "").includes("text/html")) return true;

  if (readCookie(headers.get("Cookie"), USER_COOKIE_NAME) != null) return true;

  const { pathname } = new URL(request.url);
  if (SKIP_PREFIXES.some((prefix) => pathname.startsWith(prefix))) return true;

  // A file extension on the last segment means a static asset, never a page.
  if (/\.[A-Za-z0-9]+$/.test(pathname.split("/").pop() ?? "")) return true;

  return !isPublicPath(stripLocalePrefix(pathname, locales));
}

/**
 * The locale this visitor should be on, or null to leave them where they are.
 *
 * Precedence is explicit choice, then explicit URL, then browser guess. The
 * preference cookie exists only once the visitor has used the switcher or the
 * banner, so it is the one unambiguously deliberate signal and must survive
 * following a link into another language. A locale already in the path
 * outranks the browser: a URL someone deliberately followed is the stronger
 * signal, and it keeps every prefixed URL independently shareable.
 *
 * No served language anywhere means no redirect. That covers unsupported
 * languages and, critically, clients sending no Accept-Language at all:
 * crawlers among them. Were those to resolve to English, every prefixed URL
 * would bounce to its naked form on every crawl and no locale but English
 * would ever be indexed.
 */
export function resolveLocale(request, locales = SERVED_LOCALES) {
  const pref = normalizeLocale(readCookie(request.headers.get("Cookie"), PREF_COOKIE_NAME), locales);
  if (pref) return pref;

  const fromPath = localeFromPath(new URL(request.url).pathname, locales);
  if (fromPath) return fromPath;

  return localeFromAcceptLanguage(request.headers.get("Accept-Language"), locales);
}

/**
 * The redirect a request needs, or null to let it carry on to the cache.
 *
 * 302 rather than 301, and uncacheable: which locale a URL serves is a
 * property of the visitor, not of the URL. A cached redirect would pin one
 * language's answer onto everyone who follows it, and a 301 would pin it in
 * browsers permanently.
 */
export function localeRedirect(request, locales = SERVED_LOCALES) {
  if (shouldSkip(request, locales)) return null;

  const locale = resolveLocale(request, locales);
  if (locale == null) return null;

  const url = new URL(request.url);
  const current = localeFromPath(url.pathname, locales) ?? DEFAULT_LOCALE;
  if (locale === current) return null;

  const base = stripLocalePrefix(url.pathname, locales);
  url.pathname = locale === DEFAULT_LOCALE ? base : `/${locale}${base === "/" ? "" : base}`;

  return new Response(null, {
    status: 302,
    headers: {
      Location: url.toString(),
      "Cache-Control": "private, no-store",
      Vary: "Accept-Language, Cookie"
    }
  });
}

export default {
  // Passing the original request to fetch() puts it back on the zone's normal
  // path: same-zone subrequests are not routed to Workers again, so this
  // continues into the cache rules, the cache and the origin without looping.
  // A bug here must never take a page down: any exception becomes a
  // pass-through, which is what the site does without the Worker.
  fetch(request) {
    let redirect = null;
    try {
      redirect = localeRedirect(request);
    } catch {
      redirect = null;
    }
    return redirect ?? fetch(request);
  }
};
