NULL_VECTOR = {
	0, 0, 0
}

PERIOD_HALFTIME = 4
PERIOD_MATCH_END = 5

TIME_INDEFINITE = -1

g_ChatColors = {
	"{default}",
	"{white}",
	"{darkred}",
	"{lightpurple}",
	"{green}",
	"{olive}",
	"{lime}",
	"{red}",
	"{gray}",
	"{grey}",
	"{lightyellow}",
	"{yellow}",
	"{silver}",
	"{bluegrey}",
	"{lightblue}",
	"{blue}",
	"{darkblue}",
	"{purple}",
	"{magenta}",
	"{lightred}",
	"{gold}",
	"{orange}"
}

g_EncodingPatterns = {
	"<",
	">",
	"&",
	"'",
	"\""
}

g_EncodingReplacements = {
	"&lt;",
	"&gt;",
	"&amp;",
	"&#39;",
	"&quot;"
}

g_Items = {
    [1] = "weapon_deagle",
    [2] = "weapon_elite",
    [3] = "weapon_fiveseven",
    [4] = "weapon_glock",
    [7] = "weapon_ak47",
    [8] = "weapon_aug",
    [9] = "weapon_awp",
    [10] = "weapon_famas",
    [11] = "weapon_g3sg1",
    [13] = "weapon_galilar",
    [14] = "weapon_m249",
    [16] = "weapon_m4a1",
    [17] = "weapon_mac10",
    [19] = "weapon_p90",
    [23] = "weapon_mp5sd",
    [24] = "weapon_ump45",
    [25] = "weapon_xm1014",
    [26] = "weapon_bizon",
    [27] = "weapon_mag7",
    [28] = "weapon_negev",
    [29] = "weapon_sawedoff",
    [30] = "weapon_tec9",
    [31] = "weapon_taser",
    [32] = "weapon_hkp2000",
    [33] = "weapon_mp7",
    [34] = "weapon_mp9",
    [35] = "weapon_nova",
    [36] = "weapon_p250",
    [38] = "weapon_scar20",
    [39] = "weapon_sg556",
    [40] = "weapon_ssg08",
	[41] = "weapon_knifegg",
	[42] = "weapon_knife",
	[59] = "weapon_knife_t",
    [60] = "weapon_m4a1_silencer",
    [61] = "weapon_usp_silencer",
    [63] = "weapon_cz75a",
    [64] = "weapon_revolver",
	[80] = "weapon_knife_ghost",
	[500] = "weapon_bayonet",
	[503] = "weapon_knife_css",
	[505] = "weapon_knife_flip",
	[506] = "weapon_knife_gut",
	[507] = "weapon_knife_karambit",
	[508] = "weapon_knife_m9_bayonet",
	[509] = "weapon_knife_tactical",
	[512] = "weapon_knife_falchion",
	[514] = "weapon_knife_survival_bowie",
	[515] = "weapon_knife_butterfly",
	[516] = "weapon_knife_push",
	[517] = "weapon_knife_cord",
	[518] = "weapon_knife_canis",
	[519] = "weapon_knife_ursus",
	[520] = "weapon_knife_gypsy_jackknife",
	[521] = "weapon_knife_outdoor",
	[522] = "weapon_knife_stiletto",
	[523] = "weapon_knife_widowmaker",
	[525] = "weapon_knife_skeleton",
	[526] = "weapon_knife_kukri",
    ["weapon_deagle"] = 1,
    ["weapon_elite"] = 2,
    ["weapon_fiveseven"] = 3,
    ["weapon_glock"] = 4,
    ["weapon_ak47"] = 7,
    ["weapon_aug"] = 8,
    ["weapon_awp"] = 9,
    ["weapon_famas"] = 10,
    ["weapon_g3sg1"] = 11,
    ["weapon_galilar"] = 13,
    ["weapon_m249"] = 14,
    ["weapon_m4a1"] = 16,
    ["weapon_mac10"] = 17,
    ["weapon_p90"] = 19,
    ["weapon_mp5sd"] = 23,
    ["weapon_ump45"] = 24,
    ["weapon_xm1014"] = 25,
    ["weapon_bizon"] = 26,
    ["weapon_mag7"] = 27,
    ["weapon_negev"] = 28,
    ["weapon_sawedoff"] = 29,
    ["weapon_tec9"] = 30,
    ["weapon_taser"] = 31,
    ["weapon_hkp2000"] = 32,
    ["weapon_mp7"] = 33,
    ["weapon_mp9"] = 34,
    ["weapon_nova"] = 35,
    ["weapon_p250"] = 36,
    ["weapon_scar20"] = 38,
    ["weapon_sg556"] = 39,
    ["weapon_ssg08"] = 40,
    ["weapon_knifegg"] = 41,
    ["weapon_knife"] = 42,
    ["weapon_knife_t"] = 59,
    ["weapon_m4a1_silencer"] = 60,
    ["weapon_usp_silencer"] = 61,
    ["weapon_cz75a"] = 63,
    ["weapon_revolver"] = 64,
    ["weapon_knife_ghost"] = 80,
    ["weapon_bayonet"] = 500,
    ["weapon_knife_css"] = 503,
    ["weapon_knife_flip"] = 505,
    ["weapon_knife_gut"] = 506,
    ["weapon_knife_karambit"] = 507,
    ["weapon_knife_m9_bayonet"] = 508,
    ["weapon_knife_tactical"] = 509,
    ["weapon_knife_falchion"] = 512,
    ["weapon_knife_survival_bowie"] = 514,
    ["weapon_knife_butterfly"] = 515,
    ["weapon_knife_push"] = 516,
    ["weapon_knife_cord"] = 517,
    ["weapon_knife_canis"] = 518,
    ["weapon_knife_ursus"] = 519,
    ["weapon_knife_gypsy_jackknife"] = 520,
    ["weapon_knife_outdoor"] = 521,
    ["weapon_knife_stiletto"] = 522,
    ["weapon_knife_widowmaker"] = 523,
    ["weapon_knife_skeleton"] = 525,
    ["weapon_knife_kukri"] = 526
}

