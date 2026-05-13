# DevOps Factory

Plateforme DevSecOps industrialisee de demonstration, deployee sur Scaleway Kapsule en region `fr-par`.

Le projet couvre l'infrastructure as code, la CI/CD, le GitOps, le monitoring, la securite applicative et un portail d'acces public en `nip.io`.

## Objectif

Le client souhaite professionnaliser ses livraisons applicatives :

- builds et tests automatises ;
- images Docker poussees dans un registry ;
- deploiement Kubernetes par GitOps ;
- supervision Prometheus/Grafana ;
- scans de securite dans la chaine CI/CD ;
- gestion des secrets et isolation par namespaces ;
- portail web permettant d'acceder aux applications exposees.

## Stack technique

| Domaine | Outils |
| --- | --- |
| Cloud | Scaleway, region `fr-par` |
| Kubernetes | Scaleway Kapsule |
| IaC | Terraform |
| CI/CD | GitHub Actions |
| GitOps | ArgoCD app-of-apps |
| Packaging | Helm |
| Ingress | ingress-nginx + `nip.io` |
| Monitoring | kube-prometheus-stack, Prometheus, Grafana, Alertmanager |
| Securite | Trivy, Trivy Operator, Falco, Vault, SonarCloud, Checkov, tflint, RBAC, NetworkPolicies, Sealed Secrets |
| Applications | WordPress, MySQL/MariaDB, Mattermost, Ghost, Gitea, Nextcloud, Keycloak, Metabase, Wiki.js, Flask/FastAPI, Node API, React |

## Architecture

```text
GitHub Actions
  |
  |-- Deploy Infrastructure
  |     Terraform -> Scaleway Kapsule, registry, reseau, buckets applicatifs
  |
  |-- Bootstrap Kubernetes Platform
  |     namespaces, policies, ingress-nginx, cert-manager, sealed-secrets, ArgoCD
  |
  |-- Applications - DevSecOps
        tests, SonarCloud, build Docker, push registry, Trivy, update tags GitOps

ArgoCD
  |
  |-- root app
      |-- monitoring
      |-- cert-manager issuers
      |-- tenants alpha/beta/gamma
      |-- catalogue applicatif
```

## Structure du depot

```text
.github/workflows/
  bootstrap.yml          # creation des buckets Terraform state
  deploy-infra.yml       # deploy manuel dev/prod
  destroy-infra.yml      # destroy manuel dev/prod
  bootstrap-k8s.yml      # bootstrap Kubernetes + ArgoCD + diagnostics
  deploy-monitoring.yml  # deploiement isole Grafana/Prometheus sans ingress public
  apps.yml               # CI/CD applicative
  infra.yml              # checks Terraform sur PR

infra/terraform/
  modules/               # modules reseau, Kapsule, registry, buckets, IAM
  environments/dev/      # environnement dev
  environments/prod/     # environnement prod

infra/kubernetes/bootstrap/
  01-namespaces.yaml
  02-resource-quotas.yaml
  03-limit-ranges.yaml
  04-network-policies.yaml
  05-rbac.yaml
  helm-values/

argocd/
  root-app.yaml
  applications/          # app-of-apps ArgoCD
  tenants/               # AppProjects + values tenants

apps/
  service-alpha/         # API Python
  node-api/              # API Node.js
  react/                 # frontend React

charts/
  service-alpha/
  node-api/
  react/
  nextcloud/

frontend/access-portal/  # portail d'acces nip.io
docs/runbooks/           # procedures d'exploitation
```

## Secrets GitHub requis

Dans `Settings -> Secrets and variables -> Actions` :

| Secret | Usage |
| --- | --- |
| `SCW_ACCESS_KEY` | acces Scaleway |
| `SCW_SECRET_KEY` | acces Scaleway + login registry |
| `SCW_DEFAULT_PROJECT_ID` | projet Scaleway cible |
| `SCW_DEFAULT_ORGANIZATION_ID` | organisation Scaleway, si necessaire |
| `SONAR_TOKEN` | analyse SonarCloud |
| `CLUSTER_ID_DEV` | optionnel, le workflow peut detecter `devops-factory-dev` |

