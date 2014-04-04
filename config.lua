application =
{
    content =
        {
        	width = 720, -- required for dynamic scaling, set to portrait
        	height = 1280, -- says http://docs.coronalabs.com/guide/basics/configSettings/index.html
        	scale = "letterbox", -- no black bars or main screen will get ugly
        	xAlign = "center",
        	yAlign = "center",
            fps = 60,
            imageSuffix = { ["-fhd"] = 1.5, },
            antialias = true,
            graphicsCompatibility = 1,
        },
}
