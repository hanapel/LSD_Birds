import csv 
import json

# otevrit soubor na cteni
inputFile = open("vzorek_LSD.json", encoding="utf8")
# obsah souboru v promenne data = parsing - dela datovou strukturu - sanon je slovnik (pole slovniku)
data = json.load(inputFile)

# soubor na nacteni vysledku operace s daty
outputFile = open("vzorek_LSD2.csv", "w", encoding="utf8", newline='')

# funkce writer, ktera definuje, jake oddelovace pouzit a do jakeho souboru zapisovat
csvwriter = csv.writer(outputFile, delimiter = ';')

# vlozeni hlavicky - nazvy sloupcu
csvwriter.writerow(data[0].keys())
# pro kazdy prvek (slovnik) vlozi hodnoty
for r in data:
  csvwriter.writerow(r.values())