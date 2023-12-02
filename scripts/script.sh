#!/bin/bash
zpool create zpool_m1 mirror /dev/sdb /dev/sdc
zpool create zpool_m2 mirror /dev/sdd /dev/sde
zpool create zpool_m3 mirror /dev/sdf /dev/sdg
zpool create zpool_m4 mirror /dev/sdh /dev/sdi

zfs set compression=lzjb zpool_m1
zfs set compression=lz4 zpool_m2
zfs set compression=gzip-9 zpool_m3
zfs set compression=zle zpool_m4

for i in {1..4}; do wget -P /zpool_m$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done

wget -O archive.tar.gz --no-check-certificate 'https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download' 
tar -xzvf archive.tar.gz

zpool import -d zpoolexport/ otus

wget -O otus_task2.file --no-check-certificate "https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download"
zfs receive otus/test@today < otus_task2.file





