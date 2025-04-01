return {
	{
		"yongshengzhucn/better-escape",
		dev = true,
		event = "InsertEnter",
		config = function()
			require("better_escape").setup()
		end,
	},
}
