PROG=audfprint
VER=$(shell grep '^\s*VERSION' ${PROG}.m | sed -e 's/[^0-9.]*\([0-9.]*\)[^0-9.]*/\1/')
DST=${PROG}-v${VER}
#TAR=${DST}.tgz
ZIP=${DST}.zip

#ARCH=`${MATLAB} -nojvm -nodisplay -nosplash -r "disp(computer);quit" | tail -2 | head -1 | sed `
#ARCH=MACI64
ARCH=$(shell ./matlab_arch.sh)
arch=$(shell ./matlab_arch.sh 1)

MCR_NAME=${PROG}_${ARCH}
PRJ_NAME=${PROG}_${ARCH}
#PRJ_NAME=${PROG}_prj

#MATLAB=/usr/bin/Matlab 
#DEPLOYTOOL=/usr/bin/deploytool
MATLAB=/Applications/MATLAB_R2010b.app/bin/matlab
# MacOS 64 bit (dpwe-macbook)
DEPLOYTOOL=/Applications/MATLAB_R2010b.app/bin/deploytool
# Linux 64 bit (hog)
#DEPLOYTOOL=/usr/local/MATLAB/R2010b/bin/deploytool 
# Linux 32 bit (cherry)
#DEPLOYTOOL=${MATLAB} -r deploytool

# MCC
#MCC=/Applications/MATLAB_R2010b.app/bin/mcc

MAINFILE=${PROG}.m

#THUMB=${PROG}_thumb.png

SRCS=audfprint.m add_hash.m match_hash.m find_landmarks.m landmark2hash.m audioread.m mp3read.m m4aread.m wavread_downsamp.m process_options.m

#DATA=${THUMB} query.mp3
DATA=query.mp3

FORCOMPILE=${PRJ_NAME}.prj run_prj_${ARCH}.sh Makefile matlab_arch.sh

all: dist
compile: ${MCR_NAME}.zip

# The later one will override on an actual A64 target
#${PROG}_GLNXA64.zip: ${SRCS}
#	rsync -avz ./*.m Makefile hog.ee.columbia.edu:projects/audfprint/
#	ssh -Y hog.ee.columbia.edu "cd projects/audfprint; make compile"
#	scp -p hog.ee.columbia.edu:projects/audfprint/audfprint_GLNXA64.zip .

${MCR_NAME}.zip: ${SRCS}
	-rm -rf ${PRJ_NAME}
	${DEPLOYTOOL} -build ${PRJ_NAME}
#	${MCC} -o ${PRJ_NAME} -W main:${PRJ_NAME} -T link:exe -d ${PRJ_NAME}/src -w enable:specified_file_mismatch -w enable:repeated_file -w enable:switch_ignored -w enable:missing_lib_sentinel -w enable:demo_license -v ${MAINFILE} $$x
	rm ${PRJ_NAME}/distrib/run_${PRJ_NAME}.sh
	cp run_prj_${ARCH}.sh ${PRJ_NAME}/distrib/${PROG}
	mv ${PRJ_NAME}/distrib ${PRJ_NAME}/${MCR_NAME}
	cd ${PRJ_NAME} && zip -r ${MCR_NAME}.zip ${MCR_NAME} && cd ..
	mv ${PRJ_NAME}/${MCR_NAME} ${PRJ_NAME}/distrib
	mv ${PRJ_NAME}/${MCR_NAME}.zip .

dist: ${SRCS} ${DATA} ${EXTRABINS} ${FORCOMPILE} ${PROG}_MACI64.zip
	rm -rf ${PROG}
	rm -rf ${DST}
	mkdir ${DST}
	cp -p ${SRCS} ${DATA} ${EXTRABINS} ${FORCOMPILE} ${DST}
	rm -f ${DST}/*~
	-rm-extended-attribs.sh ${DST}
#	tar cfz ${TAR} ${DST}
	zip -r ${ZIP} ${DST}
# needs to be called PROG (no ver number) not DST on server
	mv ${DST} ${PROG}
	cp -p ${ZIP} ${PROG}
#	cp -p ${PROG}_${ARCH}.zip ${PROG}
	cp -p ${PROG}_MACI64.zip ${PROG}
#	cp -p ${PROG}_GLNXA64.zip ${PROG}
#	scp -pr ${PROG} hog.ee.columbia.edu:public_html/resources/matlab/
#	scp -pr ${PROG} wool.ee.columbia.edu:wool-public_html/resources/matlab/
#	scp -pr ${PROG} fac1.ee.columbia.edu:/q/www/www-h1/dpwe/resources/matlab/
#	scp -pr ${PROG} labrosa.ee.columbia.edu:/var/www/dpwe/resources/matlab/

#sync:
#	rsync -avz ./*.m Makefile hog.ee.columbia.edu:projects/audfprint/

#buildonhog: sync
#	ssh -Y hog.ee.columbia.edu "cd projects/audfprint; make compile"
#	scp -p hog.ee.columbia.edu:projects/audfprint/audfprint_GLNXA64.zip .

