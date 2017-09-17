# Redis Tools

Набор скриптов для управления кластером Redis из личного опыта.

## redis-init

Скрипт для манипуляции инит скриптами кластера: старт, рестарт, т.д.

## redis-restore

- количество нод (и порты) скрипт берет из инит скриптов `/etc/init.d/redis*`
- архив (tar.gz) распаковывается в каталог `/tmp/<same directory>`
- предпологается что в архиве файлы лежат в каталоге `redis/*` (пример: `redis/7000/dump.rdb`)
- каталог кластера распаложен в `/var/lib/redis`

Изначально была задача перенести кластер с одного сервера на другой (на сервере запущено по экземпляру на ядро процессора). Предпологается, что конфигурация сервера таже (если запускать скрипт `redis-trib.rb` так оно и будет), т.е. такое же количество нод, там же конфиги кластера лежат. В общем всё так же, только данные перенести. Для этого нужно файлы RDB скопировать на новый сервер, а в файлах `/var/lib/redis/$REDISPORT/cluster.conf` поменять IP нод.

В этом случае команду нужно запустить так:

```
$ sudo ./redis-restore.sh -a <path to archive> -o <old IP> -n <new IP>
```

Если же нужно восстановить только RDB файлы с данными, то ключи `-o`/`-n` использовать не следует, оставив только `-a`. Шаг с заменой IP будет пропущен.

## redis-backup

Скрипт не имеет ключей запуска.

- количество нод (и порты) скрипт берет из инит скриптов `/etc/init.d/redis*`
- кластер "должен" лежать в каталоге `/var/lib/redis`
- будет создан каталог `/var/opt/redis` (mode: 0700)
- конечное имя архива `redis-cluster-2017-09-17-14-27-32.tar.gz`
- перед выполнением архивации выполняется команда `redis-cli -p <port> save`
