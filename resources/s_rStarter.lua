
sR = {
'admin',
'runcode',
-- [Shaders]
'base_env',
-- [Mapping]
-- [Mapping][Utility]
'cStream',
'cSPLoader',
'BloodGulch',
-- [Generic]
'gen_misc',
-- [Player]
'man_Skin',
'man_Player',
'player_Controller',
-- [Gamemode]
'gm_scoreboard',
'gm_chat',
'gm_HUD',
'gm_notifications',
'gm_Commands',
'gm_Env_Controller',
'gm_Env_Sounds',
'gm_voting',
'gm_BloodGulch',
-- [Vehicle]
'man_vehicle',
'veh_mongoose',
'veh_wathog',
-- [Weapons]
'man_weapon',
'wep_Systems',
'wep_Controller',
'wep_Systems',
-- [Shaders][Standard]
'sh_light',
'sh_detail',
'sh_fxaa',
'sh_dof',
'sh_lut',
'sh_flag',
'sh_sway',
'sh_bloom',
'sh_blur',
'sh_alpha',
'sh_soft_particles',
'sh_antenna',
'sh_water',
'sh_null',
'cn_ssao',
-- [Shaders][Deferred]
-- Final launch --
'gm_settings',
}

for i,v in pairs(sR) do
	if getResourceFromName ( v ) then
		startResource (getResourceFromName (v))
		print('sR :'..v)
	 end
end