# Частые проблемы и их решения, полезные ссылки

## Полезные ссылки:

* [Предложения по улучшению VIP и идеи для модулей](http://hlmod.ru/threads/predlozhenija-po-uluchsheniju-vip-i-idei-dlja-modulej.26407/)
* Хотите помочь с переводом на другие языки? [[VIP] Core](http://translator.mitchdempsey.com/sourcemod_plugins/265), [[VIP] Modules](http://translator.mitchdempsey.com/sourcemod_plugins/272)
* [Как обновить модуль для последней версии ядра?](https://github.com/R1KO/VIP-Core/blob/master/update_modules.md) (TODO: move to docs)
* ~~[Простой, безболезненный и автоматизированный перенос БД из SQLite в MySQL, и наоборот](https://hlmod.ru/threads/vip-core.37613/page-41#post-352843)~~
* [Обновление с VIP Core 2.х до 3.0](https://hlmod.ru/threads/vip-core.37613/page-46#post-368144)
* [Самая новая версия перевода модулей](https://hlmod.ru/resources/vip-translations-vip-module.938/)

## Частые проблемы и их решения

№ | Проблема | Решение
------------ | -------------
1 | "No groups available" или "Нет доступных групп" в админ меню при попытке выдать VIP-статус игроку | Файл `groups.ini `нужно сохранить в кодировке `UTF-8 (Без BOM)` и проверить что правильно открыты и закрыты все скобки и кавычки `{}`, `"val"`
2 | "No available features" или "Нет доступных привилегий" в VIP-меню | Не установлены модули либо смотреть пункт 1
3 | "No access" или "Нет доступа" в VIP-меню | Не прописан параметр модуля в группу файле `groups.ini` либо смотреть пункт 1
4 | `Native "FormatEx" reported: Language phrase "Имя фразы" not found` | Отсутствуют фразы в переводе. Обратите внимание на `"Имя фразы"` и добавьте её в файл перевода модулей
5 | VIP-меню ведет себя странно, пропадают пункты, всё смещается | Смотрите пункт 4
6 | Ошибка в логе: `[SM] Exception reported: Plugin handle 550055 is invalid (error 3)` | Перезагружаете/выгружаете/загружаете какой-то не обновленный модуль, проверьте наличие обновлений для перезагружаемых модулей
7 | `Native "VIP_RegisterFeature" reported: Feature "Имя модуля" already defined !` | Модуль установлен несколько раз (либо несколько разных версий либо в разных папках)
8 | `Native "VIP_SetClientVIP" reported: Invalid group (test_vip)` | Некорректная группа в файле `cfg/vip/vip_test.cfg` укажите свою группу там которая есть в `groups.ini` или создайте её
9 | `KeyValues Error: RecursiveLoadFromBuffer: got } in key in file addons/sourcemod/data/vip/cfg/groups.ini` | Забыли добавить скобку в файле `groups.ini`, проверьте все ли кавычки и скобки присутствуют и нет ли лишних, смотрите пункт 1
10 | Админ-меню ведет себя странно, открываются не те пункты меню, которые выбираешь | Решение проблемы №10
11 | Проблема | Решение



### Решение проблемы №10
В `addons/sourcemod/configs/adminmenu_sorting.txt` добавьте
```
"vip_admin"
{
    "item"        "add_vip"
    "item"        "edit_vip"
    "item"        "del_vip"
    "item"        "list_vip"
    "item"        "reload_vip_players"
    "item"        "reload_vip_cfg"
}
```
