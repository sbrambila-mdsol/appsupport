USE		-- THE DATABASE OF YOUR SCENARIO
exec agd.uspQADataReport @intTPSScenarioTypeId = 30276	--THE SCENARIO THAT YOU NEED TO GENERATE QA FOR
exec agd.uspQAGenerate @intTPSScenarioTypeId = 30276	--SENDS THE RESULTS OF THAT REPORT VIA EMAIL