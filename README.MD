### 1. Концепция и структура  

win-builder позволяет в автоматическом режиме собирать облачные образы Windows на Linux хостах, используя Qemu/KVM.  
В основе лежат:  
1. Базовый ISO образ Windows  
2. Элементы использующие PowerShell  
3. Описание образа в виде конфига  
4. Скрипты для запуска и автоматизации сборки.  

### 2. Делаем свой образ  
При работе "с нуля" необходимо:  
1. Залить ISO образ в папку /ISO  
2. Добавить нужные элементы в /elements  
3. По шаблону набросать конфиг образа:  
```
[SETTINGS]
	#Полное имя образа. Используется при выгрузке в OpenStack. %date пока единственная доступная переменная
osName=Windows Server 2025 Standard RU ($date) - GameReady Driver
    #Короткое имя без пробелов и специальных символов, запрещенных в файловой системе. Будет использоваться как уникальное имя конечного файла и точки монтирования
name=win25stru_game
	#Модуль для сборки. Если планируется использовать в одном режиме всегда - лучше указать в scripts/winbuilder.conf
builder=virt_win
	#Модуль для выгрузки. Так же лучше указать в scripts/winbuilder.conf в секции [DEFAULTS], если не планируется часто изменять
uploader=glance
    #Путь, по которому будет сохранен файл образа
pathSave=/opt/client-resources
    #Путь к оригинальному ISO образу Windows
pathIso=./ISO/win25ru.iso
    #Опционально: Путь к Unnatend.xml который будет использован для старта Audit Mode при первом запуске сборки 
pathUnattend=./elements/windows_general/unnatend/2025.xml
	#Опционально: Путь к оверлею WinPE, который будет развернут поверх чистого WinPE образа. 
        #             Планируется убрать и генерировать оверлей автоматически в зависимости от параметров разделов.
pathWinPE=./scripts/resources/winpe
	#Название редакции Windows так же, как указано в архиве WIM
editionName=Windows Server 2025 SERVERSTANDARD
    #Размер образа используемый на стадии сборки.
buildSize=50G
    #Опционально: Если указан, то при сборке будет работать spice на указанном порте
spicePort=5920
	#Опционально: Можем указать дополнительные параметры для QEMU на стадии WinPE. Полезно для WinServer 2025.
winPeQemuCmdline=-cpu Skylake-Client-v3
	#Опционально: Таймаут сборки в секундах. Полезно при шансе зависания установки какого-либо пакета или ОС. Если не указан применяется таймаут указанный в winbuilder.conf, либо 30000 секунд.
buildTimeout=20000
    #Список элементов для установки в виде путей
[ELEMENTS] 
./elements/general.d/windows_general
./elements/general.d/cloudbase-init
./elements/general.d/nv-gameready
./elements/general.d/virtio
./elements/general.d/geforceexp
./elements/general.d/baremetaldrv
./elements/general.d/non-existing

    #Опционально: Экспорт перемеенных окружения в сборочное окружение.
[EXPORTS]
TESTVAR=123

    #Параметры разделов. Можно указать любое число, но:
    #1. buildSize распространяется только на размер последнего раздела на стадии сборки.
    #   Другие разделы не изменят своего размера. Позже исправим на ресайз указанного системного раздела.
    #2. После точки указывается имя. На этом примере будет создано два раздела с именами BOOT и SYSTEM
[PARTITION.BOOT]
size=100M
filesystem=fat32
#Полный список флагов доступен по ссылке: https://github.com/dcantrell/pyparted/blob/main/src/parted/__init__.py#L159
flags=PARTITION_MSFT_RESERVED;PARTITION_BOOT

[PARTITION.SYSTEM]
size=25500M
filesystem=ntfs
	#Параметр system ниже указывает, на какой раздел будет устаовлен Windows.
system=true
```
4. Запустить ```./scripts/buildImage.py ./path/to/windows.config``` скрипт с указанием конфига образа. Сборка началась.  
5. Через SPICE клиенты можем подключиться по указанному в spicePort порту. Отлавливаем некорректное поведение, отлаживаем элементы.  
6. Образ собран и залит. Можно тестировать на серверах.  

### 3. Быстрая сборка из готовых  
Все готовые конфиги образов лежат в /images/ каталоге. Запустить можно следующим образом:  
```
cd <корень репозитория>/
sudo ./scripts/buildImage.py ./images/base/2022StandardRu_gameready.conf
```
И по желанию ручной аплоад. Образ и так будет залит, если указаны переменные окружения (openstack.rc) для подключения к OpenStack:  
```
openstack image create --container-format bare --disk-format raw  --file ./result/win10.raw --private --property hw_disk_bus=virtio --property hw_rescue_device=disk --property hw_rescue_bus=virtio --property os_type=windows --property hw_video_model=cirrus --property hw_firmware_type=uefi --property hw_machine_type=pc-q35-focal-hpb --progress "Windows 10 RU (May 2024) - GameReady Driver"
```

### 4. Разработка элементов  
Элемент - это единица изменений. Представляет собой каталог с необходимыми скриптами и программами. При указании элемента содержимое копируется в образ и выполняется на стороне виртуальной машины. Скрипты пишутся на PowerShell или CMD. PS предпочтительнее.  

Базовая структура элемента, в порядке выполнения:  
```
/elements/<название элемента>/prerun <-- Выполнение скриптов перед запуском машины
/elements/<название элемента>/configure <-- Преднастройка
/elements/<название элемента>/install <-- Установка программ
/elements/<название элемента>/clean <-- Этап очистки перед sysprep
/elements/<название элемента>/root <-- Копируется целиком в корень диска C:/.  
/elements/<название элемента>/version.txt <-- Версия пакета и опционально имя. При отсутствии версия будет 'none'
```

В каталоги раскладываются PS скрипты, которые будут выполнять действия по настройке и установке программ и ОС.   

В каталог `/elements/<название элемента>/root` стоит добавлять различные исполняемые файлы, либо файлы, накладываемые на диск C:/. Например, `/elements/<название элемента>/root/testfolder/testfile.txt` на хосте будет выглядеть как `C:/testfolder/testfile.txt`.  

В prerun директории можно добавить bash скрипты, которые будут выполнены после монтирования системной ФС и перед копированием элементов. Может подойти для скачивания дистрибутивов программ и драйверов до запуска машины, обновления version.txt или других действий.
Для prerun скриптов доступны следующие переменные:  
```
$WCB_PATH_SYSPART - Путь точки монтирования системного раздела образа (Диск с Windows, проще говоря) 
$WCB_PATH_ELEMENT - Путь в системе к элементу
$WCB_PATH_ISO - Путь точки монтирования исходного ISO образа Windows
```

Для элементов доступны следующие дочерние функции с примерами:  
Вывод в лог timestamp + stdout + serial:  
```
logInfo "Installing GameReady Driver"
```
Проверить необходимость перезагрузки и перезагрузиться при необходимости:  
```
checkReboot
```

Установить драйверы из каталога рекурсивно. В примере будут установлены все .inf и .cat, которые содержат "2022" в полном пути:  
```
installDrivers -path_drv "C:/my/drivers/folder" -filter "*2022*"
```

### 5. Модульность:  
Модули алгоритмов сборки доступны в `./scripts/builders`   
Модули выгрузки образов сборки в `./scripts/uploaders`  
Модули интеграций доступны в `./scripts/integrations`  
