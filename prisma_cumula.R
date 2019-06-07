#!/usr/bin/Rscript
#ELABORAZIONE RASTER PER CALCOLO MEDIE E MASSIMI AREALI SU AREE DEFINITE DA SHP
# shp contenuti in sottodirectory dir info 
# 

# librerie richieste
library(raster)
library(sp)
library(rgdal)
library(grid)
library(gridExtra)
library(png)

# argomenti
stringa_data_e_ora <- character()
n_ore <- integer()
aree <- character()
nome_aree <- character()
args = commandArgs(trailingOnly=TRUE)
if (length(args)!=4) { 
	print("Numero argomenti non corretto!")
	print("uso: Rscript prisma_cumula.R aaaammgghh n_ore aree nome_aree ")
	q()
	}

print(args)
stringa_data_e_ora<-as.character(args[1])
print(stringa_data_e_ora)
n_ore <- args[2]
print(n_ore)
aree <- args[3]
print(aree)
nome_aree <- args[4]
print(nome_aree)

rstr <- paste("dati/","cumulata_oraria_prisma_",stringa_data_e_ora,".txt",sep="")

#Compongo stringhe nomi file
file_shp <- paste('info/',aree,".shp", sep="")
print(file_shp)
rstr <- paste("dati/","cumulata_oraria_prisma_",stringa_data_e_ora,".txt",sep="")
print(rstr)

# lancio da CMD di Windoos con questo comando C:\"Program Files"\R\R-3.5.1\bin\Rscript.exe prisma_cumula.R 201801010101 3 Allerta CODICE_IM

n_ore <- as.numeric(n_ore)

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
ocra		   <- rgb(207/255, 132/255, 67/255, 1)
marrone        <- rgb(138/255, 90/255, 44/255, 1)

scala_colore <- c(bianco,grigino,grigio,azzurro,verdescuro,verdino,giallo,arancio,arancioscuro,rosso,violetto,violascuro,bluscuro,ocra,marrone)
classi <- c(0, 0.1, 0.5, 1, 2, 4, 6, 10, 20, 40, 60, 80, 100, 150, 200, 250)
classi <- classi * floor((n_ore-1)/24+1) #adattamento scala in base al numero di ore, se maggiore di 24 si moltiplica per 2, dopo 48 per 3 etc etc ...
classi_legenda <- seq(0,250,16.66666)
classi_legenda <- classi_legenda * floor((n_ore-1)/24+1) #adattamento classi_legenda in base al numero di ore, se maggiore di 24 si moltiplica per 2, dopo 48 per 3 etc etc ...

#Ridefinizione labels in base al numero di ore, devo prima trasformarle in numeri e poi nuovamente in caratteri.
labels <- c('0','0.1', '0.5', '1', '2', '4', '6', '10', '20', '40', '60', '80', '100','150', '200', '250')
labels <- as.numeric(labels)
labels <- labels * floor((n_ore-1)/24+1)
labels <- as.character(labels)


############################################ APRO LO SHAPEFILE ###########################################################

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

n_ore_mod <- n_ore - 1 #Sommo il numero di ore scelte in base all'orario di partenza (che già contiene la cumulata di 1 ora)
n_mancanti=0
for (ore in 1:as.numeric(n_ore_mod)) {
	print(ore)
	data_inizio <- as.POSIXct(strptime(stringa_data_e_ora,"%Y%m%d%H"),"GMT")
	print(data_inizio)
	data_fine<-data_inizio+60*60*ore
	print(data_fine)
	stringa_data_incremento<-format(data_fine,"%Y%m%d%H")
	rstr<-paste("dati/","cumulata_oraria_prisma_",stringa_data_incremento,".txt",sep="")
	if (file.exists(rstr)){
		print(rstr)
		rstr_finale <- rstr_finale +  raster(rstr)
		} else {
		print ("file non esistente",rstr)
	        n_mancanti=n_mancanti+1
		}
	} 


data_fine_mod <- data_fine + 60*60 #aggiungo un'ora per necessità grafiche del titolo (più comprensibile per il periodo di cumulazione)

par(mar = rep(2, 4))
#Grafico il raster e lo shp dedicato
png(filename=paste("dati_su_area_",stringa_data_e_ora,"_",n_ore,".png",sep=""), width=1600, height=1200)
plot(rstr_finale, breaks=classi, col = scala_colore, legend = FALSE, axes = FALSE)
plot(shp, add=TRUE)
plot(rstr_finale, breaks=classi_legenda, legend.only=TRUE, col=scala_colore, legend.width=1, legend.shrink=1, axis.args=list(at=classi_legenda,labels=labels, tick=FALSE, cex.axis=1.8))
title(main=paste("Precipitazioni cumulate dal", data_inizio,"al",data_fine_mod," (UTC)",n_ore_mod-n_mancanti,"/",n_ore_mod),adj=0, cex.main=2.2)
dev.off()

