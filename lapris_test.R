#!/usr/bin/Rscript
#ELABORAZIONE RASTER PER CALCOLO MEDIE E MASSIMI AREALI SU AREE DEFINITE DA SHP
# shp contenuti in sottodirectory dir info 
# 

# librerie richieste
library(raster)
library(sp)
library(rgdal)

# argomenti
stringa_data_e_ora <- character()
n_ore <- integer()
aree <- character()
args = commandArgs(trailingOnly=TRUE)
if (length(args)!=3) { 
	print("Numero argomenti non corretto!")
	print("uso: Rscript lapris_test.R aaaammgghh n aree")
	q()
	}
args<-c("2018052718", 24,"Allerta") 
print(args)
stringa_data_e_ora<-as.character(args[1])
print(stringa_data_e_ora)
n_ore <- args[2]
print(n_ore)
aree <- args[3]
print(aree)

rstr <- paste("dati/","cumulata_oraria_prisma_",stringa_data_e_ora,".txt",sep="")

#Compongo stringhe nomi file
file_shp <- paste('info/',aree,".shp", sep="")
print(file_shp)
rstr <- paste("dati/","cumulata_oraria_prisma_",stringa_data_e_ora,".txt",sep="")
print(rstr)

# lancio da CMD di Windoos con questo comando C:\"Program Files"\R\R-3.5.1\bin\Rscript.exe lapris_test.R 201801010101 3 Allerta


#giorno=readline("Che giorno vuoi visualizzare? (solo numero formato gg) ")
#orario=readline("Che orario vuoi visualizzare? (solo orario formato hh) ")
#shp=readline("Province o Aree Omogenee? (digita province o aree): ")
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
#if(shp == "province"){
#	shp <- shapefile(".\\shp\\Province_2015_polygon.shp") 
#	n_aree = 12
#	scelta_labels = "province"} else {
#	shp <- shapefile(".\\shp\\Aree_2015_UTM.shp")
#	n_aree = 14
#	scelta_labels = "aree"
#	}

if(file_test("-f",file_shp)){ 
	shp<- shapefile(file_shp)
	n_aree <- length(shp@data[,1])
	} else {
	print("Errore: non accedo allo shapefile")
	}

############################################ APRO IL RASTER SCELTO###########################################################

if(file_test("-f",rstr)){ 
	rstr_finale <- raster(rstr)
	} else {
	print("Errore: non accedo al raster iniziale")
	}
#print(Sys.getlocale(category="LC_ALL"))

#elaborazione per definire il raster somma
ore<-0
for (ore in 1:as.numeric(n_ore)) {
	print(ore)
	data_inizio <- as.POSIXct(strptime(stringa_data_e_ora,"%Y%m%d%H"))
	print(data_inizio)
	data_fine<-data_inizio+60*60*ore
	print(data_fine)
	stringa_data_incremento<-format(data_fine,"%Y%m%d%H")
	rstr<-paste("dati/","cumulata_oraria_prisma_",stringa_data_incremento,".txt",sep="")
	print(rstr)
	rstr_finale <- rstr_finale +  raster(rstr)
	}


  
par(mar = rep(2, 4))
#Grafico il raster e lo shp dedicato
png(filename=paste("dati_su_area_",stringa_data_e_ora,"_",n_ore,".png",sep=""))
plot(rstr_finale, breaks=classi, col = scala_colore, legend = FALSE, axes = FALSE)
plot(shp, add=TRUE)
plot(rstr_finale, breaks=classi_legenda, legend.only=TRUE, col=scala_colore, legend.width=1, legend.shrink=1, axis.args=list(at=classi_legenda,labels=labels, tick=FALSE))
#invisible(text(coordinates(shp), labels=as.character(shp@data$CODICE_IM), cex=0.8))
dev.off()

#calcolo Medie e percentili su Area
MEDIA<-extract(rstr_finale,shp,fun=mean,na.rm=T)
shp@data<-data.frame(shp@data,MEDIA)
PERC<-extract(rstr_finale,shp,fun=quantile,na.rm=T)
MAX<-extract(rstr_finale,shp,fun=max,na.rm=T)
shp@data<-data.frame(shp@data,MAX)

png(filename=paste("Media_su_area_",stringa_data_e_ora,"_",n_ore,".png",sep=""))
plot(shp,col=scala_colore[findInterval(shp@data$MEDIA,classi)+1])
invisible(text(coordinates(shp), labels=as.character(shp@data$CODICE_IM), cex=0.8))
dev.off()

png(filename=paste("Massimo_su_area_",stringa_data_e_ora,"_",n_ore,".png",sep=""))
plot(shp,col=scala_colore[findInterval(shp@data$MEDIA,classi)+1])
invisible(text(coordinates(shp), labels=as.character(shp@data$CODICE_IM), cex=0.8))
dev.off()



#vedere qui per grafico:
#http://rspatial.r-forge.r-project.org/gallery/#fig13.R
# e qui per tutorial
#https://www.neonscience.org/dc-shapefile-attributes-r
#https://www.neonscience.org/dc-open-shapefiles-r
#https://www.neonscience.org/dc-shapefile-attributes-r

# comando per aggregare raster su poligoni con funzione fun=...
# extract(rstr_finale,shp,fun=quantile,na.rm=T)
# shp@data<-data.frame(shp@data, vettore che voglio io)



 q()


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
	