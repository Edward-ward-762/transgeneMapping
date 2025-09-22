##UPDATE PIPELINE
nextflow pull Edward-ward-762/transgeneMapping

##RUN PIPELINE
nextflow run Edward-ward-762/transgeneMapping \
-profile docker \
-resume \
--inputFile ./inputFile.csv 
