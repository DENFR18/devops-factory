# GitHub Actions — Secrets & Environments Setup

Procédure complète "from zero" pour un nouveau collaborateur ou une nouvelle installation.

---

## 1. Ajouter les 3 secrets GitHub (étape manuelle unique)

1. Aller sur **GitHub → Settings → Secrets and variables → Actions**
2. Cliquer sur **New repository secret** pour chacun des 3 secrets suivants :

| Nom | Type | Valeur |
|---|---|---|
| `SCW_ACCESS_KEY` | Secret | Clé d'accès IAM Scaleway |
| `SCW_SECRET_KEY` | Secret | Clé secrète IAM Scaleway |
| `SCW_DEFAULT_PROJECT_ID` | Secret | UUID du projet Scaleway |

> Ces 3 secrets sont les **seules valeurs** qu'un humain doit saisir manuellement.
> Tout le reste est créé et géré par les pipelines.

### Obtenir les clés Scaleway

1. Se connecter sur [console.scaleway.com](https://console.scaleway.com)
2. Créer un **Project** (ou utiliser l'existant) — noter le **Project ID** (UUID)
3. Aller dans **IAM → API Keys** → **Generate API key**
4. Permissions minimales requises :
   - `ObjectStorageBucketsWrite` (pour le bootstrap des buckets)
   - `KapsuleFullAccess`
   - `RegistryFullAccess`

---

## 2. Créer les GitHub Environments

Les jobs `terraform-apply-*` sont protégés par des **GitHub Environments**.
Sans ces environments configurés, les apply s'exécuteraient sans approbation humaine.

### Environnement `dev`

1. Aller sur **GitHub → Settings → Environments → New environment**
2. Nom : `dev`
3. Dans **Environment protection rules** :
   - Cocher **Required reviewers**
   - Ajouter les reviewers (au moins 1 reviewer requis)
4. URL optionnelle : `https://console.scaleway.com/kapsule/clusters`

### Environnement `prod`

1. Même procédure, nom : `prod`
2. Dans **Environment protection rules** :
   - Cocher **Required reviewers** (recommandé : 2 reviewers minimum)
   - Cocher **Prevent self-review** si disponible
3. URL optionnelle : `https://console.scaleway.com/kapsule/clusters`

---

## 3. Bootstrap des buckets Terraform (une seule fois)

Une fois les secrets et les environments configurés :

1. Aller sur **GitHub → Actions → Bootstrap — State Buckets**
2. Cliquer sur **Run workflow** → **Run workflow**
3. Attendre la fin du job `create-state-buckets` (≈ 30 secondes)
4. Vérifier dans la **console Scaleway → Object Storage** que les 2 buckets sont créés :
   - `devops-factory-tfstate-dev`
   - `devops-factory-tfstate-prod`

Le bootstrap est **idempotent** : le relancer sur un projet déjà configuré est sans effet.

---

## 4. Valider le pipeline infra (premier run)

1. Créer une branche, modifier un fichier dans `infra/terraform/`
2. Ouvrir une Pull Request vers `main`
3. Le workflow **Infrastructure — Terraform** se déclenche automatiquement
4. Un commentaire avec le résumé du plan apparaît sur la PR
5. Merger la PR
6. Sur **GitHub → Actions → Infrastructure — Terraform**, le job `terraform-apply-dev`
   attend une approbation dans l'environnement `dev`
7. Approuver → le cluster Kapsule est provisionné en ≈ 10 minutes

---

## 5. Rotation des secrets (tous les 90 jours)

1. Générer une nouvelle API key dans **Scaleway IAM → API Keys**
2. Dans **GitHub → Settings → Secrets and variables → Actions** :
   - Mettre à jour `SCW_ACCESS_KEY` avec la nouvelle valeur
   - Mettre à jour `SCW_SECRET_KEY` avec la nouvelle valeur
3. Vérifier qu'un pipeline se déclenche et passe correctement
4. Supprimer l'ancienne API key dans Scaleway IAM

> Le `SCW_DEFAULT_PROJECT_ID` est stable et ne nécessite pas de rotation.

---

## 6. Onboarding d'un collaborateur

1. **Scaleway** : ajouter le collaborateur au projet dans **IAM → Members**
2. **GitHub** : inviter le collaborateur dans l'organisation/repo avec le rôle `Write`
3. **Environments** : ajouter le collaborateur comme reviewer dans les environments
   `dev` et `prod` si l'approbation des apply lui est accordée
4. Le collaborateur n'a besoin d'**aucune clé Scaleway locale** pour développer —
   tout passe par les secrets du pipeline

---

## Référence rapide

| Action | Où |
|---|---|
| Ajouter/modifier des secrets | Settings → Secrets and variables → Actions |
| Créer/modifier les environments | Settings → Environments |
| Déclencher le bootstrap | Actions → Bootstrap — State Buckets → Run workflow |
| Voir les plans Terraform | Commentaires des Pull Requests |
| Approuver un apply | Actions → run concerné → Review deployments |
| Déclencher un destroy dev | Actions → Infrastructure — Terraform → Run workflow → confirm="destroy" |
