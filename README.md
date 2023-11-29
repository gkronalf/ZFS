# Практические навыки работы с ZFS  
  
1. Подготовка тестового стенда  
используя Vagrantfile и команду vagrant up создал виртуальную машину с дополнительными дисками  
подключился к терминалу тестового стенда с помощью команды vagrant ssh

2. Определение алгоритма с наилучшим сжатием
проверил наличия достаточного количесива дисков  
создал файловую систему ZFS на 4-х блочнйх устройствах  
[root@zfs ~]# zpool create zpool_m1 mirror /dev/sdb /dev/sdc  
[root@zfs ~]# zpool create zpool_m2 mirror /dev/sdd /dev/sde  
[root@zfs ~]# zpool create zpool_m3 mirror /dev/sdf /dev/sdg  
[root@zfs ~]# zpool create zpool_m4 mirror /dev/sdh /dev/sdi  
задал метод компресси для каждого пула  
[root@zfs ~]# zfs get all | grep compression  
zpool_m1  compression           lzjb                   local  
zpool_m2  compression           lz4                    local  
zpool_m3  compression           gzip-9                 local  
zpool_m4  compression           zle                    local  
скачал один и тот же текстовый файл во все пуллы  
проверил проверил сколько места занимает один и тот же файл   
[root@zfs ~]# zpool list
NAME       SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT  
zpool_m1   480M  21.7M   458M        -         -     0%     4%  1.00x    ONLINE  -  
zpool_m2   480M  17.7M   462M        -         -     0%     3%  1.00x    ONLINE  -  
zpool_m3   480M  10.9M   469M        -         -     0%     2%  1.00x    ONLINE  -  
zpool_m4   480M  39.3M   441M        -         -     0%     8%  1.00x    ONLINE  -  
исходя из полученной информации можно сделать вывод, что самый эфективный метод сжатия gzip-9   
[root@zfs ~]# zfs list  
NAME       USED  AVAIL     REFER  MOUNTPOINT  
zpool_m1  21.7M   330M     21.6M  /zpool_m1  
zpool_m2  17.7M   334M     17.6M  /zpool_m2  
**zpool_m3  10.8M   341M     10.7M  /zpool_m3**  
zpool_m4  39.2M   313M     39.1M  /zpool_m4  
[root@zfs ~]# zfs get all | grep compressratio | grep -v ref  
zpool_m1  compressratio         1.81x                  -  
zpool_m2  compressratio         2.22x                  -  
**zpool_m3  compressratio         3.65x                  -**  
zpool_m4  compressratio         1.00x                  -  
  
3. 

 