## Mise en route

### 1. Creer les buckets Terraform state

Workflow :

```text
Bootstrap - State Buckets
```

A lancer une seule fois. Il cree les buckets :

- `devops-factory-tfstate-dev`
- `devops-factory-tfstate-prod`

Ces buckets stockent l'etat Terraform. Ils ne sont pas supprimes par `destroy dev`, car ils sont geres par le workflow de bootstrap, pas par l'environnement Terraform.

### 2. Deployer l'infrastructure dev

Workflow :

```text
Deploy Infrastructure
environment = dev
```

Ce workflow cree l'infrastructure Scaleway de dev :

- cluster Kapsule ;
- node pool ;
- reseau prive ;
- registry `devops-factory-dev` ;
- buckets applicatifs ;
- ressources IAM optionnelles.

### 3. Bootstrap Kubernetes

Workflow :

```text
Bootstrap Kubernetes Platform
task = bootstrap
```

Il installe la couche plateforme :

- namespaces ;
- quotas, limit ranges, RBAC ;
- network policies ;
- ingress-nginx ;
- cert-manager ;
- sealed-secrets ;
- ArgoCD ;
- root app ArgoCD ;
- portail d'acces `portal.<IP>.nip.io` ;
- ingresses `nip.io` pour les applications.

### 4. Builder et deployer les applications

Workflow :

```text
Applications - DevSecOps
```

Il execute :

- tests Python/Node/React ;
- analyse SonarCloud ;
- build Docker ;
- push dans Scaleway Container Registry ;
- scan Trivy avec rapport SARIF ;
- mise a jour des tags dans `argocd/tenants/*/values.yaml`.

Trivy est volontairement non bloquant : les vulnerabilites restent visibles dans les rapports, mais le MVP continue a se deployer.

### 5. Diagnostiquer les applications exposees

Workflow :

```text
Bootstrap Kubernetes Platform
task = diagnose-apps
```

Le summary GitHub affiche :

- applications ArgoCD ;
- pods ;
- services ;
- endpoints ;
- ingresses ;
- codes HTTP publics des URLs `nip.io`.

## URLs attendues

Apres bootstrap, recuperer l'IP publique ingress-nginx dans le summary du workflow.

Format :

```text
http://portal.<IP>.nip.io
http://argocd.<IP>.nip.io
http://wordpress.<IP>.nip.io
http://slack.<IP>.nip.io
http://ghost.<IP>.nip.io
http://gitea.<IP>.nip.io
http://cloud.<IP>.nip.io
http://node-api.<IP>.nip.io
http://flask.<IP>.nip.io
http://react.<IP>.nip.io
http://keycloak.<IP>.nip.io
http://vault.<IP>.nip.io
http://metabase.<IP>.nip.io
http://wikijs.<IP>.nip.io
http://falco.<IP>.nip.io
http://trivy.<IP>.nip.io/metrics
```

Grafana, Prometheus et Alertmanager sont deployes dans ArgoCD via l'application `monitoring-grafana-prometheus`. Le summary du workflow `Deploy Monitoring - Isolated` affiche directement leurs URLs `nip.io` et le mot de passe admin Grafana decode.

En acces operateur local par port-forward :

```text
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090:9090
```

## Identifiants utiles

Les applications DevSecOps ajoutees pour la demonstration sont exposees en mode non-production :

- Keycloak : utilisateur `admin`, mot de passe `devops-factory-keycloak`.
- Vault : mode dev, stockage non persistant.
- Trivy Operator : expose surtout des rapports Kubernetes et des metriques via `/metrics`, pas une UI applicative complete.

### ArgoCD

Workflow :

```text
Bootstrap Kubernetes Platform
task = reset-argocd-password
```

Le summary affiche :

- utilisateur : `admin`
- mot de passe temporaire

