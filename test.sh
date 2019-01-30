for i in $(cat elenco.txt |awk '{ print $4; }');
   do
     s3cmd --config=config_minio.txt --force get $i
done

