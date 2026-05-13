#!/usr/bin/env bash
set -euo pipefail

TASK="${1:-deploy}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ "${TASK}" != "deploy" ] && [ "${TASK}" != "diagnose" ]; then
  echo "Usage: bash monitoring/deploy-monitoring.sh [deploy|diagnose]"
  exit 1
fi

need_kubectl() {
  if ! command -v kubectl >/dev/null 2>&1; then
    echo "kubectl est requis pour deployer le monitoring."
    exit 1
  fi
}

write_env() {
  if [ -n "${GITHUB_ENV:-}" ]; then
    {
      echo "MONITORING_INGRESS_IP=${1}"
      echo "GRAFANA_URL=http://grafana.${1}.nip.io"
      echo "PROMETHEUS_URL=http://prometheus.${1}.nip.io"
      echo "ALERTMANAGER_URL=http://alertmanager.${1}.nip.io"
    } >> "${GITHUB_ENV}"
  fi
}

summary() {
  if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
    tee -a "${GITHUB_STEP_SUMMARY}"
  else
    cat
  fi
}

get_ingress_ip() {
  kubectl -n ingress-nginx get svc ingress-nginx-controller \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true
}

deploy_base() {
  kubectl apply -f "${ROOT_DIR}/monitoring/monitoring-stack.yml"
  kubectl apply -f "${ROOT_DIR}/argocd/applications/monitoring-pods-dashboard.yaml"
}

wait_for_argocd() {
  kubectl -n argocd wait application/monitoring-grafana-prometheus \
    --for=jsonpath='{.status.sync.status}'=Synced \
    --timeout=600s || true
  kubectl -n argocd wait application/monitoring-grafana-prometheus \
    --for=jsonpath='{.status.health.status}'=Healthy \
    --timeout=600s || true
}

expose_direct_urls() {
  local ingress_ip
  ingress_ip="$(get_ingress_ip)"

  if [ -z "${ingress_ip}" ]; then
    echo "IP publique ingress-nginx introuvable."
    exit 1
  fi

  cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: monitoring-direct-access
  namespace: monitoring
  labels:
    app.kubernetes.io/name: monitoring-direct-access
    app.kubernetes.io/part-of: platform
    app.kubernetes.io/component: monitoring
spec:
  ingressClassName: nginx
  rules:
    - host: grafana.${ingress_ip}.nip.io
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: kube-prometheus-stack-grafana
                port:
                  number: 80
    - host: prometheus.${ingress_ip}.nip.io
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: kube-prometheus-stack-prometheus
                port:
                  number: 9090
    - host: alertmanager.${ingress_ip}.nip.io
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: kube-prometheus-stack-alertmanager
                port:
                  number: 9093
EOF

  write_env "${ingress_ip}"
}

diagnostics() {
  {
    echo "## Monitoring direct"
    echo ""
    echo "### ArgoCD"
    echo '```'
    kubectl -n argocd get application monitoring-grafana-prometheus -o wide || true
    echo '```'
    echo ""
    echo "### Pods monitoring"
    echo '```'
    kubectl -n monitoring get pods -o wide || true
    echo '```'
    echo ""
    echo "### Services internes"
    echo '```'
    kubectl -n monitoring get svc kube-prometheus-stack-grafana kube-prometheus-stack-prometheus kube-prometheus-stack-alertmanager || true
    echo '```'
    echo ""
    echo "### Ingress monitoring direct"
    echo '```'
    kubectl -n monitoring get ingress || true
    echo '```'
    echo ""
    echo "### Acces operateur alternatif"
    echo '```bash'
    echo "kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80"
    echo "kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090:9090"
    echo "kubectl -n monitoring get secret kube-prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 -d; echo"
    echo '```'
  } | summary
}

access_summary() {
  local ingress_ip grafana_password
  ingress_ip="$(get_ingress_ip)"
  grafana_password="$(kubectl -n monitoring get secret kube-prometheus-stack-grafana \
    -o jsonpath='{.data.admin-password}' 2>/dev/null | base64 -d || echo 'indisponible')"

  {
    echo "---"
    echo "## Acces monitoring"
    echo ""
    if [ -n "${ingress_ip}" ]; then
      echo "| Service | URL | Credentials |"
      echo "|---------|-----|-------------|"
      echo "| Grafana | http://grafana.${ingress_ip}.nip.io | admin / \`${grafana_password}\` |"
      echo "| Prometheus | http://prometheus.${ingress_ip}.nip.io | - |"
      echo "| Alertmanager | http://alertmanager.${ingress_ip}.nip.io | - |"
    else
      echo "> IP ingress-nginx non disponible. Le LoadBalancer est peut-etre encore en cours de provisionnement."
      echo ""
      echo "Mot de passe Grafana admin : \`${grafana_password}\`"
    fi
  } | summary
}

need_kubectl

if [ "${TASK}" = "deploy" ]; then
  deploy_base
  wait_for_argocd
  expose_direct_urls
fi

diagnostics
access_summary
