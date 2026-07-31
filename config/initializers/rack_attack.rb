# Rack::Attack — throttling des tentatives de connexion et blocage des scanners.
#
# Puma tourne en mode "single" (aucun `workers` dans config/puma.rb) : un seul
# process, plusieurs threads. Un MemoryStore suffit donc — il est partagé entre
# tous les threads du process — et évite de dépendre du cache applicatif ou d'un
# Redis. Si un jour on passe en mode clustered (plusieurs workers) ou multi-
# conteneurs, il faudra un store partagé (Redis/Memcached) pour que les compteurs
# soient communs.
class Rack::Attack
  # En test, le throttling ferait échouer les scénarios qui répètent des POST de
  # connexion. On le neutralise pour garder une suite déterministe.
  Rack::Attack.enabled = false if Rails.env.test?

  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # IP réelle du client. Rack::Attack est inséré en fin de pile (après
  # ActionDispatch::RemoteIp), donc `action_dispatch.remote_ip` est déjà calculé
  # à partir du X-Forwarded-For posé par Traefik. Sans ça, toutes les requêtes
  # sembleraient venir de l'IP du proxy et on throttlerait tout le monde ensemble.
  def self.client_ip(req)
    (req.env["action_dispatch.remote_ip"] || req.ip).to_s
  end

  def self.login_attempt?(req)
    req.path == "/users/sign_in" && req.post?
  end

  # Ne jamais throttler le réseau local (health check Coolify sur le conteneur).
  safelist("allow-local") do |req|
    req.ip == "127.0.0.1" || req.ip == "::1"
  end

  # Connexion : 5 tentatives / 20 s par IP.
  throttle("login/ip", limit: 5, period: 20.seconds) do |req|
    client_ip(req) if login_attempt?(req)
  end

  # Connexion : 5 tentatives / 20 s par email (freine le credential stuffing
  # réparti sur plusieurs IP). Email normalisé pour éviter le contournement.
  throttle("login/email", limit: 5, period: 20.seconds) do |req|
    if login_attempt?(req)
      req.params.dig("user", "email").to_s.downcase.strip.presence
    end
  end

  # Garde-fou général contre le crawl agressif (les assets digérés sont exclus).
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    client_ip(req) unless req.path.start_with?("/assets")
  end

  # Bannit temporairement les scanners qui cherchent des chemins qui n'existent
  # pas chez nous (.env, .git, WordPress, phpMyAdmin…). 2 essais tolérés.
  blocklist("scanners") do |req|
    Rack::Attack::Fail2Ban.filter("scan-#{client_ip(req)}", maxretry: 2, findtime: 10.minutes, bantime: 1.hour) do
      CGI.unescape(req.path).match?(%r{\A/(\.env|\.git|wp-|wordpress|phpmyadmin|xmlrpc|vendor/phpunit|autodiscover)}i)
    end
  end

  # Réponses renvoyées quand on limite / bloque.
  self.throttled_responder = lambda do |_req|
    [ 429, { "content-type" => "text/plain" }, [ "Trop de requêtes. Réessaie dans un instant.\n" ] ]
  end

  self.blocklisted_responder = lambda do |_req|
    [ 403, { "content-type" => "text/plain" }, [ "Forbidden\n" ] ]
  end
end
