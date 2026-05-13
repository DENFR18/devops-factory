const platformApps = [
  {
    name: "ArgoCD",
    prefix: "argocd",
    mark: "AC",
    state: "Pilotage",
    desc: "Console GitOps pour suivre la root app, les tenants et les synchronisations."
  }
];

const tenantApps = [
  {
    name: "WordPress + MySQL",
    prefix: "wordpress",
    mark: "WP",
    state: "Web",
    desc: "Site vitrine client avec base SQL dediee pour les contenus projet."
  },
  {
    name: "Messagerie",
    prefix: "slack",
    mark: "SL",
    state: "Collaboration",
    desc: "Espace d'equipe Mattermost pour les echanges projet et run."
  },
  {
    name: "Ghost",
    prefix: "ghost",
    mark: "GH",
    state: "Editorial",
    desc: "Publication de contenus, annonces et articles autour de la transformation cloud."
  },
  {
    name: "Gitea",
    prefix: "gitea",
    mark: "GT",
    state: "Factory",
    desc: "Forge Git self-hosted pour repositories, issues et pull requests."
  },
  {
    name: "Cloud",
    prefix: "cloud",
    mark: "CL",
    state: "Documents",
    desc: "Espace fichiers pour partager les livrables et supports de mission."
  },
  {
    name: "Node API",
    prefix: "node-api",
    mark: "JS",
    path: "/health",
    state: "API",
    desc: "Service Express expose pour valider la chaine build, scan et deploy."
  },
  {
    name: "Flask API",
    prefix: "flask",
    mark: "PY",
    path: "/health",
    state: "API",
    desc: "Service Python/FastAPI pour le tenant alpha et les tests de disponibilite."
  },
  {
    name: "React",
    prefix: "react",
    mark: "RX",
    state: "Frontend",
    desc: "Interface web moderne livree en conteneur nginx via GitOps."
  }
];

const devsecopsApps = [
  {
    name: "Keycloak",
    prefix: "keycloak",
    mark: "KC",
    state: "IAM",
    desc: "Gestion des identites et des acces pour les applications de demonstration."
  },
  {
    name: "Vault",
    prefix: "vault",
    mark: "VT",
    state: "Secrets",
    desc: "Illustration de la gestion des secrets et des pratiques zero trust."
  },
  {
    name: "Metabase",
    prefix: "metabase",
    mark: "MB",
    state: "BI",
    desc: "Exploration de donnees pour les indicateurs metier et plateforme."
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
