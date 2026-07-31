// Service worker de CinéClub.
//
// Objectif : rendre l'app installable (Android/Chrome exige un service worker
// avec un handler `fetch`) et offrir un repli hors-ligne, SANS jamais servir de
// HTML périmé — les navigations vont toujours au réseau d'abord.
//
// Bump CACHE_VERSION à chaque changement de cet ordre de cache pour forcer le
// remplacement de l'ancien service worker.
const CACHE_VERSION = "cineclub-v1";
const PRECACHE = [
  "/offline.html",
  "/manifest.json",
  "/icon-192.png",
  "/icon-512.png"
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_VERSION)
      .then((cache) => cache.addAll(PRECACHE))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(
        keys.filter((k) => k !== CACHE_VERSION).map((k) => caches.delete(k))
      ))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (event) => {
  const { request } = event;

  // On ne touche qu'aux GET same-origin.
  if (request.method !== "GET") return;
  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;

  // Navigations (pages) : réseau d'abord, repli offline.html si hors-ligne.
  // Jamais de HTML en cache tant qu'on est en ligne → pas de page périmée.
  if (request.mode === "navigate") {
    event.respondWith(
      fetch(request).catch(() => caches.match("/offline.html"))
    );
    return;
  }

  // Assets digérés (immuables, empreinte dans le nom) : cache d'abord.
  if (url.pathname.startsWith("/assets/")) {
    event.respondWith(
      caches.match(request).then((cached) =>
        cached ||
        fetch(request).then((response) => {
          const copy = response.clone();
          caches.open(CACHE_VERSION).then((cache) => cache.put(request, copy));
          return response;
        })
      )
    );
  }
});