Le mot de passe doit etre change apres connexion.

### Grafana

Workflow :

```text
Deploy Monitoring - Isolated
task = deploy
```

Le summary du workflow affiche directement :

- l'URL publique `http://grafana.<IP>.nip.io`
- l'URL Prometheus `http://prometheus.<IP>.nip.io`
- l'URL Alertmanager `http://alertmanager.<IP>.nip.io`
- le mot de passe admin decode depuis le secret Kubernetes `kube-prometheus-stack-grafana`

Identifiants : utilisateur `admin`, mot de passe visible dans le summary apres deploiement.

Dashboard ajoute :

- `DevOps Factory - Pods consommation` : CPU, memoire et requests CPU/memoire par namespace et par pod pour suivre la consommation de toutes les applications.

## Difference entre deploy dev et deploy prod

### Deploy dev

`Deploy Infrastructure` avec `environment = dev` sert a creer l'environnement de demonstration et de test.

C'est l'environnement utilise pour :

- le MVP ;
- les tests de workflows ;
- ArgoCD ;
- le portail ;
- les applications exposees en `nip.io`.

C'est celui a utiliser par defaut.

### Deploy prod

`Deploy Infrastructure` avec `environment = prod` sert a creer un deuxieme environnement, separe du dev.

Il est utile si le projet veut montrer une vraie separation :

- dev pour tester ;
- prod pour simuler la production ;
- state Terraform separe ;
- ressources Scaleway separees ;
- approbation GitHub Environment separee.

Attention : deployer `prod` consomme aussi des ressources Scaleway. Pour ce projet, il n'est pas obligatoire de lancer `prod` si la demo se concentre sur `dev`.

## Detail des workflows GitHub Actions

### `Bootstrap - State Buckets`

Fichier :

```text
.github/workflows/bootstrap.yml
```

Role :

Ce workflow prepare le backend Terraform distant. Terraform a besoin d'un endroit stable pour stocker son fichier d'etat, afin de savoir quelles ressources existent deja chez Scaleway.

Quand le lancer :

- une seule fois au debut du projet ;
- a relancer seulement si les buckets de state ont ete supprimes.

Ce qu'il cree :

- bucket `devops-factory-tfstate-dev` ;
- bucket `devops-factory-tfstate-prod` ;
- versioning ;
- regles de cycle de vie.

Ce qu'il ne cree pas :

- aucun cluster Kubernetes ;
- aucune ressource applicative ;
- aucune application.

Pourquoi c'est important :

Sans backend distant, le state Terraform serait local ou perdu entre deux executions GitHub Actions. Avec ce bucket, les runs CI/CD peuvent retrouver l'etat exact de l'infrastructure.

### `Deploy Infrastructure`

Fichier :

```text
.github/workflows/deploy-infra.yml
```

Role :

Ce workflow applique Terraform sur un environnement choisi (`dev` ou `prod`). Il cree l'infrastructure cloud de base.

Inputs :

| Input | Valeur | Role |
| --- | --- | --- |
| `environment` | `dev` ou `prod` | choisit le dossier Terraform `infra/terraform/environments/<env>` |

Etapes principales :

1. checkout du depot ;
2. installation de Terraform ;
3. `terraform init` avec le backend S3 Scaleway ;
4. `terraform validate` ;
5. `terraform plan` ;
6. `terraform apply` ;
7. affichage des outputs.

Ressources creees en dev :

- reseau prive Scaleway ;
- cluster Kapsule ;
- pool de nodes ;
- registry conteneur `devops-factory-dev` ;
- buckets applicatifs ;
- IAM optionnel selon les variables.

Pourquoi il existe :

Il permet de remonter toute l'infrastructure sans CLI locale. C'est utile pour une demo reproductible : un correcteur peut verifier que l'infra vient bien d'un pipeline.

### `Destroy Infrastructure`

Fichier :

```text
.github/workflows/destroy-infra.yml
```

Role :

