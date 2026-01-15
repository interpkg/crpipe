# Hua Sun
# v0.3.2


## getOptions
RUN='local'

while getopts "C:R:G:N:O:F:n:c:" opt; do
  case $opt in
    C)
      CONFIG=$OPTARG
      ;;
    R)
      RUN=$OPTARG
      ;;
    G)
      GENOME=$OPTARG
      ;;
    N)
      NAME=$OPTARG
      ;;
    O)
      OUTDIR=$OPTARG
      ;;
    F)
      FQ_DIR=$OPTARG
      ;;
    n)
      ncell=$OPTARG
      ;;
    c)
      chemistry=$OPTARG
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

source ${CONFIG}

mkdir -p $OUTDIR

if [ -d ${OUTDIR}/${NAME} ]; then
    echo "[ERROR] The name directory ${OUTDIR}/${NAME} exists !"
    exit 1
fi


# set 10xGenomics reference
ref_arc=${REF_ARC_DIR}/refdata-cellranger-arc-${GENOME}
echo $ref_arc

if [ ! -d $ref_arc ]; then
    echo "[Error] Folder does not exist!"
    exit 1
fi




cd ${OUTDIR}


# local mode: stable
if [[ $RUN == 'local' ]]; then
    ${CELLRANGER_ATAC} count --id=${NAME} \
                    --reference=${ref_arc} \
                    --fastqs=${FQ_DIR} \
                    --localcores=16 \
                    --localmem=64
fi


if [[ $RUN == 'local-fc' ]]; then
    ${CELLRANGER_ATAC} count --id=${NAME} \
                    --reference=${ref_arc} \
                    --fastqs=${FQ_DIR} \
                    --force-cells=${ncell} \
                    --chemistry=${chemistry} \
                    --localcores=16 \
                    --localmem=64
fi



if [[ $RUN == 'local-chem' ]]; then
    ${CELLRANGER_ATAC} count --id=${NAME} \
                    --reference=${ref_arc} \
                    --fastqs=${FQ_DIR} \
                    --chemistry=${chemistry} \
                    --localcores=16 \
                    --localmem=64
fi



# cluster mode - but it depends on cluster
if [[ $RUN == 'lsf' ]]; then
    ${CELLRANGER_ATAC} count --id=${NAME} \
                    --reference=${ref_arc} \
                    --fastqs=${FQ_DIR} \
                    --jobmode=lsf \
                    --mempercore=8
fi





