# Requêtes d'une BDD et création d'un tableau de bord (projet pédagogique de formation)

## A propos

Projet pédagogique de formation réalisé au cours de la formation *Data Analyst* de la Wild Code School.  
Ce projet a pour but de créer un tableau de bord pour une **entreprise fictive** de vente de modèles réduits pour répondre à des questions posées par l'entreprise concernant 4 départements :
- **Ventes** : ventes des produits par catégorie et par mois, avec comparaison par rapport aux mêmes mois de l'année précédente.
- **Finances** : 
  - chiffre d'affaires des deux derniers mois par pays
  - montant des factures impayées.
- **Logistique** : stock des produits les plus vendus.
- **Ressources Humaines** : les vendeurs ayant le meilleur chiffre d'affaires chaque mois.

## Descriptif des fichiers présents

### Synthèse_Projet_requêtes_BDD_et_tableau_de_bord_2023_03_31.pdf
Synthèse du projet. Ce fichier présente :
- Le contexte du projet
- Les objectifs et ce qui est attendu par le client
- La base de données disponible
- Ce qui a été fait :
  - Requêtes SQL
  - Visualisations et tableau de bord

### Dashboard_projet_01.pbix
Fichier Power BI contenant le tableau de bord. Dans chaque onglet, on retrouve un ou plusieurs graphiques qui répondent aux demandes du client, ou qui proposent d'aller plus loin avec d'autres indicateurs.  
Ces graphiques sont identifiés par département.

### Fichiers .sql
Ces fichiers contiennent certaines des requêtes SQL utilisées dans Power BI lors du chargement des données et de la connexion à la source de données distante.
- Queries_views_turnover_by_country_by_month_year.sql : requêtes SQL utilisées pour récupérer les chiffres d'affaires par pays, par mois et par an.
- Queries_unpaid_orders.sql : requêts SQL utilisées pour récupérer le montant des commandes impayées ; ce fichier contient plusieurs requêtes avec les commandes, les montants des commandes par client.

## Fabriqué avec

### Langage
- SQL

### Logiciels
- MySQL Workbench
- Power BI

## Auteurs

* **Julien Michaut** _alias_ [@Miche5967](https://github.com/Miche5967)
* **Elizabeth Landry**
* **Geoffrey Castel**
* **Julien Mahiette**

