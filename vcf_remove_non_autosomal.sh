awk '/^#/ { print /bin/bash }  ~ /^[0-9]+$/ {print /bin/bash}' CFA_6468.g.vcf > CFA_6468.autosomes.g.vcf
