import csv
import sys

filas = [
    ("Datos abiertos",    82),
    ("Encuestas",         65),
    ("Redes sociales",    54),
    ("Sensores IoT",      41),
    ("Registros admin.",  37),
    ("Web scraping",      29),
    ("APIs públicas",     23),
    ("Bases internas",    18),
]

escritor = csv.writer(sys.stdout)
escritor.writerow(["recurso", "menciones"])
escritor.writerows(filas)
