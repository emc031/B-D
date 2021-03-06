#!/bin/bash

dir=correlators/set2_th1.10/
theta=1.1

python extract/extract_milc_corrs.py ${dir}/*_Ds.ll > out_milc
python extract/to_gpl.py 'Ds.ll_th'${theta} > Ds_th$theta.gpl

python extract/extract_milc_corrs.py ${dir}/*_Ds.le > out_milc
python extract/to_gpl.py 'Ds.le_th'${theta} >> Ds_th$theta.gpl

python extract/extract_milc_corrs.py ${dir}/*_Ds.el > out_milc
python extract/to_gpl.py 'Ds.el_th'${theta} >> Ds_th$theta.gpl

python extract/extract_milc_corrs.py ${dir}/*_Ds.ee > out_milc
python extract/to_gpl.py 'Ds.ee_th'${theta} >> Ds_th$theta.gpl

python extract/extract_milc_corrs.py ${dir}/*_etac.ll > out_milc
python extract/to_gpl.py 'etac_th'${theta} > etac_th$theta.gpl

python extract/extract_milc_corrs.py ${dir}/*_kaon.ll > out_milc
python extract/to_gpl.py 'pseudopi_th'${theta} > pseudopi_th$theta.gpl

rm out_milc