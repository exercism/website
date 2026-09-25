import assert from "node:assert/strict";
import { describe, it } from "node:test";

import {
  localeFromAcceptLanguage,
  localeFromPath,
  localeRedirect,
  normalizeLocale,
  readCookie,
  resolveLocale,
  shouldSkip
} from "./worker.js";
import config from "../../config/i18n.json" with { type: "json" };

const LOCALES = ["en", "hu"];
const HTML = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8";

function req(path, { method = "GET", accept = HTML, headers = {} } = {}) {
  const all = { ...headers };
  if (accept != null) all.Accept = accept;
  return new Request(`https://exercism.org${path}`, { method, headers: all });
}

describe("skip rules", () => {
  it("skips non-GET/HEAD methods", () => {
    for (const method of ["POST", "PUT", "PATCH", "DELETE"]) {
      assert.equal(shouldSkip(req("/tracks", { method }), LOCALES), true, method);
    }
  });


  it("skips paths with a file extension", () => {
    assert.equal(shouldSkip(req("/favicon.ico"), LOCALES), true);
    assert.equal(shouldSkip(req("/tracks/ruby.json"), LOCALES), true);
    assert.equal(shouldSkip(req("/tracks/ruby"), LOCALES), false);
  });

  it("skips when Accept does not ask for HTML", () => {
    assert.equal(shouldSkip(req("/tracks", { accept: "application/json" }), LOCALES), true);
    assert.equal(shouldSkip(req("/tracks", { accept: null }), LOCALES), true);
  });

  it("skips Turbo frame requests", () => {
    assert.equal(shouldSkip(req("/tracks", { headers: { "Turbo-Frame": "track_list" } }), LOCALES), true);
  });

  it("skips requests carrying a user cookie", () => {
    assert.equal(shouldSkip(req("/tracks", { headers: { Cookie: "_exercism_user_id=abc123" } }), LOCALES), true);
    assert.equal(shouldSkip(req("/tracks", { headers: { Cookie: "other=1; _exercism_user_id=x" } }), LOCALES), true);
  });

  it("judges a prefixed path by its public base", () => {
    assert.equal(shouldSkip(req("/hu"), LOCALES), false);
    assert.equal(shouldSkip(req("/hu/tracks/ruby"), LOCALES), false);
    assert.equal(shouldSkip(req("/hu/settings"), LOCALES), true);
  });

  it("skips paths outside the public set", () => {
    for (const path of ["/settings", "/auth/sign_in", "/dashboard", "/unsubscribe"]) {
      assert.equal(shouldSkip(req(path), LOCALES), true, path);
    }
  });

  it("allows the public sections and pages", () => {
    const paths = ["/", "/insiders", "/tracks", "/tracks/ruby", "/docs/using", "/community", "/profiles/iHiD", "/contributing"];
    for (const path of paths) {
      assert.equal(shouldSkip(req(path), LOCALES), false, path);
    }
  });

  it("does not treat a section name as a prefix of a longer word", () => {
    assert.equal(shouldSkip(req("/trackside"), LOCALES), true);
  });
});

