#ELABORAZIONE RASTER PER CALCOLO MEDIE E MASSIMI AREALI 
library(raster)
library(sp)
library(rgdal)
#prova

giorno=readline("Che giorno vuoi visualizzare? (solo numero formato gg) ")
orario=readline("Che orario vuoi visualizzare? (solo orario formato hh) ")
shp=readline("Province o Aree Omogenee? (digita province o aree): ")
###################### DATI DI CONFIGURAZIONE (COLORI E CLASSI) ###################################



#scala colore per le soglie
bianco		   <- rgb(255/255, 255/255, 255/255, 1)
grigino        <- rgb(200/255, 200/255, 200/255, 1)
grigio         <- rgb(155/255, 125/255, 150/255, 1)
azzurro        <- rgb(0/255,   100/255, 255/255, 1)
verdescuro     <- rgb(5/255,   140/255, 45/255, 1)
verdino        <- rgb(5/255, 255/255, 5/255, 1)
giallo	       <- rgb(255/255, 255/255, 0/255, 1)
arancio        <- rgb(255/255, 200/255, 0/255, 1)
arancioscuro   <- rgb(255/255, 125/255, 0/255, 1)
rosso          <- rgb(255/255, 25/255, 0/255, 1)
violetto       <- rgb(175/255, 0/255, 220/255, 1)
violascuro     <- rgb(130/255, 0/255, 220/255, 1)
bluscuro       <- rgb(100/255, 0/255, 220/255, 1)

scala_colore <- c(bianco,grigino,grigio,azzurro,verdescuro,verdino,giallo,arancio,arancioscuro,rosso,violetto,violascuro,bluscuro)

classi <- c(0.1, 0.5, 1, 2, 4, 6, 10, 20, 40, 60, 80, 100,150)
classi_legenda <- seq(0,150,11.53846)
labels <- c('0','0.1', '0.5', '1', '2', '4', '6', '10', '20', '40', '60', '80', '100','150 +')

############################################ APRO LO SHAPEFILE ###########################################################
if(shp == "province"){
	shp <- shapefile(".\\shp\\Province_2015_polygon.shp") 
	n_aree = 12
	scelta_labels = "province"} else {
	shp <- shapefile(".\\shp\\Aree_2015_UTM.shp")
	n_aree = 14
	scelta_labels = "aree"
	}

############################################ APRO IL RASTER SCELTO###########################################################

raster <- raster(paste(".\\prisma27e28maggio2018\\cumulata_oraria_prisma_201805",giorno,orario,".txt",sep=""))
  
par(mar = rep(2, 4))
#Grafico il raster e lo shp dedicato
plot(raster, breaks=classi, col = scala_colore, legend = FALSE, axes = FALSE)
plot(shp, add=TRUE)
plot(raster, breaks=classi_legenda, legend.only=TRUE, col=scala_colore, legend.width=1, legend.shrink=1, axis.args=list(at=classi_legenda,labels=labels, tick=FALSE))

############################################ MEDIA E SOMMA ###########################################################
scelta_math=readline("Vuoi massimo o media delle aree scelte? ")

#identifico le aree con un indice numerico e le inserisco in un dataframe
 ID_ZONA<-array(0,c(n_aree))
 for(k in 1:n_aree) {
   ID_ZONA[k]<- k
 }
 
 shp@data <- data.frame(shp@data, ID_ZONA)
 
 #Inizializzo array per medie e massimi
MEAN<-array(0,c(n_aree))
MAX<-array(0,c(n_aree))

#Estraggo valori dal raster (quello totale)
r.vals <- extract(raster, shp)

#Ciclo per calcolare medie e massimi
for (k in 1:n_aree){
  MEAN[k]<-round(mean(r.vals[[k]],na.rm=TRUE),digits=2)
  MAX[k]<-round(max(r.vals[[k]],na.rm=TRUE),digits=2)
  if (MEAN[k]<=0.1) { MEAN[k]<-0 }
  if (MAX[k]<=0.1) { MAX[k]<-0 }
  
  shp@data$MEAN[k == shp@data$ID_ZONA]<-MEAN[k]
  shp@data$MAX[k == shp@data$ID_ZONA]<-MAX[k]
}

#Preparo ciclo per i colori inizializzando i vettori che mi servono e colorandoli di bianco
 ncolori<-length(scala_colore)
 aree<-shp@data$ID_ZONA
 colore_aree<-rep('white',n_aree)
 

shp@data <- data.frame(shp@data,COL_MEAN=t(data.frame(t(colore_aree))))
shp$COL_MEAN <-as.character.factor(shp$COL_MEAN)
shp@data <- data.frame(shp@data,COL_MAX=t(data.frame(t(colore_aree))))
shp$COL_MAX <-as.character.factor(shp$COL_MAX)

#Ciclo per colorare le province in base alla MEDIA	
 for(k in 1:n_aree) {
	for (j in 1:ncolori){
		if(shp@data$MEAN[k] <= classi[1]) {
			shp@data$COL_MEAN[k] <- scala_colore[1]
		} 
			else if(shp@data$MEAN[k] <= classi[j+1]){
				shp@data$COL_MEAN[k] <- scala_colore[j+1]
				break
			}
	}
} 

#Ciclo per colorare le province in base al MASSIMO
 for(k in 1:n_aree) {
	for (j in 1:ncolori){
		if(shp@data$MAX[k] <= classi[1]) {
			shp@data$COL_MAX[k] <- scala_colore[1]
		} 
			else if(shp@data$MAX[k] <= classi[j+1]){
				shp@data$COL_MAX[k] <- scala_colore[j+1]
				break
			}
	}
} 

#Grafico in base alla scelta fatta
if(scelta_math == "media"){
	plot(shp, col = shp@data$COL_MEAN)
	plot(raster, breaks=classi_legenda, legend.only=TRUE, col=scala_colore, legend.width=1, legend.shrink=1, axis.args=list(at=classi_legenda,labels=labels, tick=FALSE))
	} else { 
		plot(shp, col = shp@data$COL_MAX)
		plot(raster, breaks=classi_legenda, legend.only=TRUE, col=scala_colore, legend.width=1, legend.shrink=1, axis.args=list(at=classi_legenda,labels=labels, tick=FALSE))
	}

#Posizionamento labels al centro dell'area scelta
cents <- coordinates(shp)
centroids <- SpatialPointsDataFrame(coords=cents, data=shp@data, proj4string=CRS("+proj=longlat +datum=WGS84"))

#Ciclo per scorrere le aree e scrivere le labels
for(k in 1:n_aree) {
	lat=cents[shp$ID_ZONA==aree[k],2]
	lon=cents[shp$ID_ZONA==aree[k],1]
	
	if(scelta_labels == "province"){
		text(lon,lat, labels=shp@data$SIGLA[k], col="black",cex=1.0,font=2)
		#text(lon,lat -  10000, labels=round(max(shp$MEAN[shp$ID_ZONA==aree[k]],0),digits=1), col="black",cex=0.6,font=2)
	} else {
		text(lon,lat, labels=shp@data$CODICE_IM[k], col="black",cex=1.0,font=2)
		#text(lon,lat -  10000, labels=round(max(shp$MEAN[shp$ID_ZONA==aree[k]],0),digits=1), col="black",cex=0.6,font=2)	
	}
}
	