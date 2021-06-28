# Установка и настройка модулей

[<- К содержанию](../index.md)

> Все файлы сохраняйте в кодировке UTF-8 Без BOM Редактором [Notepad++](https://notepad-plus-plus.org/download/)

1. Скачать архив с файлами модуля
2. Распаковать архив и разложить файлы по папкам на сервере.
3. Добавить фразы модуля в файл перевода модулей `addons/sourcemod/translations/vip_modules.phrases.txt` (Написано в описании к каждому модулю. Если отсутствует - пропустите этот пункт)
4. Настроить конфиг модуля. Находится в `addons/sourcemod/data/vip/modules/`  (Написано в описании к каждому модулю. Если отсутствует - пропустите этот пункт)
5. Прописать нужным VIP-группам параметры (`addons/sourcemod/data/vip/cfg/groups.ini`), которые добавляет модуль. (Написано в описании к каждому модулю. Если отсутствует - пропустите этот пункт)
6. После запуска модуля, будет создан конфиг. Находится в `cfg/vip/` (Написано в описании к каждому модулю. Если отсутствует - пропустите этот пункт)


## Пример установки модуля

Установим модуль [[VIP] Respawn](https://hlmod.ru/resources/vip-respawn.221/) следуя инструкции:


1. Качаем файлы модуля ![download module](/images/install-modules/download_module.png)
2. Распаковываем архив и раскладываем файлы по папкам на сервере.
3. Добавляем фразы модуля в файл перевода модулей `addons/sourcemod/translations/vip_modules.phrases.txt`: ![vip_modules_phrases](/images/install-modules/vip_modules_phrases.png)  ![vip_modules_phrases](/images/install-modules/vip_modules_phrases2.png)
4. Настроить конфиг модуля - *Пропускаем т.к. про это ничего не сказано*
5. Прописать нужным VIP-группам параметры: ![groups_features](/images/install-modules/groups_features.png)  ![groups_features](/images/install-modules/groups_features2.png)
6. После запуска модуля, будет создан конфиг - *Пропускаем т.к. про это ничего не сказано*
7. Теперь перезапускаем сервер или меняем карту (не забываем сделать **sm_reload_translations** если меняли файл переводов) и насладжаемся
