# Частые проблемы и их решения, полезные ссылки

## Полезные ссылки:

* [Предложения по улучшению VIP и идеи для модулей](http://hlmod.ru/threads/predlozhenija-po-uluchsheniju-vip-i-idei-dlja-modulej.26407/)
* Хотите помочь с переводом на другие языки?[[VIP] Core](http://translator.mitchdempsey.com/sourcemod_plugins/265), [[VIP] Modules](http://translator.mitchdempsey.com/sourcemod_plugins/272)
* [Как обновить модуль для последней версии ядра?](https://github.com/R1KO/VIP-Core/blob/master/update_modules.md) (TODO: move to docs)
* ~~[Простой, безболезненный и автоматизированный перенос БД из SQLite в MySQL, и наоборот](https://hlmod.ru/threads/vip-core.37613/page-41#post-352843)~~
* [Обновление с VIP Core 2.х до 3.0](https://hlmod.ru/threads/vip-core.37613/page-46#post-368144)
* [Самая новая версия перевода модулей](https://hlmod.ru/resources/vip-translations-vip-module.938/)

## Частые проблемы и их решения

№ | Проблема | Решение
------------ | -------------
№ | Проблема | Решение
№ | Проблема | Решение
№ | Проблема | Решение


1. > "No groups available" или "Нет доступных групп"

**Ответ:** Файл `groups.ini `нужно сохранить в кодировке `UTF-8 (Без BOM)`

2. > "No available features" или "Нет доступных привилегий"

**Ответ:** Не установлены модули либо смотреть пункт 1

3. > "No access" или "Нет доступа" в VIP-меню

**Ответ:** Не прописан параметр модуля в группу файле `groups.ini`

4. > Native "VIP_RegisterFeature" reported: Feature "Имя модуля" already defined !
**Ответ:** Модуль установлен несколько раз (либо несколько разных версий либо в разных папках)[/SPOILER]
5. Native "FormatEx" reported: Language phrase "Имя фразы" not found
**Ответ:** Отсутствуют фразы в переводе. Обратите внимание на "Имя фразы" и добавьте её[/SPOILER]
6. VIP-меню ведет себя странно, пропадают пункты, всё смещается.
**Ответ:** Смотрите пункт 5[/SPOILER]
7. Native "reported: Translation string formatted incorrectly - missing at least 2 parameters
**Ответ:** аменить файл перевода в translations папке на оригинальный файл с архива Core 1.1.3, Core 1.1.4 и Core 2.0.0[/SPOILER]
8. KeyValues Error: RecursiveLoadFromBuffer: got } in key in file addons/sourcemod/data/vip/cfg/groups.ini
**Ответ:** Забыли добавить скобку в файле groups.ini[/SPOILER]
9. Если всё верно но проблемы остались либо другие проблемы
**Ответ:** Проверьте целосность структуры конфигов, все ли кавычки и скобки присутствуют и нет ли лишних.[/SPOILER]
10. Native "VIP_SetClientVIP" reported: Invalid group (test_vip)
**Ответ:** Некорректная группа в файле cfg/vip/vip_test.cfg укажите свою группу там которая есть в groups.ini[/SPOILER]
11. Админ-меню ведет себя странно, открываются не те пункты меню, которые выбираешь
**Ответ:** 
В [B][I]addons/sourcemod/configs/adminmenu_sorting.txt[/I][/B] добавьте
[code]
   "vip_admin"
   {
       "item"        "add_vip"
       "item"        "edit_vip"
       "item"        "del_vip"
       "item"        "list_vip"
       "item"        "reload_vip_players"
       "item"        "reload_vip_cfg"
   }[/code][/SPOILER]
   
12. Ошибка в логе:

> L 06/28/2021 - 11:34:46: [SM] Exception reported: Plugin handle 550055 is invalid (error 3)
> L 06/28/2021 - 11:34:46: [SM] Blaming: vip/VIP_Core.smx
> L 06/28/2021 - 11:34:46: [SM] Call stack trace:
> L 06/28/2021 - 11:34:46: [SM]   [0] Call_StartFunction
> L 06/28/2021 - 11:34:46: [SM]   [1] Line 221, vip/VipMenu.sp::Handler_VIPMenu
> ...

**Ответ:** Перезагружаете/выгружаете/загружаете какой-то не обновленный модуль.
