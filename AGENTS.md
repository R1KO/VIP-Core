# AGENTS.md

[VIP] Core — SourceMod (SourcePawn) plugin that grants players VIP status (timed or permanent). Extended by separate "module" plugins via natives/forwards. No tests; correctness = clean compile.

## Build
- CI (`.github/workflows/build.yml`) compiles against SM 1.10 and 1.11 (must pass) and 1.12 (allowed to fail):
  `cd addons/sourcemod/scripting && mkdir -p ../plugins && spcomp VIP_Core.sp -E -o ../plugins/VIP_Core.smx -i./include`
- `-E` = warnings are errors. Fix every warning, including deprecation ones. SM 1.10 is the strictest parser (e.g. missing `;`), so code must build there too.
- Alt: `sourceknight build` (`sourceknight.yaml`, SM 1.13). It ignores spcomp's exit code — check output for `error`.
- Never commit `*.smx`, `plugins/`, `.sourceknight`.
- Git: `dev` is the integration branch: branch from `dev`, merge back into `dev`. `master` is for releases. LF line endings only (`.gitattributes`).

## Layout
- `scripting/VIP_Core.sp` — entry point; `#include`s every `vip/*.sp` into ONE compilation unit (order matters: Global → Debug → ... → API → CMD → Clients). New file = add `#include` there.
- Compile-time switches in `VIP_Core.sp`: `DEBUG_MODE`, `USE_ADMINMENU` (gates `AdminMenu.sp` + `vip/adminmenu/*`), `USE_MORE_SERVERS`, `USE_CLIENTPREFS` (toggle statuses in cookies vs `vip_storage`; status I/O only via `Features_GetSavedStatus`/`Features_SaveStatus`).
- `vip/Global.sp` — all globals, macros (`SZF`, `UID/CID`, `SET_BIT/UNSET_BIT`), client flag bits (`IS_VIP`, `IS_LOADED`, ...), core state bits (`IS_STARTED`, `IS_MySQL`, `IS_LOADING`).
- `vip/API.sp` — forwards (`API_SetupForwards`, `CreateForward_*`) and natives (`AskPluginLoad2`, `RegNative(X)` → `VIP_X` bound to `Native_X`).
- `vip/Database.sp` — connection, schema, queries. `UTIL.sp` — shared helpers; check here before writing new ones. `Clients.sp` — client load/unload lifecycle, spawn. `Features.sp` — feature registry.
- `include/vip_core.inc` — PUBLIC API for third-party modules. `data/vip/cfg/*.ini` — runtime configs (groups, info, sort_menu, times). `translations/vip_core.phrases.txt` — all user-facing strings.

## Public API rules (vip_core.inc)
- Third-party modules depend on it: never change existing native/forward signatures or semantics. Add new params with defaults or add new natives. Deprecate via `#pragma deprecated`, don't delete (see `docs/update_modules.md`).
- New native: implement `Native_X` in API.sp, `RegNative(X)` in `AskPluginLoad2`, declare in `.inc`, add `MarkNativeAsOptional("VIP_X")` in `__pl_vip_core_SetNTVOptional`.
- New forward: `static GlobalForward` field + `new GlobalForward(...)` in `API_SetupForwards` + `CreateForward_*` wrapper + `forward` declaration with doc comment in `.inc`.

## Database
- Config name `vip_core` in databases.cfg → MySQL; otherwise falls back to local SQLite. Every query must work on BOTH.
- Schemas differ: MySQL has `sid` column (PK `account_id, sid`), SQLite has no `sid`. Use `g_szSID` (empty on SQLite) when filtering by server.
- MySQL uses `utf8mb4`. Escape user strings with `g_hDatabase.Escape`. All queries are async (`g_hDatabase.Query` + callback); check `szError` in callbacks.
- Players are keyed by `account_id` (SteamID AccountID), not userid/client index. Never store data under `account_id` 0 (unauthorized client).
- `vip/Storage.sp` — per-player key/value cache over `vip_storage` (filtered by `sm_vip_storage_id` on MySQL), loaded on connect, written on disconnect.

## Code style (new/changed code; legacy deviations are not a reason to copy them)
- `#pragma semicolon 1`, `#pragma newdecls required`. Tabs, no trailing whitespace. Allman braces, always braced, also single-statement `if`/`for` and `case` bodies (`case MenuAction_End: delete hMenu;` is the only one-liner).
- Space after keywords: `if (`, `for (`, `while (`, `switch (`. `++i` in loops. `!bFlag`, not `bFlag == false`. Buffers: `SZF(szBuf)`, not `szBuf, sizeof(szBuf)`; `FormatEx` unless formatting a buffer into itself.
- Names: locals/params Hungarian `iClient`, `szName`, `hMenu`, `bFlag`, `fTime`, `eStatus`; globals `g_` + prefix (`g_hDatabase`, `g_szSID`), cvars `g_CVAR_*`; macros/consts `UPPER_SNAKE`, StringMap keys `KEY_*` / `DATA_KEY_*`.
- Functions: `PascalCase` with file prefix: `Clients_*`, `Features_*`, `Storage_*`, `DB_*`, `UTIL_*`, `API_*`. Callbacks: `SQL_Callback_*`, `SQL_TxnCallback_*`, `Timer_*`, `MenuHandler_*`, `Event_*`; commands `*_CMD`; natives `Native_*`; forward wrappers `CreateForward_*`.
- SQL: backticks around identifiers, single quotes for values, trailing `;`, user strings via `g_hDatabase.Format`/`Escape`. Callbacks: `if (hResult == null || szError[0]) { LogError("<Callback>: %s", szError); return; }`, free the DataPack on every path.
- File-private state/helpers are `static`. Never pass already formatted text as a format string: `PrintToServer("%s", szMsg)`, not `PrintToServer(szMsg)`.

## Comments
- Explain *why*, never restate *what* the code does. A comment doesn't excuse unclear code: rename/restructure first; if a clear comment is hard to write, the code is the problem.
- Comment what a reader would trip over: unidiomatic code, SourceMod quirks, ordering constraints, odd-looking bug fixes. Mark unfinished parts `// TODO: <what and why>`. Link the source of copied code and external refs (SM docs, AlliedModders) where they help.

## Conventions
- Pass client across async boundaries as userid (`UID`/`CID`), never raw index.
- `GLOBAL_TRIE` / `GLOBAL_INFO` are index `[0]` of per-client arrays — slot 0 = global, not a player.
- Use methodmaps (`StringMap`, `Cookie`, `KeyValues`, `delete`), not legacy procedural calls (`CreateTrie`, `SetClientCookie`, `CloseHandle`, `Kv*`).
- Debug logging via `DBG_*` / `DebugMessage` functions from `Debug.sp` (empty unless `DEBUG_MODE 1`); calls still need a trailing `;`.
- English only in code, comments, cvar descriptions, log/error strings and docs. Other languages live only in `translations/*.phrases.txt` and the per-language values of `data/vip/cfg/*.ini`. Any new user-facing text → new phrase in `vip_core.phrases.txt` with at least `en` and `ru`. Bump `VIP_VERSION` in `VIP_Core.sp` only when asked; changelog lives in GitHub Releases (release notes).
