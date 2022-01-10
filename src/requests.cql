
// Requêtes sur les protéines

// id, nom, description et taille de la protéine de taille minimale
MATCH (p:Protein) 
WITH min(p.size) as min_size
MATCH (p_min: Protein {size: min_size})
RETURN p_min.id, p_min.name, p_min.size, p_min.description;

// id, nom, description et taille de la protéine de taille maximale
MATCH (p:Protein) 
WITH max(p.size) as max_size
MATCH (p_max: Protein {size: max_size})
RETURN p_max.id, p_max.name, p_max.size, p_max.description;

// taille moyenne d’une protéine
MATCH (p:Protein) RETURN avg(p.size);


// Requêtes sur la hiérarchie de clusters

// Les clusters sans cluster parent
MATCH (c:Cluster) WHERE NOT ()-[:Is_Parent]->(c) RETURN c.id, c.description

// Le classement des id de cluster avec leur nombre de descendants directs et indirects 
// par ordre décroissant de nombre de descendants directs et indirects
MATCH p=(c:Cluster)-[:Is_Parent*]->() RETURN DISTINCT c.id, COUNT(p) as nb_desc ORDER BY nb_desc DESC

// Le nombre moyen de descendants directs et indirects de clusters
MATCH p=(c:Cluster)-[:Is_Parent*]->() WITH c.id as cid, COUNT(p) as nb_desc RETURN AVG(nb_desc)


// Requêtes sur les interactions protéine-protéine

// Les protéines (id et nom) qui interagissent avec aucune protéine
MATCH (p:Protein) WHERE NOT (p)-[:Interacts_With]-(:Protein) RETURN p.id, p.name

// Le nombre moyen (par protéine) d’interactions entre protéines en ne prenant en compte que
// les interactions entre protéines de la base de données
MATCH path=(p:Protein)-[:Interacts_With]-() WITH p.id as pid, COUNT(path) as nb_interactions RETURN AVG(nb_interactions)

// Le nombre moyen d’interactions entre protéines en prenant en compte toutes les protéines
// de la base de données
MATCH path=(p:Protein)-[:Interacts_With]-() WITH COUNT(path) as nb_interactions MATCH (p2:Protein) RETURN toFloat(nb_interactions) / COUNT(p2.id)

// Le nombre d’interactions par niveau de confiance
// Niveaux de confiance : low confidence - 0.15 (or better), medium confidence - 0.4,
// high confidence - 0.7, highest confidence - 0.9.

MATCH ()-[iwl:Interacts_With]->() WHERE iwl.combined_score >= 150 AND iwl.combined_score < 400
WITH COUNT(iwl) as nb_low
MATCH ()-[iwm:Interacts_With]->() WHERE iwm.combined_score >= 400 AND iwm.combined_score < 700
WITH COUNT(iwm) as nb_medium, nb_low
MATCH ()-[iwh:Interacts_With]->() WHERE iwh.combined_score >= 700 AND iwh.combined_score < 900
WITH COUNT(iwh) as nb_high, nb_medium, nb_low
MATCH ()-[iwht:Interacts_With]->() WHERE iwht.combined_score >= 900
RETURN nb_low as nb_interactions_low_confidence, nb_medium as nb_interactions_medium_confidence, nb_high as nb_interactions_high_confidence, COUNT(iwht) as nb_interactions_highest_confidence


// Requêtes sur les clusters de protéines

// Les protéines (id, nom) dans aucun cluster
MATCH (p:Protein) WHERE NOT (p)-[:Is_In]->() RETURN p.id, p.name

// Les protéines (id, name) dans un seul cluster (on peut dire qu’elles sont spécifiques)
MATCH (p:Protein)-[:Is_In]->(c:Cluster) WITH p, COUNT(c) as nb_clusters WHERE nb_clusters = 1 RETURN p.id, p.name

// Les protéines qui sont dans le plus grand nombre de clusters
// (elles ont plein de rôles, interviennent dans plus de mécanismes biologiques)
MATCH (p:Protein)-[:Is_In]->(c:Cluster)
WITH p, COUNT(c) as nb_clusters
WITH MAX(nb_clusters) as max
MATCH (p:Protein)-[:Is_In]->(c:Cluster)
WITH p, COUNT(c) as nb_clusters, max
WHERE nb_clusters = max
RETURN p.id, p.name

// Classement (ordre décroissant) des clusters (id) selon leur taille
MATCH (c:Cluster)<-[:Is_In]-(p:Protein)
WITH c, COUNT(p) as nb_prot
ORDER BY nb_prot DESC
RETURN c.id, nb_prot

// Taille moyenne des clusters
MATCH (c:Cluster)<-[:Is_In]-(p:Protein)
WITH c, COUNT(p) as nb_prot
WITH AVG(nb_prot) as avg_nb_proteins
RETURN avg_nb_proteins

// Requêtes sur les clusters et les interactions
// (plus complexe car cela fait intervenir une relation et un label)

// Classement (ordre décroissant) des clusters selon le nombre d’interactions intra-cluster
// des protéines qu’ils contiennent, sans prendre en compte l'interaction d’une protéine dans
// un cluster avec une protéine dans un cluster descendant ou parent

// Première proposition
MATCH (p1:Protein)-[iw:Interacts_With]->(p2:Protein), (p1)-[:Is_In]->(c1:Cluster), (p2)-[:Is_In]->(c1)
WITH c1, COUNT(iw) as nb_interactions
ORDER BY nb_interactions DESC
RETURN c1.id as id_cluster, nb_interactions

// Deuxième proposition
MATCH (c:Cluster) 
CALL {WITH c MATCH (p1:Protein)-[iw:Interacts_With]->(p2:Protein), (p1)-[:Is_In]->(c), (p2)-[:Is_In]->(c) RETURN COUNT(iw) as nb_interactions}
RETURN c.id as id_cluster, nb_interactions
ORDER BY nb_interactions DESC

// Classement (ordre décroissant) des clusters selon le nombre d’interactions inter-cluster 
// des protéines qu’ils contiennent, sans prendre en compte l'interaction d’une protéine 
// dans un cluster avec une protéine dans un cluster descendant ou parent

MATCH (c:Cluster)
CALL {WITH c MATCH (p1:Protein)-[iw:Interacts_With]->(p2:Protein), (p1)-[:Is_In]->(c) WHERE NOT EXISTS((p2)-[:Is_In]->(c)) RETURN COUNT(iw) as nb_interactions}
RETURN c.id as id_cluster, nb_interactions
ORDER BY nb_interactions DESC
