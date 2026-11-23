// Offline: cache halaman, ROM (dari roms.json), dan emulator dari CDN.
var CACHE='retro-v5-ui-library-fix';
var CORE=['./','index.html','manifest.webmanifest','icon.svg','roms/roms.json'];
self.addEventListener('install',function(e){
  self.skipWaiting();
  e.waitUntil(caches.open(CACHE).then(function(c){
    return c.addAll(CORE).catch(function(){}).then(function(){
      return fetch('roms/roms.json').then(function(r){return r.json()}).then(function(a){
        return Promise.all(a.map(function(g){ return c.add(g.file).catch(function(){}); }));
      }).catch(function(){});
    });
  }));
});
self.addEventListener('activate',function(e){
  e.waitUntil(caches.keys().then(function(k){
    return Promise.all(k.filter(function(n){return n!==CACHE}).map(function(n){return caches.delete(n)}));
  }).then(function(){return self.clients.claim()}));
});
self.addEventListener('fetch',function(e){
  var req=e.request; if(req.method!=='GET') return;
  var u=new URL(req.url);
  if(!(u.origin===location.origin || u.hostname==='cdn.emulatorjs.org')) return;
  var big = u.pathname.indexOf('/roms/')>-1 && /\.(gba|gb|gbc|nes|sfc|smc|md|bin|gen|sms|gg|pce)$/i.test(u.pathname);
  if(u.origin===location.origin && !big){   // halaman sendiri: network-first biar update langsung masuk
    e.respondWith(fetch(req).then(function(res){
      if(res.ok){ var cp=res.clone(); caches.open(CACHE).then(function(c){c.put(req,cp)}); }
      return res;
    }).catch(function(){ return caches.match(req,{ignoreSearch:true}); }));
    return;
  }
  e.respondWith(caches.open(CACHE).then(function(c){
    return c.match(req,{ignoreSearch:true}).then(function(hit){
      var net=fetch(req).then(function(res){
        if(res && (res.ok||res.type==='opaque') && !req.headers.has('range')) c.put(req,res.clone());
        return res;
      }).catch(function(){ return hit; });
      return hit || net;
    });
  }));
});