describe("normalizeLocale", () => {
  it("matches a served locale exactly", () => {
    assert.equal(normalizeLocale("hu", LOCALES), "hu");
    assert.equal(normalizeLocale("HU", LOCALES), "hu");
    assert.equal(normalizeLocale("hu_HU", LOCALES), "hu");
  });

  it("falls back from a region to the base language", () => {
    assert.equal(normalizeLocale("en-GB", LOCALES), "en");
    assert.equal(normalizeLocale("hu-HU", LOCALES), "hu");
  });

  it("returns null for languages that are not served", () => {
    for (const tag of ["fr", "pt-BR", "es-ES", "es-419", "zh-Hant-TW", ""]) {
      assert.equal(normalizeLocale(tag, LOCALES), null, tag);
    }
  });

  it("applies the variants table once a variant is served", () => {
    const locales = ["en", "hu", "es-419", "es-ES", "pt-BR", "pt-PT", "zh-CN", "zh-TW"];
    assert.equal(normalizeLocale("es-ES", locales), "es-ES");
    assert.equal(normalizeLocale("es-CL", locales), "es-419");
    assert.equal(normalizeLocale("es", locales), "es-419");
    assert.equal(normalizeLocale("pt", locales), "pt-BR");
    assert.equal(normalizeLocale("pt-PT", locales), "pt-PT");
    assert.equal(normalizeLocale("pt-AO", locales), "pt-PT");
    assert.equal(normalizeLocale("zh-Hant", locales), "zh-TW");
    assert.equal(normalizeLocale("zh-HK", locales), "zh-TW");
    assert.equal(normalizeLocale("zh", locales), "zh-CN");
  });
});

describe("localeFromAcceptLanguage", () => {
  it("honours quality ordering and drops q=0", () => {
    assert.equal(localeFromAcceptLanguage("en;q=0.9,hu;q=1.0", LOCALES), "hu");
    assert.equal(localeFromAcceptLanguage("hu;q=0,en", LOCALES), "en");
    assert.equal(localeFromAcceptLanguage("fr,hu;q=0.8,en;q=0.5", LOCALES), "hu");
  });

  it("keeps header order for equal weights", () => {
    assert.equal(localeFromAcceptLanguage("hu,en", LOCALES), "hu");
    assert.equal(localeFromAcceptLanguage("en,hu", LOCALES), "en");
  });

  it("ignores the wildcard and returns null when nothing is served", () => {
    assert.equal(localeFromAcceptLanguage("*", LOCALES), null);
    assert.equal(localeFromAcceptLanguage("fr-CA,de;q=0.8", LOCALES), null);
    assert.equal(localeFromAcceptLanguage("", LOCALES), null);
    assert.equal(localeFromAcceptLanguage(null), null);
  });
});

describe("readCookie and localeFromPath", () => {
  it("reads one cookie out of a header", () => {
    assert.equal(readCookie("a=1; _exercism_locale_pref=hu; b=2", "_exercism_locale_pref"), "hu");
    assert.equal(readCookie("a=1", "_exercism_locale_pref"), null);
    assert.equal(readCookie(null, "a"), null);
  });

  it("reads a served non-default prefix off a path", () => {
    assert.equal(localeFromPath("/hu/tracks", LOCALES), "hu");
    assert.equal(localeFromPath("/tracks", LOCALES), null);
    assert.equal(localeFromPath("/en/tracks", LOCALES), null);
  });
});

describe("resolveLocale", () => {
  it("prefers the preference cookie over Accept-Language", () => {
    const request = req("/tracks/ruby", {
      headers: { Cookie: "_exercism_locale_pref=hu", "Accept-Language": "en-GB,en;q=0.9" }
    });
    assert.equal(resolveLocale(request, LOCALES), "hu");
  });

  it("ignores a preference cookie naming a locale we do not serve", () => {
    const request = req("/tracks/ruby", {
      headers: { Cookie: "_exercism_locale_pref=fr", "Accept-Language": "hu" }
    });
    assert.equal(resolveLocale(request, LOCALES), "hu");
  });
});

