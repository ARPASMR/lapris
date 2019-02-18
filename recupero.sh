#!/bin/bash
# il launcher deve 
# 1. copiare i file da minio in locale (cartella dati)
# 2. creare le immagini
# 3. copiare le immagioni su minio
# 4. far vedere le immagini
S3CMD='s3cmd --config=config_minio.txt'
H='00'
N='24'
Shp='Allerta'
Campo='CODICE_IM'

   #list dei file di ieri
   if [[ -n $1 ]]; then
       yesterday=$1
   else
      yesterday=$(date -d "yesterday" +"%Y%m%d")
   fi   
   #yesterday='20180528'
   $S3CMD ls s3://prisma/dati/cumulata_oraria_prisma_${yesterday}* > elenco.txt 
   # copia i file di ieri nella cartella dati
   for i in $(cat elenco.txt |awk '{ print $4; }');
   do
     s3cmd --config=config_minio.txt --force get $i dati/
   done
   #eseguo lo script reindirizzando nei log
   if [[ -n $2 ]]; then
      H=$2
   fi
   if [[ -n $3 ]]; then
      N=$3
   fi
   if [[ -n $4 ]]; then
      Shp=$4
   fi
   if [[ -n $5 ]]; then
      Campo=$5
   fi
   Rscript prisma_cumula.R ${yesterday}${H} $N $Shp $Campo > prisma_cumula_${yesterday}.log
   $S3CMD put *.png s3://prisma
   mv *.png static/

  ls -L ./static/*.png > ./static/fof.txt
  
