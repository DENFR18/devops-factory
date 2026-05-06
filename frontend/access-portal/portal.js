const platformApps = [
  {
    name: "ArgoCD",
    prefix: "argocd",
    mark: "AC",
    state: "GitOps",
    desc: "Console ArgoCD pour suivre la root app, les tenants et les synchronisations."
  },
  {
    name: "Prometheus",
    prefix: "prometheus",
    mark: "PR",
    state: "Metrics",
    desc: "Point d'acces prevu pour la supervision Prometheus."
  },
  {
    name: "Grafana",
    prefix: "grafana",
    mark: "GF",
    state: "Dashboards",
    desc: "Point d'acces prevu pour les dashboards de la plateforme."
  },
  {
    name: "Alertmanager",
    prefix: "alertmanager",
    mark: "AM",
    state: "Alerting",
    desc: "Gestion des alertes issues de kube-prometheus-stack."
  }
];

const tenantApps = [
  {
    name: "WordPress + MySQL",
    prefix: "wordpress",
    mark: "WP",
    state: "CMS",
    desc: "CMS WordPress avec base SQL pour la demo projet."
  },
  {
    name: "Slack-like",
    prefix: "slack",
    mark: "SL",
    state: "Mattermost",
    desc: "Messagerie d'equipe compatible usage Slack via Mattermost."
  },
  {
    name: "Ghost",
    prefix: "ghost",
    mark: "GH",
    state: "CMS",
    desc: "Plateforme de publication moderne pour blog et documentation."
  },
  {
    name: "Gitea",
    prefix: "gitea",
    mark: "GT",
    state: "Git",
    desc: "Forge Git self-hosted pour repositories, issues et pull requests."
  },
  {
    name: "Cloud",
    prefix: "cloud",
    mark: "CL",
    state: "Nextcloud",
    desc: "Espace cloud de fichiers pour la plateforme."
  },
  {
    name: "Node API",
    prefix: "node-api",
    mark: "JS",
    state: "Node.js",
    desc: "API Express exposee via GitOps."
  },
  {
    name: "Flask API",
    prefix: "flask",
    mark: "PY",
    state: "Python",
    desc: "API Python exposee pour le tenant alpha."
  },
  {
    name: "React",
    prefix: "react",
    mark: "RX",
    state: "Frontend",
    desc: "Application frontend React exposee via GitOps."
  }
];

const devsecopsApps = [
  {
    name: "Keycloak",
    prefix: "keycloak",
    mark: "KC",
    state: "IAM",
    desc: "Gestion des identites et acces pour les applications de demonstration."
  },
  {
    name: "Vault",
    prefix: "vault",
    mark: "VT",
    state: "Secrets",
    desc: "Interface Vault en mode dev pour illustrer la gestion des secrets."
  },
  {
    name: "Metabase",
    prefix: "metabase",
    mark: "MB",
    state: "BI",
    desc: "Exploration et visualisation de donnees pour le volet data."
  },
  {
    name: "Wiki.js",
    prefix: "wikijs",
    mark: "WK",
    state: "Docs",
    desc: "Wiki projet pour centraliser la documentation et les procedures."
  },
  {
    name: "Falco",
    prefix: "falco",
    mark: "FC",
    state: "Runtime",
    desc: "Console Falcosidekick pour les evenements de securite runtime."
  },
  {
    name: "Trivy Operator",
    prefix: "trivy",
    path: "/metrics",
    mark: "TV",
    state: "Scan",
    desc: "Metriques Trivy Operator exposees pour Prometheus et diagnostic securite."
  }
];

const ipInput = document.querySelector("#ingressIp");
const ipHint = document.querySelector("#ipHint");
const applyButton = document.querySelector("#applyIp");
const cardTemplate = document.querySelector("#appCard");

function detectIpFromHost() {
  const host = window.location.hostname;
  const match = host.match(/(?:^|\.)(\d+\.\d+\.\d+\.\d+)\.nip\.io$/);
  return match ? match[1] : "";
}

function getInitialIp() {
  const params = new URLSearchParams(window.location.search);
  return params.get("ip") || detectIpFromHost() || localStorage.getItem("devopsFactoryIngressIp") || "";
}

function appUrl(app, ip) {
  if (!ip) {
    return "#";
  }
  return `http://${app.prefix}.${ip}.nip.io${app.path || ""}`;
}

function renderGroup(targetId, apps, ip) {
  const target = document.querySelector(`#${targetId}`);
  target.replaceChildren();

  apps.forEach((app) => {
    const node = cardTemplate.content.cloneNode(true);
    const card = node.querySelector(".app-card");
    const link = node.querySelector(".app-link");
    const url = appUrl(app, ip);

    card.querySelector(".app-mark").textContent = app.mark;
    card.querySelector(".app-state").textContent = app.state;
    card.querySelector("h3").textContent = app.name;
    card.querySelector(".app-desc").textContent = app.desc;
    link.href = url;
    link.textContent = ip ? url.replace("http://", "") : "IP ingress requise";
    link.toggleAttribute("aria-disabled", !ip);

    target.appendChild(node);
  });
}

function render() {
  const ip = ipInput.value.trim();
  localStorage.setItem("devopsFactoryIngressIp", ip);
  renderGroup("platformApps", platformApps, ip);
  renderGroup("tenantApps", tenantApps, ip);
  renderGroup("devsecopsApps", devsecopsApps, ip);
  ipHint.textContent = ip
    ? `Liens generes avec ${ip}.nip.io`
    : "Ajoute l'IP ingress-nginx ou ouvre le portail via portal.<IP>.nip.io.";
}

ipInput.value = getInitialIp();
applyButton.addEventListener("click", render);
ipInput.addEventListener("keydown", (event) => {
  if (event.key === "Enter") {
    render();
  }
});

render();
