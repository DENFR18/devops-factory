# Monitoring

Ce dossier regroupe les points d'entree lies a la supervision de la plateforme.

## Fichiers

- `monitoring-stack.yml` decrit la stack de supervision a deployer : namespace `monitoring` et application ArgoCD `monitoring-grafana-prometheus`.
- `deploy-monitoring.sh` automatise l'application de la stack, du dashboard Grafana de consommation des pods et des URLs directes operateur.

Les dashboards Grafana sont toujours charges par le sidecar `grafana_dashboard` de kube-prometheus-stack. Le manifest historique `argocd/applications/monitoring-pods-dashboard.yaml` reste applique pour etre synchronise par la root app ArgoCD.

## Utilisation

```bash
bash monitoring/deploy-monitoring.sh deploy
bash monitoring/deploy-monitoring.sh diagnose
```

Grafana, Prometheus et Alertmanager restent absents du portail public. L'acces se fait via les URLs directes `nip.io` generees par le script, ou par port-forward.
