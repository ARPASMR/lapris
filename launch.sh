#!/bin/bash
# il launcher deve 
# 1. copiare i file da minio in locale (cartella dati)
# 2. creare le immagini
# 3. copiare le immagioni su minio
# 4. far vedere le immagini
S3CMD='s3cmd --config=config_minio.txt'
./launch_flash.sh & 
#endless loop
#while [ 1 ]
#do
   #list dei file di ieri
   #yesterday=$(date -d "yesterday" +"%Y%m%d")
   yesterday='20180528'
   $S3CMD ls s3://prisma/dati/cumulata_oraria_prisma_${yesterday}*.txt > elenco.txt 
   # copia i file di ieri nella cartella dati
   for i in $(cat elenco.txt |awk '{ print $4; }');
   do
     s3cmd --config=config_minio.txt --force get $i dati/
   done
   Rscript prisma_cumula.R ${yesterday}00 24 Allerta CODICE_IM
#done
