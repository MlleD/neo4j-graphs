// Classement des protéines contenues dans le plus grand nombre de clusters
// par ordre décroissant de nombre de voisins communs (ce score est affiché)
WITH ["9606.ENSP00000423067", "9606.ENSP00000422392", "9606.ENSP00000364813", "9606.ENSP00000363746",
"9606.ENSP00000363642", "9606.ENSP00000355541", "9606.ENSP00000327179", "9606.ENSP00000300413",
"9606.ENSP00000297990", "9606.ENSP00000261708", "9606.ENSP00000264279", "9606.ENSP00000252622",
"9606.ENSP00000249299", "9606.ENSP00000225298"] as list 
WITH list, apoc.coll.combinations(list, 2, 2) AS pairs
UNWIND pairs as pair 
MATCH (p1: Protein {id: pair[0] }), (p2: Protein {id: pair[1]})
RETURN p1.id, p2.id, gds.alpha.linkprediction.commonNeighbors(p1, p2) AS score ORDER BY score DESC

// Scores de proximité quand on prend en compte seulement les interactions de score 999
WITH ["9606.ENSP00000423067", "9606.ENSP00000422392", "9606.ENSP00000364813", "9606.ENSP00000363746",
"9606.ENSP00000363642", "9606.ENSP00000355541", "9606.ENSP00000327179", "9606.ENSP00000300413",
"9606.ENSP00000297990", "9606.ENSP00000261708", "9606.ENSP00000264279", "9606.ENSP00000252622",
"9606.ENSP00000249299", "9606.ENSP00000225298"] as list
WITH list, apoc.coll.combinations(list, 2, 2) AS pairs
UNWIND pairs as pair 
MATCH (p1: Protein {id: pair[0] }), (p2: Protein {id: pair[1]})
RETURN DISTINCT p1.id, p2.id, gds.alpha.linkprediction.commonNeighbors(p1, p2, 
{relationshipQuery: "Interacts_With"}) AS score ORDER BY score DESC

// Calcul du score de proximité entre les protéines contenues dans le plus grand nombre de clusters
// et les protéines avec lesquelles leur score de confiance d'interaction est de 999 (maximum)
// Affichage du score et des couples de protéines classées par ordre décroissant du score 
// de proximité
MATCH (p:Protein)-[:Is_In]->(c:Cluster)
WITH p, COUNT(c) as nb_clusters
WITH MAX(nb_clusters) as max
MATCH (p:Protein)-[:Is_In]->(c:Cluster)
WITH p, COUNT(c) as nb_clusters, max
WHERE nb_clusters = max
MATCH (p1:Protein {id:p.id})-[iwht:Interacts_With]->(p2:Protein) WHERE iwht.combined_score = 999
RETURN p1.name, p2.name, 
gds.alpha.linkprediction.resourceAllocation(p1, p2, {relationshipQuery: "Interacts_With"}) AS score
ORDER BY score DESC

// Voisins communs aux protéines présentes dans aucun cluster
MATCH (p:Protein) WHERE NOT (p)-[:Is_In]->()
WITH collect(p) as proteins
WITH apoc.coll.combinations(proteins, 2, 2) AS pairs
UNWIND pairs as pair
RETURN pair[0].name, pair[1].name, gds.alpha.linkprediction.commonNeighbors(pair[0], pair[1]) AS score
ORDER BY score DESC

// Nombre d'interaction de ces protéines
MATCH (p:Protein) WHERE NOT (p)-[:Is_In]->()
WITH collect(p) as proteins
UNWIND proteins as protein
MATCH (protein)-[iw:Interacts_With]->(p2:Protein)
RETURN protein.name, COUNT(iw) as nb_interactions
