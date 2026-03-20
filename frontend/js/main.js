// Exemple de données utilisateurs pour le dashboard
const users = [
  { nom: "Hafsa", email: "hafsa@example.com", role: "Admin" },
  { nom: "Ali", email: "ali@example.com", role: "Utilisateur" },
  { nom: "Sara", email: "sara@example.com", role: "Utilisateur" }
];

const tbody = document.querySelector("#dashboardTable tbody");
users.forEach(user => {
  const tr = document.createElement("tr");
  tr.innerHTML = `<td>${user.nom}</td><td>${user.email}</td><td>${user.role}</td>`;
  tbody.appendChild(tr);
});

// Barre de bienvenue dynamique
const prenom = "Hafsa";
document.getElementById("greeting").textContent = `Bonjour ${prenom} !`;