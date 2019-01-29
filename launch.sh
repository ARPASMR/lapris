#!/bin/bash
# il launcher deve 
# 1. copiare i file da minio in locale (cartella dati)
# 2. creare le immagini
# 3. copiare le immagioni su minio
# 4. far vedere le immagini
./launch_flash.sh & 
while [ 1 ]
do
   s3cmd --config= get s3://prisma/dati/cumulata_oraria_prisma_$(date "%Y%m%d").txt 
done
