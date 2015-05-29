import LINZ.gazetteer.gui.DatabaseConfiguration
from LINZ.gazetteer import Export

e = Export.Export()
# print e.getFields()
e.createCsvFile('gazetteer_export.gaz_names_csv','gaznames.csv')