Ce workflow detruit l'infrastructure Terraform d'un environnement donne. Il sert surtout a eviter de laisser tourner un cluster Kapsule inutilement.

Inputs :

| Input | Valeur | Role |
| --- | --- | --- |
| `environment` | `dev` ou `prod` | environnement a detruire |
| `confirm` | `destroy` | securite anti-erreur |

Etapes principales :

1. verification que `confirm` vaut exactement `destroy` ;
2. `terraform init` ;
3. `terraform plan -destroy` ;
4. affichage du plan de destruction ;
5. `terraform apply` du plan destroy.

Ce que ca supprime :

- cluster Kapsule ;
- nodes ;
- reseau Terraform ;
- registry de l'environnement ;
- buckets applicatifs de l'environnement ;
- objets Kubernetes, car le cluster disparait.

Ce que ca ne supprime pas :

- buckets Terraform state ;
- secrets GitHub ;
- historiques GitHub Actions ;
- ressources creees manuellement hors Terraform.

Impact cout :

Apres `destroy dev`, il ne doit plus y avoir de cluster Kapsule ni de nodes dev qui consomment. Les buckets de state restent, mais coutent tres peu. Pour verifier, il faut regarder la console Scaleway : Kapsule, Registry, Object Storage, VPC.

### `Bootstrap Kubernetes Platform`

Fichier :

```text
.github/workflows/bootstrap-k8s.yml
```

Role :

Ce workflow installe la couche Kubernetes au-dessus du cluster Kapsule deja cree par Terraform.

Inputs :

| Task | Role |
| --- | --- |
| `bootstrap` | installe/reconcile la plateforme Kubernetes |
| `get-argocd-password` | affiche le mot de passe initial ArgoCD |
| `reset-argocd-password` | reinitialise le mot de passe admin ArgoCD |
| `diagnose-apps` | sort un diagnostic pods/services/endpoints/HTTP |

Ce que `bootstrap` installe :

- namespaces plateforme et tenants ;
- `ResourceQuota` ;
- `LimitRange` ;
- `NetworkPolicy` ;
- RBAC deployer par tenant ;
- ingress-nginx via Helm ;
- cert-manager via Helm ;
- sealed-secrets via Helm ;
- ArgoCD via Helm ;
- root app ArgoCD ;
- portail web ;
- ingresses `nip.io`.

Pourquoi il est separe de Terraform :

Terraform cree l'infrastructure cloud. Le bootstrap Kubernetes gere ce qui vit dans le cluster. Cette separation rend le projet plus clair :

- Terraform = ressources cloud ;
- Helm/Kubectl/ArgoCD = ressources Kubernetes ;
- ArgoCD = reconciliation continue des applications.

### `Applications - DevSecOps`

Fichier :

```text
.github/workflows/apps.yml
```

Role :

Ce workflow est la chaine CI/CD applicative. Il prend les applications dans `apps/`, les teste, les analyse, les construit en images Docker, puis met a jour les tags GitOps.

Applications gerees :

- `service-alpha` : Python/FastAPI ;
- `node-api` : Node.js/Express ;
- `react` : frontend React.

Etapes principales :

| Job | Role |
| --- | --- |
| `CI` | lint + tests unitaires |
| `SonarCloud` | analyse qualite/code smells/coverage |
| `Build & Push` | build Docker + push Scaleway Registry |
| `Trivy` | scan de vulnerabilites image |
| `Update image tags` | commit des nouveaux tags dans les values ArgoCD |

Pourquoi le job `Update image tags` commit dans le repo :

Le projet suit le principe GitOps : l'etat voulu est dans Git. Quand une image est construite, le workflow met a jour :

```text
argocd/tenants/alpha/values.yaml
argocd/tenants/beta/values.yaml
argocd/tenants/gamma/values.yaml
```

ArgoCD voit ensuite ce changement et redeploie les applications.

Pourquoi Trivy est non bloquant :

