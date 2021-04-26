local Addon, Private = ...

-- Default settings.
-----------------------------------------------------------
-- Note that anything changed will be saved to disk
-- when you reload the user interface, or exit the game,
-- and those saved changes will override your defaults here.
-- * You should access saved settings by using db[key]
-- * Don't put frame handles or other widget references in here, 
--   just strings, numbers and booleans.
Private.db = (function(db) _G[Addon.."_DB"] = db; return db end)({
	
})
