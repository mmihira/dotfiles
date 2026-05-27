local present, ls = pcall(require, "luasnip")
if not present then
  return
end

local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local ai = require("luasnip.nodes.absolute_indexer")
local events = require("luasnip.util.events")
local partial = require("luasnip.extras").partial

local snippets = {
  -- fmt
  ls.s(
    { trig = "fp", name = "fmt::println", dscr = "fmt::println" },
    fmt('spdlog::info("{val} = {ix}", {s});', {
      val = ls.i(1, "val"),
      ix = ls.i(2, "{}"),
      s = ls.i(3, ""),
    })
  ),
  -- c++20 module
  ls.s(
    { trig = "mod", name = "C++20 module", dscr = "C++20 module declaration" },
    fmt(
      [[
module;

{}

export module {};

{}
]],
      {
        ls.i(1, "// global module fragment"),
        ls.i(2, "module_name"),
        ls.i(3, "// module interface"),
      }
    )
  ),
  ls.s(
    { trig = "svcspatial", name = "Get spatialservice from ctx", dscr = "game::getSpatialServiceFromCtx(registry)" },
    fmt("auto &{} = game::getSpatialServiceFromCtx({});", {
      ls.i(1, "spatialSvc"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svcspatialscene", name = "Get spatialservice from ctx by scene", dscr = "game::getSpatialServiceFromCtx(registry, scene)" },
    fmt("auto &{} = game::getSpatialServiceFromCtx({}, {});", {
      ls.i(1, "spatialSvc"),
      ls.i(2, "registry"),
      ls.i(3, "scene"),
    })
  ),
  ls.s(
    { trig = "svcentitybuildingplan", name = "Get entity building plan svc", dscr = "game::getEntityBuildingPlanSvc(registry)" },
    fmt("auto &{} = game::getEntityBuildingPlanSvc({});", {
      ls.i(1, "buildingPlanSvc"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svcentitycustomprop", name = "Get entity registry custom prop svc", dscr = "game::getEntityRegistryCustomPropSvc(registry)" },
    fmt("auto &{} = game::getEntityRegistryCustomPropSvc({});", {
      ls.i(1, "customPropSvc"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svcscript", name = "Get script service from ctx", dscr = "scripting::getScriptServiceFromCtx(registry)" },
    fmt("auto &{} = scripting::getScriptServiceFromCtx({});", {
      ls.i(1, "scriptSvc"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svcentitydefinition", name = "Get entity definition svc", dscr = "game::getEntityDefinitionSvc(registry)" },
    fmt("auto &{} = game::getEntityDefinitionSvc({});", {
      ls.i(1, "entityDefinitionSvc"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svcentitydebug", name = "Get entity debug svc", dscr = "game::getEntityDebugSvc(registry)" },
    fmt("auto &{} = game::getEntityDebugSvc({});", {
      ls.i(1, "entityDebugSvc"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svcsettingstweak", name = "Get settings tweak svc", dscr = "game::getSettingsTweak(registry)" },
    fmt("auto &{} = game::getSettingsTweak({});", {
      ls.i(1, "settingsTweakSvc"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svcentitybuilder", name = "Get entity builder svc", dscr = "game::getEntityBuilderSvc(registry)" },
    fmt("auto &{} = game::getEntityBuilderSvc({});", {
      ls.i(1, "entityBuilderSvc"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svcentitytileset", name = "Get entity registry tileset svc", dscr = "game::getEntityRegistryTileSetSvc(registry)" },
    fmt("auto &{} = game::getEntityRegistryTileSetSvc({});", {
      ls.i(1, "entityRegistryTileSetSvc"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svcmapsave", name = "Get map save svc from ctx", dscr = "game::getMapSaveSvcFromCtx(registry)" },
    fmt("auto &{} = game::getMapSaveSvcFromCtx({});", {
      ls.i(1, "mapSaveSvc"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svcplayerctx", name = "Get player ctx from registry", dscr = "game::getPlayerCtxFromRegistry(registry)" },
    fmt("auto &{} = game::getPlayerCtxFromRegistry({});", {
      ls.i(1, "playerCtx"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svcgamemetrics", name = "Get game metrics svc", dscr = "game::getGameMetrics(registry)" },
    fmt("auto &{} = game::getGameMetrics({});", {
      ls.i(1, "gameMetrics"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svcglobaldll", name = "Get global dll registry from ctx", dscr = "game::getGlobalDllRegistryFromCtx(registry)" },
    fmt("auto &{} = game::getGlobalDllRegistryFromCtx({});", {
      ls.i(1, "globalDllRegistrySvc"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svcdeathregistry", name = "Get death registry from ctx", dscr = "game::getDeathRegistryFromCtx(registry)" },
    fmt("auto &{} = game::getDeathRegistryFromCtx({});", {
      ls.i(1, "deathRegistrySvc"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svcinventory", name = "Get inventory service from ctx", dscr = "game::getInventoryServiceFromCtx(entity, registry)" },
    fmt("auto {} = game::getInventoryServiceFromCtx({}, {});", {
      ls.i(1, "inventorySvc"),
      ls.i(2, "entity"),
      ls.i(3, "registry"),
    })
  ),
  ls.s(
    { trig = "svcsysdll", name = "Get sys dll registry from ctx", dscr = "game::getSysDllRegistryFromCtx(registry)" },
    fmt("auto &{} = game::getSysDllRegistryFromCtx({});", {
      ls.i(1, "sysDllRegistrySvc"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svcentityanimation", name = "Get entity registry animation svc", dscr = "game::getEntityRegistryAnimationSvc(registry)" },
    fmt("auto &{} = game::getEntityRegistryAnimationSvc({});", {
      ls.i(1, "entityRegistryAnimationSvc"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svctime", name = "Get game time from ctx", dscr = "game::getGameTimeFromCtx(registry)" },
    fmt("auto &{} = game::getGameTimeFromCtx({});", {
      ls.i(1, "gameTime"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svcluaglobal", name = "Get lua global state from ctx", dscr = "scripting::getLuaGlobalStateFromCtx(registry)" },
    fmt("auto &{} = scripting::getLuaGlobalStateFromCtx({});", {
      ls.i(1, "luaGlobalStateSvc"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svcsymbolfinder", name = "Get symbol finder svc from ctx", dscr = "game::getSymbolFinderSvcFromCtx(registry)" },
    fmt("auto &{} = game::getSymbolFinderSvcFromCtx({});", {
      ls.i(1, "symbolFinderSvc"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svcrand", name = "Get rand service from ctx", dscr = "game::getRandServiceFromCtx(registry)" },
    fmt("auto &{} = game::getRandServiceFromCtx({});", {
      ls.i(1, "randSvc"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svcentitytexture", name = "Get entity texture svc", dscr = "game::getEntityTextureSvc(registry)" },
    fmt("auto &{} = game::getEntityTextureSvc({});", {
      ls.i(1, "entityTextureSvc"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svcentityoverlay", name = "Get entity registry overlay svc", dscr = "game::getEntityRegistryOverlaySvc(registry)" },
    fmt("auto &{} = game::getEntityRegistryOverlaySvc({});", {
      ls.i(1, "entityRegistryOverlaySvc"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svcgamemanager", name = "Get game manager svc from ctx", dscr = "game::getGameManagerSvcFromCtx(registry)" },
    fmt("auto &{} = game::getGameManagerSvcFromCtx({});", {
      ls.i(1, "gameManagerSvc"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svcscriptregistry", name = "Get script registry from ctx", dscr = "scripting::getScriptRegistryFromCtx(registry)" },
    fmt("auto &{} = scripting::getScriptRegistryFromCtx({});", {
      ls.i(1, "scriptRegistrySvc"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "svceventdispatcher", name = "Get event dispatcher", dscr = "events::getEventDispatcherFromCtx(registry)" },
    fmt("auto &{} = events::getEventDispatcherFromCtx({});", {
      ls.i(1, "eventDispatcher"),
      ls.i(2, "registry"),
    })
  ),
  ls.s(
    { trig = "enqueueevent", name = "Enqueue event", dscr = 'eventDispatcher.enqueue(cmp::eStateChangeEvent{ .entity = entity, .event = "DAMAGE_RESOLVED"_hs })' },
    fmta([[
<dispatcher>.enqueue(<event_type>{
  .entity = <entity>,
  .event = <event>,
});
]], {
      dispatcher = ls.i(1, "eventDispatcher"),
      event_type = ls.i(2, "cmp::eStateChangeEvent"),
      entity = ls.i(3, "entity"),
      event = ls.i(4, '"DAMAGE_RESOLVED"_hs'),
    })
  ),
}

ls.add_snippets("cpp", snippets)