describe("localeRedirect", () => {
  it("moves a Hungarian browser onto the prefixed path", () => {
    const response = localeRedirect(req("/tracks/ruby", { headers: { "Accept-Language": "hu-HU,hu;q=0.9,en;q=0.8" } }), LOCALES);

    assert.equal(response.status, 302);
    assert.equal(response.headers.get("Location"), "https://exercism.org/hu/tracks/ruby");
    assert.equal(response.headers.get("Cache-Control"), "private, no-store");
    assert.equal(response.headers.get("Vary"), "Accept-Language, Cookie");
  });

  it("treats HEAD exactly as GET", () => {
    const headers = { "Accept-Language": "hu" };
    const get = localeRedirect(req("/tracks/ruby", { headers }), LOCALES);
    const head = localeRedirect(req("/tracks/ruby", { method: "HEAD", headers }), LOCALES);

    assert.equal(head.status, get.status);
    assert.equal(head.headers.get("Location"), get.headers.get("Location"));
  });

  it("prefixes the root path without doubling the slash", () => {
    const response = localeRedirect(req("/", { headers: { "Accept-Language": "hu" } }), LOCALES);
    assert.equal(response.headers.get("Location"), "https://exercism.org/hu");
  });

  it("keeps the query string", () => {
    const response = localeRedirect(req("/tracks?q=ruby", { headers: { "Accept-Language": "hu" } }), LOCALES);
    assert.equal(response.headers.get("Location"), "https://exercism.org/hu/tracks?q=ruby");
  });

  it("keeps an English browser on a prefixed path it followed", () => {
    assert.equal(localeRedirect(req("/hu/tracks/ruby", { headers: { "Accept-Language": "en-GB,en;q=0.9" } }), LOCALES), null);
  });

  it("moves a visitor whose cookie says English off a prefixed path", () => {
    const response = localeRedirect(req("/hu/tracks/ruby", { headers: { Cookie: "_exercism_locale_pref=en" } }), LOCALES);
    assert.equal(response.status, 302);
    assert.equal(response.headers.get("Location"), "https://exercism.org/tracks/ruby");
  });

  it("leaves a visitor whose cookie matches the prefix alone", () => {
    assert.equal(localeRedirect(req("/hu/tracks", { headers: { Cookie: "_exercism_locale_pref=hu" } }), LOCALES), null);
  });

  it("passes through an English browser", () => {
    assert.equal(localeRedirect(req("/tracks/ruby", { headers: { "Accept-Language": "en-GB,en;q=0.9" } }), LOCALES), null);
  });

  it("passes through a client sending no Accept-Language", () => {
    assert.equal(localeRedirect(req("/tracks/ruby"), LOCALES), null);
  });

  it("passes through variants of languages that are not served yet", () => {
    for (const header of ["pt-BR,pt;q=0.9", "es-ES,es;q=0.9", "es-419", "zh-Hant-TW"]) {
      assert.equal(localeRedirect(req("/tracks/ruby", { headers: { "Accept-Language": header } }), LOCALES), null, header);
    }
  });

  it("passes through a path that already has the prefix", () => {
    assert.equal(localeRedirect(req("/hu/tracks/ruby", { headers: { "Accept-Language": "hu" } }), LOCALES), null);
  });

  it("passes through every skipped request even when a locale resolves", () => {
    const headers = { "Accept-Language": "hu" };
    assert.equal(localeRedirect(req("/tracks", { method: "POST", headers }), LOCALES), null);
    assert.equal(localeRedirect(req("/api/v2/tracks", { headers }), LOCALES), null);
    assert.equal(localeRedirect(req("/settings", { headers }), LOCALES), null);
    assert.equal(localeRedirect(req("/tracks", { accept: "application/json", headers }), LOCALES), null);
    assert.equal(localeRedirect(req("/tracks", { headers: { ...headers, "Turbo-Frame": "x" } }), LOCALES), null);
    assert.equal(localeRedirect(req("/tracks", { headers: { ...headers, Cookie: "_exercism_user_id=1" } }), LOCALES), null);
  });
});

describe("the shipped locale list", () => {
  it("reads config/i18n.json, the same file Rails reads", () => {
    assert.equal(config.served.includes(config.default), true);
  });

  it("never redirects while only the default locale is served", () => {
    if (config.served.length > 1) return;

    const request = req("/tracks/ruby", { headers: { "Accept-Language": "hu-HU,hu;q=0.9", Cookie: "_exercism_locale_pref=hu" } });
    assert.equal(localeRedirect(request), null);
  });
});
