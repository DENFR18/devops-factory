# Bootstrap Kubernetes Platform

Cette procedure initialise la couche plateforme Kubernetes sur Scaleway Kapsule via GitHub Actions, puis laisse ArgoCD prendre le relais avec le pattern app-of-apps.

## Prerequis

1. Le workflow `Deploy Infrastructure` est vert.
2. Le cluster Kapsule dev est disponible.
3. Le secret GitHub `CLUSTER_ID_DEV` contient l'identifiant du cluster Kapsule dev.
4. Les secrets GitHub suivants existent deja :
   - `SCW_ACCESS_KEY`
   - `SCW_SECRET_KEY`
   - `SCW_DEFAULT_PROJECT_ID`
   - `CLUSTER_ID_DEV`

## Procedure

1. Ouvrir GitHub Actions.
2. Lancer le workflow `Bootstrap Kubernetes Platform`.
3. Choisir `task = bootstrap`.
4. Cliquer `Run workflow`.
5. Suivre les jobs dans l'ordre :
   - `bootstrap-namespaces`
   - `bootstrap-ingress-nginx`
   - `bootstrap-cert-manager`
   - `bootstrap-sealed-secrets`
   - `bootstrap-argocd`
   - `bootstrap-root-app`
6. ArgoCD synchronise ensuite la root app, les composants plateforme et les tenants.
7. Ouvrir le summary du job `bootstrap-root-app` et recuperer le lien `portal.<IP>.nip.io`.
8. Utiliser le portail pour acceder a ArgoCD et aux applications exposees en `nip.io`.
9. Relancer `Bootstrap Kubernetes Platform`.
10. Choisir `task = get-argocd-password`.
11. Copier le mot de passe initial affiche dans les logs.
12. Se connecter a ArgoCD avec l'utilisateur `admin`, puis changer ce mot de passe immediatement.

Total attendu : environ 2 boutons `Run workflow`, zero CLI manuelle.

## Ce que le bootstrap installe

- Namespaces plateforme : `argocd`, `ingress-nginx`, `cert-manager`, `sealed-secrets`, `monitoring`
- Namespaces tenants : `tenant-alpha`, `tenant-beta`, `tenant-gamma`
- ResourceQuotas, LimitRanges, NetworkPolicies deny-all et RBAC deployer par tenant
- ingress-nginx via Helm
- cert-manager via Helm avec CRDs
- sealed-secrets via Helm
- ArgoCD via Helm
- Application ArgoCD `root`
- Portail d'acces `portal.<IP>.nip.io`
- Catalogue applicatif GitOps :
  - `wordpress.<IP>.nip.io` pour WordPress + base SQL
  - `grafana.<IP>.nip.io`
  - `prometheus.<IP>.nip.io`
  - `alertmanager.<IP>.nip.io`
  - `slack.<IP>.nip.io` pour Mattermost
  - `ghost.<IP>.nip.io`
  - `gitea.<IP>.nip.io`
  - `cloud.<IP>.nip.io` pour Nextcloud
  - `node-api.<IP>.nip.io`
  - `flask.<IP>.nip.io`
  - `react.<IP>.nip.io`

## GitOps

La root app ArgoCD surveille `argocd/applications/` sur la branche `main`.

Applications gerees :

- `kube-prometheus-stack` dans `monitoring`
- `cert-manager-issuers` pour les ClusterIssuers Let's Encrypt staging/prod
- `tenant-alpha`
- `tenant-beta`
- `tenant-gamma`

Chaque tenant possede un `AppProject` limite a son namespace Kubernetes.

## Notes operationnelles

- Les manifests de bootstrap utilisent `kubectl apply`, ils sont idempotents.
- Apres installation d'ArgoCD, les deploiements applicatifs doivent passer par GitOps.
- Aucun secret applicatif ne doit etre commite en clair. Utiliser Sealed Secrets.
- Les hosts ingress par defaut utilisent `*.devops-factory.example.com`; les remplacer par les domaines reels avant exposition publique.
- Le portail d'acces genere aussi des URLs temporaires `*.nip.io` a partir de l'IP publique ingress-nginx.
- Les ClusterIssuers utilisent `devops@example.com`; remplacer cet email par une adresse operationnelle avant usage production.