#calcolo Medie e percentili su Area
MEDIA<-extract(rstr_finale,shp,fun=mean,na.rm=T)
MEDIA <- round(MEDIA,digits=2)
shp@data<-data.frame(shp@data,MEDIA)
PERC<-extract(rstr_finale,shp,fun=function(rstr_finale,na.rm){quantile(rstr_finale,probs=c(0,0.5,0.75,0.9,1),na.rm=TRUE)})
MAX<-extract(rstr_finale,shp,fun=max,na.rm=T)
shp@data<-data.frame(shp@data,MAX)


####################################################### TABLE ######################################################
#Conto righe nel dataframe
nrow <- nrow(shp)

#Creo tabella vuota con numero di righe in base allo shp
table <- data.frame(matrix(ncol=3,nrow=nrow))


#Assegnazione colonne
table[,1] <- shp[[nome_aree]]
table[,2] <- round(shp$MEDIA,digits=1)
table[,3] <- round(shp$MAX,digits=1)

#Assegnazione nome e ordinamento in base alla media (più avanti lo farò in base al massimo)
colnames(table) <- c("AREA","MEDIA","MAX")
table <- table[order(-table$MEDIA),]

#Assegnazione "tema" per disegno tabella
tt <- ttheme_default(base_size=24)
total_tt <- ttheme_default(base_size=16)

#Creazione tabella totale con percentili e assegnazioni/ordinamenti
total_table <- data.frame(shp[[nome_aree]],round(PERC,digits=1),round(MEDIA,digits=1))
colnames(total_table) <- c("AREA","MIN","50\U00B0","75\U00B0","90\U00B0","MAX","MEDIA")
total_table <- total_table[order(-shp@data$MEDIA),]

#Creo png tabella totale
png(filename=paste("Tabella_",stringa_data_e_ora,"_",n_ore,".png",sep=""))
grid.table(total_table,theme=total_tt, rows=NULL)
dev.off()


##################################################GRAFICI MEDIE E MASSIMI#################################################
png(filename=paste("Media_su_area_",stringa_data_e_ora,"_",n_ore,".png",sep=""),width=1600, height=1200)
par(mar=c(2.1,8.1,2.1,2.1)) #Margini del grafico
plot(shp,col=scala_colore[findInterval(shp@data$MEDIA,classi)])
title(main=paste("Media precipitazioni cumulate dal", data_inizio,"al",data_fine_mod," (UTC)",n_ore_mod-n_mancanti,"/",n_ore_mod),adj=0, cex.main=2.2)
plot(rstr_finale, breaks=classi_legenda, legend.only=TRUE, col=scala_colore, legend.width=1, legend.shrink=1, axis.args=list(at=classi_legenda,labels=labels, tick=FALSE, cex.axis=1.8))
invisible(text(coordinates(shp), labels=as.character(shp[[nome_aree]]), cex=1.5))
pushViewport(viewport(y=.75,x=.10, height=0.5)) #Posizionamento tabella
grid.table(table,theme=tt, rows=NULL) #Disegno tabella
dev.off()

png(filename=paste("Massimo_su_area_",stringa_data_e_ora,"_",n_ore,".png",sep=""),width=1600, height=1200)
par(mar=c(2.1,8.1,2.1,2.1)) #Margini del grafico
plot(shp,col=scala_colore[findInterval(shp@data$MAX,classi)])
title(main=paste("Massimo precipitazioni cumulate dal", data_inizio,"al",data_fine_mod," (UTC)",n_ore_mod-n_mancanti,"/",n_ore_mod),adj=0, cex.main=2.2)
plot(rstr_finale, breaks=classi_legenda, legend.only=TRUE, col=scala_colore, legend.width=1, legend.shrink=1, axis.args=list(at=classi_legenda,labels=labels, tick=FALSE, cex.axis=1.8))
invisible(text(coordinates(shp), labels=as.character(shp[[nome_aree]]), cex=1.5))
table <- table[order(-table$MAX),] #Ordinamento in base al massimo
pushViewport(viewport(y=.75,x=.10, height=0.5)) #Posizionamento tabella
grid.table(table,theme=tt, rows=NULL) #Disegno tabella
dev.off()

################################################## COMPOSITE FOR WEB #############################################à##

#Lettura dei PNG già stampati e trasformazione in raster
img1 <- as.raster(readPNG(paste("dati_su_area_",stringa_data_e_ora,"_",n_ore,".png",sep="")))
img2 <- as.raster(readPNG(paste("Media_su_area_",stringa_data_e_ora,"_",n_ore,".png",sep="")))
img3 <- as.raster(readPNG(paste("Massimo_su_area_",stringa_data_e_ora,"_",n_ore,".png",sep="")))
img4 <- as.raster(readPNG(paste("Tabella_",stringa_data_e_ora,"_",n_ore,".png",sep="")))

#Stampo un nuovo PNG componendo i 4 raster
png(filename=paste("Composizione_",stringa_data_e_ora,"_",n_ore,".png",sep=""), width=1600, height=1200)
par(mfrow=c(2,2),mai=c(0.1,0.1,0.1,0.1)) #Settaggio margini al minimo per una migliore resa grafica
plot(img1)
plot(img2)
plot(img3)
plot(img4)
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

 #q()
