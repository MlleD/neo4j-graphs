CREATE CONSTRAINT exists_protein_id IF NOT EXISTS ON (p:Protein) ASSERT EXISTS (p.id);
CREATE CONSTRAINT exists_protein_name IF NOT EXISTS ON (p:Protein) ASSERT EXISTS (p.name);
CREATE CONSTRAINT exists_protein_size IF NOT EXISTS ON (p:Protein) ASSERT EXISTS (p.size);
CREATE CONSTRAINT exists_protein_description IF NOT EXISTS ON (p:Protein) ASSERT EXISTS (p.description);

CREATE CONSTRAINT unique_protein_id IF NOT EXISTS ON (p:Protein) ASSERT p.id IS UNIQUE OPTIONS {indexProvider: 'lucene+native-3.0'};

CREATE CONSTRAINT exists_interacts_with_combined_score IF NOT EXISTS ON ()-[R:Interacts_With]-() ASSERT EXISTS (R.combined_score);

CREATE CONSTRAINT exists_cluster_id IF NOT EXISTS ON (c:Cluster) ASSERT EXISTS (c.id);
CREATE CONSTRAINT exists_cluster_description IF NOT EXISTS ON (c:Cluster) ASSERT EXISTS (c.description);

CREATE CONSTRAINT unique_cluster_id IF NOT EXISTS ON (c:Cluster) ASSERT c.id IS UNIQUE OPTIONS {indexProvider: 'lucene+native-3.0'};

:auto USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:/protein.info.cypher.csv' AS row
CREATE (:Protein {id: row.Id, name: row.Name, size: toInteger(row.Size), description: row.Description});

:auto USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:/protein.links.csv' AS row
MATCH (p1:Protein {id: row.Protein1_Id}), (p2:Protein {id: row.Protein2_Id})
CREATE (p1)-[:Interacts_With {combined_score: toInteger(row.Combined_Score)}]->(p2);

:auto USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:/clusters.info.csv' AS row
CREATE (:Cluster {id: row.Id, description: row.Description});

:auto USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:/clusters.proteins.csv' AS row
MATCH (p:Protein {id: row.Protein_Id}), (c:Cluster {id: row.Cluster_Id})
CREATE (p)-[:Is_In]->(c);

:auto USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:/clusters.tree.csv' AS row
MATCH (c1:Cluster {id: row.Parent_Cluster_Id}), (c2:Cluster {id: row.Child_Cluster_Id})
CREATE (c1)-[:Is_Parent]->(c2);