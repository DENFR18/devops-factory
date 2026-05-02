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
  }
];

const tenantApps = [
  {
    name: "Tenant alpha",
    prefix: "alpha",
    mark: "A",
    state: "FastAPI",
    desc: "Service alpha deploye dans le namespace tenant-alpha."
  },
  {
    name: "Tenant beta",
    prefix: "beta",
    mark: "B",
    state: "Node.js",
    desc: "API Node.js deployee dans le namespace tenant-beta."
  },
  {
    name: "Tenant gamma",
    prefix: "gamma",
    mark: "G",
    state: "React",
    desc: "Application React deployee dans le namespace tenant-gamma."
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

function appUrl(prefix, ip) {
  if (!ip) {
    return "#";
  }
  return `http://${prefix}.${ip}.nip.io`;
}

function renderGroup(targetId, apps, ip) {
  const target = document.querySelector(`#${targetId}`);
  target.replaceChildren();

  apps.forEach((app) => {
    const node = cardTemplate.content.cloneNode(true);
    const card = node.querySelector(".app-card");
    const link = node.querySelector(".app-link");
    const url = appUrl(app.prefix, ip);

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