g_KnifeItems = {
	[41] = "weapon_knifegg",
	[42] = "weapon_knife",
	[59] = "weapon_knife_t",
	[80] = "weapon_knife_ghost",
	[500] = "weapon_bayonet",
	[503] = "weapon_knife_css",
	[505] = "weapon_knife_flip",
	[506] = "weapon_knife_gut",
	[507] = "weapon_knife_karambit",
	[508] = "weapon_knife_m9_bayonet",
	[509] = "weapon_knife_tactical",
	[512] = "weapon_knife_falchion",
	[514] = "weapon_knife_survival_bowie",
	[515] = "weapon_knife_butterfly",
	[516] = "weapon_knife_push",
	[517] = "weapon_knife_cord",
	[518] = "weapon_knife_canis",
	[519] = "weapon_knife_ursus",
	[520] = "weapon_knife_gypsy_jackknife",
	[521] = "weapon_knife_outdoor",
	[522] = "weapon_knife_stiletto",
	[523] = "weapon_knife_widowmaker",
	[525] = "weapon_knife_skeleton",
	[526] = "weapon_knife_kukri",
	["weapon_knifegg"] = 41,
	["weapon_knife"] = 42,
	["weapon_knife_t"] = 59,
	["weapon_knife_ghost"] = 80,
	["weapon_bayonet"] = 500,
	["weapon_knife_css"] = 503,
	["weapon_knife_flip"] = 505,
	["weapon_knife_gut"] = 506,
	["weapon_knife_karambit"] = 507,
	["weapon_knife_m9_bayonet"] = 508,
	["weapon_knife_tactical"] = 509,
	["weapon_knife_falchion"] = 512,
	["weapon_knife_survival_bowie"] = 514,
	["weapon_knife_butterfly"] = 515,
	["weapon_knife_push"] = 516,
	["weapon_knife_cord"] = 517,
	["weapon_knife_canis"] = 518,
	["weapon_knife_ursus"] = 519,
	["weapon_knife_gypsy_jackknife"] = 520,
	["weapon_knife_outdoor"] = 521,
	["weapon_knife_stiletto"] = 522,
	["weapon_knife_widowmaker"] = 523,
	["weapon_knife_skeleton"] = 525,
	["weapon_knife_kukri"] = 526
}

g_TeamChatColors = {
	[Team.T] = "{gold}",
	[Team.CT] = "{lightblue}",
	[Team.Spectator] = "{grey}",
	[Team.None] = "{grey}"
}

g_TeamHintColors = {
	[Team.T] = "#FFA500",
	[Team.CT] = "#6BDBFF",
	[Team.Spectator] = "#FFFFFF",
	[Team.None] = "#FFFFFF"
}

g_TeamIdentifiers = {
	["t"] = Team.T,
	["ct"] = Team.CT,
	["spec"] = Team.Spectator,
	[Team.T] = "t",
	[Team.CT] = "ct",
	[Team.Spectator] = "spec"
}

g_TeamItems = {
	[3] = Team.CT,
	[4] = Team.T,
	[7] = Team.T,
	[8] = Team.CT,
	[10] = Team.CT,
	[11] = Team.T,
	[13] = Team.T,
	[16] = Team.CT,
	[17] = Team.T,
	[27] = Team.CT,
	[29] = Team.T,
	[30] = Team.T,
	[32] = Team.CT,
	[34] = Team.CT,
	[38] = Team.CT,
	[39] = Team.T,
	[60] = Team.CT,
	[61] = Team.CT
}

g_TeamNames = {
	[Team.T] = "Terrorists",
	[Team.CT] = "Counter-Terrorists",
	[Team.Spectator] = "Spectators"
}