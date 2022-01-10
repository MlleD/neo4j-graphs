CREATE TABLE IF NOT EXISTS Protein (
    Id CHAR(20) PRIMARY KEY,
    Name VARCHAR(15) NOT NULL,
    Size INT CHECK(Size > 0) NOT NULL,
    Description TEXT NOT NULL
);

\COPY Protein FROM '../my_data/protein.info.csv' CSV HEADER;

CREATE TABLE IF NOT EXISTS Interacts_With (
    Protein1_Id CHAR(20) REFERENCES Protein (Id),
    Protein2_Id CHAR(20) REFERENCES Protein (Id),
    Combined_Score SMALLINT CHECK (Combined_Score >= 0 AND Combined_Score <= 1000) NOT NULL,
    PRIMARY KEY (Protein1_Id, Protein2_Id)
);

\COPY Interacts_With FROM '../my_data/protein.links.csv' CSV HEADER;

CREATE TABLE IF NOT EXISTS Cluster (
    Id VARCHAR(8) PRIMARY KEY,
    Description TEXT NOT NULL
);

\COPY Cluster FROM '../my_data/clusters.info.csv' CSV HEADER;

CREATE TABLE IF NOT EXISTS Is_In (
    Protein_Id CHAR(20) REFERENCES Protein (Id),
    Cluster_Id VARCHAR(8) REFERENCES Cluster (Id)
);

\COPY Is_In FROM '../my_data/clusters.proteins.csv' CSV HEADER;

CREATE TABLE IF NOT EXISTS Is_Parent (
    Parent_Cluster_Id VARCHAR(8) REFERENCES Cluster (Id),
    Child_Cluster_Id VARCHAR(8) REFERENCES Cluster (Id)
);

\COPY Is_Parent FROM '../my_data/clusters.tree.csv' CSV HEADER;