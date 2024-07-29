#!/bin/bash

approach=$1
annotated_data=$2

pip install gdown==5.0
cd ${approach}/data

mkdir -p Split_Dataset/Data
mkdir -p Split_Dataset/Ground_truth

cd Split_Dataset/Data/

if [ "$annotated_data" = true ]; then
    echo "Downloading annotated datasets"
    gdown https://drive.google.com/uc?id=1GkSgtiiX7BG5LygBq3I0HKRRGEBQ7_Lz -O test.npy 
    gdown https://drive.google.com/uc?id=1oIPGaplji5jgn3qtlm_HE8lL5HTpeHXl -O train.npy                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
    gdown https://drive.google.com/uc?id=1IhDxuD3jhhXwapeEOBmCgqcp4iFc_nWG -O valid.npy
else
    echo "Downloading normal text datasets"
    gdown https://drive.google.com/uc?id=19dk3ITChA7wKHJS_eSbzxad1DtIQ1dCx -O test.npy
    gdown https://drive.google.com/uc?id=1jMSuZvHFTYdFdtmUclqy3X-jIXVNrmZo -O train.npy
    gdown https://drive.google.com/uc?id=1tsz-xXeFCOa6b9JK8h6nt6yTrZru9oER -O valid.npy
fi

cd ../Ground_truth

echo "Downloading Grouth truth datasets"
gdown https://drive.google.com/uc?id=15z0lWO2kUR8irIyzV5g3yn9wv2SaoRx0 -O test.tsv
gdown https://drive.google.com/uc?id=1hTS76X6S_slnZZoZRBmlpYqq6T3vEiWF -O train.tsv
gdown https://drive.google.com/uc?id=1FFXIH70kPKtwhtF7TvTQ7ue3M0zGSnuZ -O valid.tsv

echo "Downloaded datasets"