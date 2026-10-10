# AGENTS.md

[VIP] Core — SourceMod (SourcePawn) plugin that grants players VIP status (timed or permanent). Extended by separate "module" plugins via natives/forwards. No tests; correctness = clean compile.

## Build
- CI (`.github/workflows/build.yml`) compiles against SM 1.10 and 1.11 (must pass) and 1.12 (allowed to fail):
  `cd addons/sourcemod/scripting && mkdir -p ../plugins && spcomp VIP_Core.sp -E -o ../plugins/VIP_Core.smx -i./include`
- `-E` = warnings are errors. Fix every warning, including deprecation ones. SM 1.10 is the strictest parser (e.g. missing `;`), so code must build there too.
- Alt: `sourceknight build` (`sourceknight.yaml`, SM 1.13). It ignores spcomp's exit code — check output for `error`.
- Never commit `*.smx`, `plugins/`, `.sourceknight`.

## Git
- `dev` is the integration branch: branch from `dev`, merge back into `dev`. `master` is for releases.
- LF line endings only (enforced by `.gitattributes`); don't introduce CRLF.

## Layout
- `scripting/VIP_Core.sp` — entry point; `#include`s every `vip/*.sp` into ONE compilation unit (order matters: Global → Debug → ... → API → CMD → Clients). New file = add `#include` there.
- Compile-time switches in `VIP_Core.sp`: `DEBUG_MODE`, `USE_ADMINMENU` (gates `AdminMenu.sp` + `vip/adminmenu/*`), `USE_MORE_SERVERS`.
- `vip/Global.sp` — all globals, macros (`SZF`, `UID/CID`, `SET_BIT/UNSET_BIT`), client flag bits (`IS_VIP`, `IS_LOADED`, ...), core state bits (`IS_STARTED`, `IS_MySQL`, `IS_LOADING`).
- `vip/API.sp` — forwards (`API_SetupForwards`, `CreateForward_*`) and natives (`AskPluginLoad2`, `RegNative(X)` → `VIP_X` bound to `Native_X`).
- `vip/Database.sp` — connection, schema, queries. `UTIL.sp` — shared helpers; check here before writing new ones.
- `vip/Clients.sp` — client load/unload lifecycle, spawn handling. `Features.sp` — feature registry.
- `include/vip_core.inc` — PUBLIC API for third-party modules.
- `data/vip/cfg/*.ini` — runtime configs (groups, info, sort_menu, times). `translations/vip_core.phrases.txt` — all user-facing strings.

## Public API rules (vip_core.inc)
- Third-party modules depend on it: never change existing native/forward signatures or semantics. Add new params with defaults or add new natives.
- New native: implement `Native_X` in API.sp, `RegNative(X)` in `AskPluginLoad2`, declare in `.inc`, add `MarkNativeAsOptional("VIP_X")` in `__pl_vip_core_SetNTVOptional`.
- New forward: `static GlobalForward` field + `new GlobalForward(...)` in `API_SetupForwards` + `CreateForward_*` wrapper + `forward` declaration with doc comment in `.inc`.
- Deprecate via `#pragma deprecated`, don't delete (see `update_modules.md`).

## Database
- Config name `vip_core` in databases.cfg → MySQL; otherwise falls back to local SQLite. Every query must work on BOTH.
- Schemas differ: MySQL has `sid` column (PK `account_id, sid`), SQLite has no `sid`. Use `g_szSID` (empty on SQLite) when filtering by server.
- MySQL uses `utf8mb4`. Escape user strings with `g_hDatabase.Escape`. All queries are async (`g_hDatabase.Query` + callback); check `szError` in callbacks.
- Players are keyed by `account_id` (SteamID AccountID), not userid/client index.

## Conventions
- `#pragma semicolon 1`, `#pragma newdecls required`. Tabs. Hungarian-ish names: `iClient`, `szName`, `hMenu`, `bFlag`, globals `g_*`, cvars `g_CVAR_*`.
- Pass client across async boundaries as userid (`UID`/`CID`), never raw index.
- `GLOBAL_TRIE` / `GLOBAL_INFO` are index `[0]` of per-client arrays — slot 0 = global, not a player.
- Use methodmaps (`StringMap`, `Cookie`, `KeyValues`, `delete`), not legacy procedural calls (`CreateTrie`, `SetClientCookie`, `CloseHandle`, `Kv*`).
- Debug logging via `DBG_*` / `DebugMessage` functions from `Debug.sp` (empty unless `DEBUG_MODE 1`); calls still need a trailing `;`.
- Any new user-facing text → new phrase in `vip_core.phrases.txt` with at least `en` and `ru`.
- Comments and cvar descriptions are mostly Russian; either language is fine, keep the surrounding style.
- Bump `VIP_VERSION` in `VIP_Core.sp` only when asked; changelog lives in `updates.md`.
