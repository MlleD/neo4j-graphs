DATA_DIR = "../initial_data/"
MYDATA_DIR = "../my_data/"
PREFIX_FILENAME = "9606."
SUFFIX_FILENAME = ".v11.0.txt"

def create_csv(filename, header):
    """Crée un fichier csv avec un header dans le répertoire my_data
    Args:
        filename: nom du fichier csv à créer
        header: header du csv
    """
    with open(MYDATA_DIR + filename + ".csv", "w+") as f:
        for name in header[:-1]:
            f.write(name + ",")
        f.write(header[len(header) - 1] + '\n')

def append_csv(filename, values):
    """Ajoute des valeurs au fichier csv
    Args:
        filename: nom du fichier csv
        values: valeurs à ajouter
    """
    with open(MYDATA_DIR + filename + ".csv", "a+") as f:
        for v in values[:-1]:
            f.write(v + ',')
        f.write(values[len(values) - 1] + '\n')

def convert_txt_to_csv(txtname, txtsep, idx_columns, idx_txt_cols):
    """Ajoute à un fichier csv les données des colonnes choisies dans le txt source
    Args:
        txtname: nom du fihcier .txt source de la conversion
        txtsep: séparateur des valeurs dans chaque ligne du fichier txt
        idx_columns: index des colonnes du fichier txt à mettre dans le fichier csv
        idx_txt_cols: set des index de colonnes textuelles parmi les index de idx_columns
    """
    with open(DATA_DIR + PREFIX_FILENAME + txtname + SUFFIX_FILENAME) as f:
        for line in f.readlines()[1:]:
            vals = line.rstrip().split(txtsep)
            data = []
            for i in idx_columns:
                v = "\"" + vals[i] + "\"" if i in idx_txt_cols else vals[i]
                data.append(v)
            append_csv(txtname, data)

if __name__ == "__main__":
    filenames = [
        "protein.info", "protein.links", 
        "clusters.info", "clusters.proteins", "clusters.tree"]
    colnames = [
        ["Id", "Name", "Size", "Description"], ["Protein1_Id", "Protein2_Id", "Combined_Score"],
        ["Id", "Description"], ["Protein_Id", "Cluster_Id"], ["Parent_Cluster_Id", "Child_Cluster_Id"]]
    idx_cols = [[0, 1, 2, 3], [0, 1, 2], [1, 3], [2, 1], [2, 1]]
    seps = ['\t', ' ', '\t', '\t', '\t']
    idx_txt_cols = [set([3]), set(), set([3]), set(), set()]

    for name, cols, icols, txtsep, itxtcols in zip(filenames, colnames, idx_cols, seps, idx_txt_cols):
        create_csv(name, cols)
        convert_txt_to_csv(name, txtsep, icols, itxtcols)
