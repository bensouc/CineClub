# Seeds — exécuté par `bin/rails db:seed`, et automatiquement par `db:prepare`
# lorsque la base n'existe pas encore (donc au tout premier déploiement).
#
# Rien n'est créé sans variables d'environnement explicites : un mot de passe en
# dur ici finirait dans le dépôt Git et ouvrirait le premier déploiement à qui
# sait lire le code.
#
# Pour amorcer le premier administrateur :
#   ADMIN_EMAIL=vous@exemple.fr ADMIN_PASSWORD='...' bin/rails db:seed
#
# Ensuite, tous les autres comptes se créent via un lien d'invitation (/invitations).

email = ENV["ADMIN_EMAIL"].presence
password = ENV["ADMIN_PASSWORD"].presence

if email.nil? || password.nil?
  puts "db:seed — ADMIN_EMAIL / ADMIN_PASSWORD non fournis, aucun compte créé."
  puts "          Le premier admin s'amorce avec :"
  puts "          ADMIN_EMAIL=... ADMIN_PASSWORD=... bin/rails db:seed"
else
  admin = User.find_or_initialize_by(email: email)
  admin.password = password
  admin.admin = true
  admin.save!

  puts "db:seed — administrateur #{admin.email} prêt."
end
