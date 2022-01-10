from txt_to_csv import MYDATA_DIR, append_csv

def escape_internal_quotes(str): 
    """Echappe les guillemets à l'intérieur d'une chaîne de caractères
    délimitée par des guillemets
    Args: 
        str: chaîne de caractère à traiter
    Returns:
        la chaîne de caractère après traitement
    """
    internal = str[1:-1]
    return '"' + internal.replace('"', '""') + '"'

def convert_csv(csv_source_name, csv_converted_name):
    """Convertit un csv avec des guillemets imbriqués en un csv acceptable
    (échappement des guillements internes) pour Cypher
    """
    with open(MYDATA_DIR + csv_source_name + ".csv") as f:
        content = f.readlines()
        append_csv(csv_converted_name, content[0].rstrip().split(','))
        for line in content[1:]:
            last_index = 3
            vals = line.rstrip().split(',', last_index)
            data = [vals[i] for i in range(last_index)]
            data.append(escape_internal_quotes(vals[last_index]))
            append_csv(csv_converted_name, data)

if __name__ == "__main__":
    source_name = "protein.info"
    convert_csv(source_name, source_name + ".cypher")