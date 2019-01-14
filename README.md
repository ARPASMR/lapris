# lapris
_Progetto obiettivo 2018 LAmpinet e PRISma - Fase 4_
L'applicazione consente di realizzare delle immagini che riguardano le cumulate del processo prisma per scadenze prefissate o per scadenze impostate dall'utente.

# struttura directory
prisma_cumula.R
_file di appoggio_

/dati (file txt con dati di input)

/info (shapefiles)

# uso

Lancio da CMD di Windows con questo comando 
```
Rscript prisma_cumula.R yyyymmgghh n_ore basename_shp label
```
dove:
- yyyymmgghh n_ore = Orario di partenza da cui cumulare per n-ore(Es. 2018052718 12 = Cumulo a partire dalle h 18.00 UTC e fino alle 06.00 UTC del giorno successivo)  
- basename_shp = Nome shapefile senza estensione (Es. Allerta, Province, etc.)  
- label = Nome colonna della tabella attributi shp da usare per etichette (Es. CODICE_IM, SIGLA, BACINI_AGG, etc.)

__Esempio__
```
Rscript prisma_cumula.R 2018052718 12 Allerta CODICE_IM
```

ATTENZIONE: Il periodo di cumulazione è espresso in UTC

# output
 - Mappa con dati cumulati disaggregati su shapefile scelto
 - Mappa con media areale
 - Mappa con massimo areale
 - Tabella riassuntiva con statistiche su aree

# funzionamento come container
1. esiste un bucket su minio diviso in dati e immagini; nella cartella dati vengono copiati i file in uscita da prisma _(to be implemented)_
2. il container copia a orari prestabiliti il file dal bucket alla directory _dati_, elabora il file eproduce le immagini
3. le immagini viengono servite via Flask (_completamente da fare_)
4. le immagini vengono archiviate nel bucket di minio
