# lapris
progetto obiettivo 2018 LAmpinet e PRISma - Fase 4

STRUTTURA SCRIPT

prisma_cumula.R

/dati (file txt con dati di input)

/info (shapefiles)


Lancio da CMD di Windows con questo comando "Rscript prisma_cumula.R yyyymmgghh n_ore basename_shp label"
Es. "Rscript prisma_cumula.R 2018052718 12 Allerta CODICE_IM"

yyyymmgghh n_ore = Orario di partenza da cui cumulare per n-ore(Es. 2018052718 12 = Cumulo a partire dalle h 18.00 UTC e fino alle 06.00 UTC del giorno successivo)
basename_shp = Nome shapefile senza estensione (Es. Allerta, Province, etc.)
label = Nome colonna della tabella attributi shp da usare per etichette (Es. CODICE_IM, SIGLA, BACINI_AGG, etc.)

ATTENZIONE: Il periodo di cumulazione è espresso in UTC

OUTPUT:
 - Mappa con dati cumulati disaggregati su shapefile scelto
 - Mappa con media areale
 - Mappa con massimo areale
 - Tabella riassuntiva con statistiche su aree
