# Guide de Mise à Jour - Métadonnées Open Graph pour Partage Social

## Changements effectués

### 1. Nouveau fichier Helper (`app/helpers/meta_tags_helper.rb`)
Ce fichier centralise la gestion des métadonnées Open Graph et Twitter Cards.

### 2. Mise à jour du Layout (`app/views/layouts/application.html.erb`)
Ajout des balises meta dans le `<head>` pour :
- **Open Graph** (Facebook, LinkedIn)
- **Twitter Cards**
- **SEO** (description, keywords, canonical URL)

### 3. Mise à jour de la vue Article (`app/views/posts/show.html.erb`)
Définition des métadonnées spécifiques à chaque article :
- Titre de l'article
- Description (160 premiers caractères du contenu)
- Image de couverture (cover_image)
- URL de l'article
- Auteur
- Tags (mots-clés)

## Déploiement sur le VPS

### Étape 1 : Pousser les changements vers GitHub
```bash
git add .
git commit -m "Ajout des métadonnées Open Graph pour partage social enrichi"
git push origin feature/migration-vps
```

### Étape 2 : Déployer sur le VPS
Connectez-vous au VPS et exécutez :
```bash
ssh root@72.62.30.117
cd /var/www/magjury
./deploy.sh
```

### Étape 3 : Redémarrer l'application
```bash
docker compose restart app
```

## Test du partage social

### 1. Tester les métadonnées localement
Après le déploiement, visitez un article sur votre site :
https://magjury.org/posts/[ID_ARTICLE]

Affichez le code source de la page (Clic droit > "Afficher le code source") et vérifiez que vous voyez bien :
```html
<meta property="og:title" content="[Titre de l'article]">
<meta property="og:image" content="[URL de l'image Cloudinary]">
<meta property="og:description" content="[Description]">
```

### 2. Tester avec Facebook Debugger
1. Allez sur : https://developers.facebook.com/tools/debug/
2. Collez l'URL de votre article : `https://magjury.org/posts/[ID]`
3. Cliquez sur "Déboguer"
4. Facebook va "scraper" votre page et vous montrer l'aperçu

**Important** : La première fois, Facebook garde l'ancien cache. Cliquez sur **"Scrape Again"** (Récupérer à nouveau) pour forcer la mise à jour.

### 3. Tester avec LinkedIn
1. Allez sur : https://www.linkedin.com/post-inspector/
2. Collez l'URL de votre article
3. Cliquez sur "Inspect"

### 4. Tester avec Twitter
1. Allez sur : https://cards-dev.twitter.com/validator
2. Collez l'URL de votre article
3. Cliquez sur "Preview card"

## Points importants

### Images Cloudinary
Les images doivent être **publiquement accessibles**. Active Storage et Cloudinary génèrent automatiquement des URLs publiques pour les images `cover_image` attachées.

L'URL générée ressemble à :
```
https://res.cloudinary.com/[CLOUD_NAME]/image/upload/[TRANSFORMATIONS]/[PUBLIC_ID]
```

### Dimensions recommandées pour les images de partage
- **Facebook/LinkedIn** : 1200 x 630 px
- **Twitter** : 1200 x 600 px

Les images existantes fonctionneront, mais pour un rendu optimal, utilisez ces dimensions lors de la création de nouveaux articles.

### Cache des réseaux sociaux
Quand vous modifiez un article existant :
1. Les métadonnées se mettent à jour immédiatement sur votre site
2. **MAIS** Facebook, LinkedIn, et Twitter gardent l'ancien aperçu en cache pendant ~7 jours
3. Utilisez les outils de débogage ci-dessus pour forcer le rafraîchissement

## Vérification rapide

### Checklist après déploiement :
- [ ] L'application redémarre sans erreur
- [ ] La page d'article s'affiche correctement
- [ ] Le code source contient les balises `<meta property="og:...">
- [ ] Facebook Debugger affiche l'image de l'article (pas le logo)
- [ ] Le partage sur Facebook montre bien l'image et la description
- [ ] Le partage sur LinkedIn montre bien l'image et la description
- [ ] Le partage sur Twitter montre bien l'image et la description

## Dépannage

### Problème : L'image ne s'affiche pas dans l'aperçu Facebook

**Solution 1** : Vérifier l'URL de l'image
```ruby
# Dans la console Rails sur le VPS :
docker compose exec app rails c
post = Post.last
url_for(post.cover_image) # Doit retourner une URL Cloudinary complète
```

**Solution 2** : Forcer le scraping Facebook
1. Allez sur https://developers.facebook.com/tools/debug/
2. Entrez l'URL
3. Cliquez sur "Scrape Again" plusieurs fois

**Solution 3** : Vérifier que Cloudinary est bien configuré
```bash
# Sur le VPS
docker compose exec app printenv | grep CLOUDINARY
# Doit afficher : CLOUDINARY_URL=cloudinary://...
```

### Problème : Les métadonnées sont vides

Vérifiez que le helper est bien chargé :
```bash
# Sur le VPS
docker compose exec app rails c
helper.meta_title # Ne doit pas retourner d'erreur
```

Si erreur "undefined method", redémarrez l'app :
```bash
docker compose restart app
```

## Support

Si vous rencontrez des problèmes, vérifiez les logs :
```bash
docker compose logs app --tail=100
```
