local describe = require("plenary.busted").describe
local it = require("plenary.busted").it

describe("fix-ts-var-hints plugin tests", function()
	it("should test a function from the plugin", function()
		local my_plugin = require("fix-ts-var-hints") -- This requires your plugin
		local result = my_plugin.your_function() -- Replace with the function you want to test
		assert.are.same(result, "expected_result")
	end)
end)
