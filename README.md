# Практические навыки работы с ZFS  
  
1. ### Подготовка тестового стенда  
используя Vagrantfile и команду vagrant up создал виртуальную машину с дополнительными дисками  
подключился к терминалу тестового стенда с помощью команды vagrant ssh
  
2. ### Определение алгоритма с наилучшим сжатием  
проверил наличия достаточного количества дисков  
создал файловую систему ZFS на 4-х блочнйх устройствах  
  
    [root@zfs ~]# zpool create zpool_m1 mirror /dev/sdb /dev/sdc  
    [root@zfs ~]# zpool create zpool_m2 mirror /dev/sdd /dev/sde  
    [root@zfs ~]# zpool create zpool_m3 mirror /dev/sdf /dev/sdg  
    [root@zfs ~]# zpool create zpool_m4 mirror /dev/sdh /dev/sdi  
  
задал метод компрессии для каждого пула  
  
    [root@zfs ~]# zfs get all | grep compression  
    zpool_m1  compression           lzjb                   local  
    zpool_m2  compression           lz4                    local  
    zpool_m3  compression           gzip-9                 local  
    zpool_m4  compression           zle                    local  
  
скачал один и тот же текстовый файл во все пулы  
проверил проверил сколько места занимает один и тот же файл  
  
    [root@zfs ~]# zpool list  
    NAME       SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT  
    zpool_m1   480M  21.7M   458M        -         -     0%     4%  1.00x    ONLINE  -  
    zpool_m2   480M  17.7M   462M        -         -     0%     3%  1.00x    ONLINE  -  
    zpool_m3   480M  10.9M   469M        -         -     0%     2%  1.00x    ONLINE  -  
    zpool_m4   480M  39.3M   441M        -         -     0%     8%  1.00x    ONLINE  -  
  
исходя из полученной информации можно сделать вывод, что самый эффективный метод сжатия gzip-9  
  
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
  
3. ### Определение настроек пула  
скачал архив и разархивировал его в домашний каталог  
проверил возможно ли импортировать данный каталог в пул  
  
    [root@zfs ~]# zpool import -d zpoolexport/  
      pool: otus  
      id: 6554193320433390805  
      state: ONLINE  
      action: The pool can be imported using its name or numeric identifier.  
      config:  
        otus                         ONLINE  
          mirror-0                   ONLINE  
            /root/zpoolexport/filea  ONLINE  
            /root/zpoolexport/fileb  ONLINE  
  
вывод показывает имя пула, тип raid, и его состав  
далее сделал импорт данного пула в ОС  
  
    [root@zfs ~]# zpool import -d zpoolexport/ otus  
    [root@zfs ~]# zpool status  
     pool: otus  
     state: ONLINE  
     scan: none requested  
     config:  
        NAME                         STATE     READ WRITE CKSUM  
        otus                         ONLINE       0     0     0  
          mirror-0                   ONLINE       0     0     0  
            /root/zpoolexport/filea  ONLINE       0     0     0  
            /root/zpoolexport/fileb  ONLINE       0     0     0  
  
    errors: No known data errors  
  
получаем параметры пула  
  
    [root@zfs ~]# zfs get available otus  
    NAME  PROPERTY   VALUE  SOURCE  
    otus  available  350M   -  
  
    [root@zfs ~]# zfs get readonly otus  
    NAME  PROPERTY  VALUE   SOURCE  
    otus  readonly  off     default  
  
    [root@zfs ~]# zfs get recordsize otus  
    NAME  PROPERTY    VALUE    SOURCE  
    otus  recordsize  128K     local  
  
    [root@zfs ~]# zfs get compression otus  
    NAME  PROPERTY     VALUE     SOURCE  
    otus  compression  zle       local  
  
    [root@zfs ~]# zfs get checksum otus  
    NAME  PROPERTY  VALUE      SOURCE  
    otus  checksum  sha256     local  
  
4. Работа со снапшотом, поиск сообщения от преподавателя  
скачал файл указанный в задании  
  
восстановил файловую систему из снапшота  
  
    [root@zfs ~]# zfs receive otus/test@today < otus_task2.file  
  
далее нашел в каталоге файл с именем "secret_message" и посмотрел содержимое файла  
    [root@zfs ~]# find /otus/test/ -name "secret_message"  
    /otus/test/task1/file_mess/secret_message  
    [root@zfs ~]# cat /otus/test/task1/file_mess/secret_message  
    https://github.com/sindresorhus/awesome  
  
в файле обнаружил ссылку на репозиторий GitHub  
[в текущих реалиях содержимое данного репозитория подпадает под статьи 280.3, 275 УК РФ](https://ria.ru/20220322/pomosch-1779389662.html)