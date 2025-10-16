##UPDATE PIPELINE
nextflow pull Edward-ward-762/transgeneMapping -r main

##RUN PIPELINE
nextflow run Edward-ward-762/transgeneMapping \
-r main \
-profile docker \
-resume \
--inputFile ./inputFile.csv 