Pour le MVP, on veut montrer le scan securite sans bloquer la livraison a cause d'images de base qui contiennent des CVEs. Les findings restent visibles via le rapport SARIF et l'onglet Security de GitHub.

### `Infrastructure - Terraform`

Fichier :

```text
.github/workflows/infra.yml
```

Role :

Ce workflow sert surtout aux pull requests et controles qualite Terraform.

Jobs principaux :

| Job | Role |
| --- | --- |
| `terraform-fmt` | verifie le format Terraform |
| `terraform-validate-dev` | valide la syntaxe et les providers dev |
| `terraform-validate-prod` | valide la syntaxe et les providers prod |
| `tflint` | lint Terraform |
| `checkov` | scan securite IaC |
| `terraform-plan-dev` | plan dev |
| `terraform-plan-prod` | plan prod |
| `terraform-apply-dev/prod` | apply controle selon branche/environnement |
| `terraform-destroy-dev` | destruction dev via workflow controle |

Pourquoi il existe alors qu'il y a deja `Deploy Infrastructure` :

`infra.yml` est pense pour le cycle pull request et controle continu. `deploy-infra.yml` est plus simple et manuel, utile pour l'exploitation quotidienne ou la demo.

### `bootstrap.yml` vs `deploy-infra.yml` vs `bootstrap-k8s.yml`

Ces trois workflows ne font pas la meme chose :

| Workflow | Niveau | But |
| --- | --- | --- |
| `Bootstrap - State Buckets` | stockage Terraform | creer le backend d'etat |
| `Deploy Infrastructure` | cloud Scaleway | creer le cluster et les ressources cloud |
| `Bootstrap Kubernetes Platform` | Kubernetes | installer la plateforme dans le cluster |

Ordre logique :

```text
Bootstrap - State Buckets
Deploy Infrastructure
Bootstrap Kubernetes Platform
Applications - DevSecOps
Bootstrap Kubernetes Platform / diagnose-apps
```

## Destruction et couts

### Detruire dev

Workflow :

```text
Destroy Infrastructure
environment = dev
confirm = destroy
```

Cela detruit les ressources Terraform de l'environnement dev :

- cluster Kapsule ;
- node pool ;
- reseau ;
- registry dev ;
- buckets applicatifs dev ;
- ressources IAM dev si activees.

Comme le cluster est supprime, les ressources Kubernetes installees par le bootstrap disparaissent aussi :

- ArgoCD ;
- ingress-nginx ;
- monitoring ;
- applications ;
- services LoadBalancer lies au cluster.

### Ce qui peut rester apres destroy dev

`destroy dev` ne supprime pas :

- les buckets Terraform state `devops-factory-tfstate-dev` et `devops-factory-tfstate-prod` ;
- les secrets GitHub ;
- les artifacts GitHub Actions ;
- les historiques de workflow ;
- les eventuelles ressources creees manuellement hors Terraform.

Les buckets Terraform state coutent tres peu, mais ils existent encore. Si tu veux un nettoyage total en fin de projet, il faut les supprimer manuellement ou ajouter un workflow dedie.

## Ordre recommande pour la demo

1. Ouvrir le portail `portal.<IP>.nip.io`.
2. Montrer ArgoCD et la root app.
3. Montrer les applications exposees.
4. Montrer l'application ArgoCD `monitoring-grafana-prometheus`.
5. Recuperer l'URL Grafana et le mot de passe dans le summary du workflow `Deploy Monitoring - Isolated`, ouvrir Grafana et afficher le dashboard `DevOps Factory - Pods consommation`.
6. Montrer le workflow `Applications - DevSecOps` vert.
7. Montrer Trivy/SonarCloud/Checkov comme preuves de securite.
8. Montrer Terraform et le workflow de destruction pour la maitrise des couts.

## Runbooks

- [Bootstrap Kubernetes](docs/runbooks/bootstrap-k8s.md)
- [Secrets GitHub Actions](docs/runbooks/github-actions-secrets.md)
- [Variables GitLab CI](docs/runbooks/gitlab-ci-variables.md)
