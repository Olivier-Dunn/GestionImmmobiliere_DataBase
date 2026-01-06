# Gestion Immobilière – Base de données

## Description
Ce projet est une **base de données pour la gestion immobilière**, réalisé dans le cadre du cours IFT 187 à l'Université de Sherbrooke.  
La base permet de gérer les propriétaires, les locataires, les baux, les paiements et les travaux effectués sur les immeubles.  
Toutes les explications détaillées sont disponibles dans le rapport : [Rapport de projet SGBD](docs/RapportDeProjetSGBD.pdf)

---

## Réalisation en équipe
Projet réalisé en **équipe** avec :  
- Olivier Dunn
- Ahmed Hamissi
- Maxime Malette
- Thomas Paré 

Nous avons travaillé ensemble pour définir les entités et associations, créer le modèle conceptuel et relationnel, et développer les tests SQL pour valider les fonctionnalités.

---

## Fonctionnalités principales
- Liste de tous les baux, triée par propriétaire, avec informations complètes sur locataires et loyers  
- Calcul automatique des revenus d’un propriétaire pour un mois donné  
- Mise à jour automatique des statuts de paiement des locataires et montants à payer  
- Vérification de l’occupation d’un logement  
- Gestion des paiements de travaux et des paiements de gestion  

**Limites actuelles :**  
- Automatisation limitée aux paiements  
- Pas d’historique complet des anciens locataires ou propriétaires  
- Pas de table d’archives  

**Améliorations possibles :**  
- Étendre l’automatisation pour les paiements de gestion et travaux  
- Ajouter une table d’archives pour les anciens locataires  
- Ajouter des fonctionnalités pour visualiser l’évolution des loyers sur plusieurs années  

---

## Modèle conceptuel
**Entités principales :** Adresses, Baux, Compagnies, ContratsGestion, Immeubles, Inclusions, Locataires, Logements, PaiementsGestion, PaiementsLocataire, PaiementsTravaux, Particuliers, Propriétaires, Règles, Travaux  

**Associations principales :**  
- Adresse ↔ Immeuble/Logement  
- Bail ↔ Locataire ↔ Logement  
- ContratGestion ↔ Immeuble ↔ Propriétaire  
- PaiementGestion ↔ Propriétaire  
- PaiementLocataire ↔ Locataire ↔ Bail  
- PaiementTravaux ↔ Travaux  
- Règles ↔ Logement  
- Travaux ↔ Immeuble/Logement  

---

## Modèle relationnel & scripts
Le dépôt contient les fichiers SQL principaux pour créer, remplir et tester la base de données :  

- Création des tables : [CréationTables.sql](GestionImmobiliereDataBase/CodeSQL/CreationTables.sql)   – contient les instructions SQL pour créer toutes les tables.  
- Insertion des données : [InsertionDonnées.sql](GestionImmobiliereDataBase/CodeSQL/Fonctions.sql)  – insère les données initiales dans les tables.  
- Triggers et fonctions : [Fonctions.sql](GestionImmobiliereDataBase/CodeSQL/InsertionDonnees.sql)  – contient les triggers et fonctions pour automatiser certaines opérations.
- Tests : [TestsFonctions.sql](GestionImmobiliereDataBase/TestDeFonctions/TestsFonctions.sql) -- [TestsFonctions.pdf](GestionImmobiliereDataBase/TestDeFonctions/TestsFonctions.pdf) - Contient les tests de chacunes des fonctionalités ainsi que le rapport des tests.

---

## Technologies et outils utilisés
- **PostgreSQL** : base de données relationnelle  
- **pgAdmin** : interface de gestion PostgreSQL  
- **Notepad++** : édition et organisation des scripts SQL  
- **draw.io** : conception du diagramme relationnel  

---

## Licence
Ce projet est sous **licence MIT** – voir le fichier [LICENSE](LICENSE) pour plus de détails.
