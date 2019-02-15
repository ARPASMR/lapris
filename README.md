# lapris
_Progetto obiettivo 2018 LAmpinet e PRISma - Fase 4_

L'applicazione consente di aggregare le stime di precipitazione prodotte dal processo prisma (interpolazione ottimale di radar e pluviometri su grigliato UTM 1kmx1km) su aree a scelta dell'utente utilizzando media e percentili standard (min,10,25,50,75,90,max); in output fornisce 4 immagini: campo totale cumulato in overlay con le areee scelte, media e massimo su aree scelte, tabella con valori dei  percentili sulle aree scelte. 

# Uso in locale
- scaricare repository
- salvare nella cartella locale dati/ i dati prodotti da prisma del periodo di interesse; i dati si trovano sul server mediano, /home/meteo/dati/prisma/ascii, senza modificare il nome dei file (contiene le infomazioni sulla data e ora dei dati contenuti)
- nella cartella info sono contenuti già alcuni shapefile con i poligoni su cui aggregare le stime di precipitazione; si possono inserire altri shapefile nella stessa cartella

## struttura directory da replicare in locale
prisma_cumula.R
_file di appoggio_

/dati (file txt con dati di input)

/info (shapefiles)

## uso

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

## output
 - Mappa con dati cumulati disaggregati su shapefile scelto
 - Mappa con media areale
 - Mappa con massimo areale
 - Tabella riassuntiva con statistiche su aree

# funzionamento come container
1. esiste un bucket su minio diviso in dati e immagini; nella cartella dati vengono copiati i file in uscita da prisma _(to be implemented)_
2. il container copia a orari prestabiliti il file dal bucket alla directory _dati_, elabora il file eproduce le immagini
3. le immagini viengono servite via Flask (_completamente da fare_)
4. le immagini vengono archiviate nel bucket di minio

# uso dall'interno del container per periodo arbitrario
1. da UCP lanciare una console del container
2. lanciare il comando
```
recupero.sh AAAAMMGG HH N <shapefile> <label>
```
dove:</B>
AAAAMMGG    = data di inizio della cumulata<br>
HH          = ora di inizio della cumulata<br>
N           = numero di ore di cumulata<br>
_shapefile_ = shapefile dell'area di cumulata<br>
_label_     = campo dello shapefile per la cumulata <br>
