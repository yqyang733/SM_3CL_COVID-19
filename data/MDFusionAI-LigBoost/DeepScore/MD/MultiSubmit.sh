IFS=",";for i in `cat lst`;do cd ${i};cp ../script/* .;sh build_pipline.sh ${i}.mol2 ${i}.pdb;cd ..;done
IFS=",";for i in `cat lst`;do echo ${i};done