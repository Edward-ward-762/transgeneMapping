##RUN PIPELINE
nextflow run ./main.nf \
-profile docker \
-resume \
--inputFile ./inputFile.csv 
