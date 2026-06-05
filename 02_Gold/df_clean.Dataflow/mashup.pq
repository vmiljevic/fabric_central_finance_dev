[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "dim_company_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared dim_company = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = Variable.ValueOrDefault("$(/**/vl_main/WorkspaceID)",  "c70edda0-25b6-4c4e-ad60-5a2466e1851f")]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = Variable.ValueOrDefault("$(/**/vl_main/SilverLakehouseID)",  "6d567d3b-f85d-4055-a4b1-100b9da83cf0")]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "dim_company", ItemKind = "Table"]}[Data]



in
  #"Navigation 2";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "dim_date_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared dim_date = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = Variable.ValueOrDefault("$(/**/vl_main/WorkspaceID)",  "c70edda0-25b6-4c4e-ad60-5a2466e1851f")]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = Variable.ValueOrDefault("$(/**/vl_main/SilverLakehouseID)",  "6d567d3b-f85d-4055-a4b1-100b9da83cf0")]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "dim_date", ItemKind = "Table"]}[Data]
in
  #"Navigation 2";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "dim_profit_centers_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared dim_profit_centers = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = Variable.ValueOrDefault("$(/**/vl_main/WorkspaceID)",  "c70edda0-25b6-4c4e-ad60-5a2466e1851f")]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = Variable.ValueOrDefault("$(/**/vl_main/SilverLakehouseID)",  "6d567d3b-f85d-4055-a4b1-100b9da83cf0")]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "dim_profit_centers", ItemKind = "Table"]}[Data],
  #"Renamed columns" = Table.RenameColumns(#"Navigation 2", {{"Landing Zone 1 - Other", "Landing Zone OE"}})
in
  #"Renamed columns";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "fact_costs_cbn_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared fact_costs_cbn = let
  // Load fact table from Lakehouse
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = Variable.ValueOrDefault("$(/**/vl_main/WorkspaceID)",  "c70edda0-25b6-4c4e-ad60-5a2466e1851f")]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = Variable.ValueOrDefault("$(/**/vl_main/SilverLakehouseID)",  "6d567d3b-f85d-4055-a4b1-100b9da83cf0")]}[Data],
  fact_costs_cbn = #"Navigation 1"{[Id = "fact_costs_cbn", ItemKind = "Table"]}[Data],

  // Step 1: Build OH adjustments
  OHOverhead = Table.SelectRows(fact_costs_cbn, each [Group Nature] = "Overhead"),
  OHGrouped = Table.Group(OHOverhead,
      {"Year", "Amount Type", "Change Run Indicator Intial", "Company Code", "Group Nature"},
      {{"Amount", each -List.Sum([Amount]), type nullable number}}),
  OHWithKey = Table.AddColumn(OHGrouped, "OH Key",
      each [Year] & "-" & [Amount Type] & "-" & [Company Code]),
  OHMerged = Table.NestedJoin(OHWithKey, {"OH Key"},
      map_cbn_oh_allocation, {"Key"}, "map_cbn_oh_allocation", JoinKind.LeftOuter),
  OHExpanded = Table.ExpandTableColumn(OHMerged, "map_cbn_oh_allocation",
      {"Cost By Nature", "Split"}, {"Cost By Nature", "Split"}),
  OHWithCorrected = Table.AddColumn(OHExpanded, "Amount Corrected",
      each [Amount] * [Split]),
  OHWithCbN = Table.AddColumn(OHWithCorrected, "Cost By Nature Final",
      each if [Cost By Nature] <> null then [Cost By Nature] else [Group Nature]),
  OHWithFinal = Table.AddColumn(OHWithCbN, "Amount Final",
      each if [Amount Corrected] <> null then [Amount Corrected] else [Amount]),
  OHFiltered = Table.SelectRows(OHWithFinal,
      each [Cost By Nature Final] <> null and [Cost By Nature Final] <> "Overhead"),
  OHAdjGrouped = Table.Group(OHFiltered,
      {"Cost By Nature Final", "Change Run Indicator Intial", "Year", "Amount Type"},
      {{"amount", each List.Sum([Amount Final]), type nullable number}}),
  OHAdjWithKey = Table.AddColumn(OHAdjGrouped, "OH Key",
      each [Year] & "-" & [Amount Type] & "-" & [Cost By Nature Final]),
  OHPivoted = Table.Pivot(
      Table.TransformColumnTypes(OHAdjWithKey, {{"Change Run Indicator Intial", type text}}),
      List.Distinct(Table.TransformColumnTypes(OHAdjWithKey,
          {{"Change Run Indicator Intial", type text}})[#"Change Run Indicator Intial"]),
      "Change Run Indicator Intial", "amount"),
  OHPivotedClean = Table.ReplaceValue(OHPivoted, null, 0,
      Replacer.ReplaceValue, {"Change", "Project", "Run", "Not assigned"}),

  // Step 2: Summary totals
  SummaryTotals = Table.Group(fact_costs_cbn,
      {"Group Nature", "Change Run Indicator", "Amount Type", "Year"},
      {{"Total Amount", each -List.Sum([Amount]), type number}}),

  // Step 3: Join OH adjustments to detail
  DetailWithKey = Table.AddColumn(fact_costs_cbn, "OH Key",
      each [Year] & "-" & [Amount Type] & "-" & [Group Nature]),
  DetailWithSummary = Table.NestedJoin(DetailWithKey,
      {"Group Nature", "Change Run Indicator", "Amount Type", "Year"},
      SummaryTotals,
      {"Group Nature", "Change Run Indicator", "Amount Type", "Year"},
      "summary", JoinKind.LeftOuter),
  DetailWithSummaryExp = Table.ExpandTableColumn(DetailWithSummary, "summary",
      {"Total Amount"}, {"Total Amount"}),
  DetailWithOH = Table.NestedJoin(DetailWithSummaryExp, {"OH Key"},
      OHPivotedClean, {"OH Key"}, "oh_adj", JoinKind.LeftOuter),
  DetailWithOHExp = Table.ExpandTableColumn(DetailWithOH, "oh_adj",
      {"Not assigned", "Run", "Project", "Change"},
      {"OH Not assigned", "OH Run", "OH Project", "OH Change"}),
  DetailWithOHClean = Table.ReplaceValue(DetailWithOHExp, null, 0,
      Replacer.ReplaceValue, {"OH Change", "OH Project", "OH Run", "OH Not assigned"}),

  // Step 4: Proportional adjustment
  DetailWithAdjusted = Table.AddColumn(DetailWithOHClean, "Amount Adjusted",
      each let
          prop = if [Total Amount] = 0 then 0 else -[Amount] / [Total Amount]
      in
          Currency.From(
              if [Change Run Indicator] = "Not assigned"
                  then -(-[Amount] - ([OH Run] * prop) - ([OH Project] * prop) - ([OH Change] * prop))
              else if [Change Run Indicator] = "Run"
                  then -(-[Amount] + ([OH Run] * prop))
              else if [Change Run Indicator] = "Change"
                  then -(-[Amount] + ([OH Change] * prop))
              else if [Change Run Indicator] = "Project"
                  then -(-[Amount] + ([OH Project] * prop))
              else [Amount])),

  // Step 5: Remove helper columns — keep original Amount intact
  DetailCleaned = Table.RemoveColumns(DetailWithAdjusted,
      {"OH Key", "Total Amount", "OH Not assigned", "OH Run", "OH Project", "OH Change"}),

  // Step 6: Snapshot original Group Nature and Change Run Indicator before transforming
  DetailWithOrigGN = Table.AddColumn(DetailCleaned, "Group Nature Original",
      each [Group Nature]),
  DetailWithOrigCRI = Table.AddColumn(DetailWithOrigGN, "Change Run Indicator Original",
      each [Change Run Indicator]),

  // Step 7: Group Nature reclassification
  DetailGroupFixed = Table.TransformColumns(DetailWithOrigCRI,
      {{"Group Nature", each if _ = "Overhead" or _ = "Secondary Costs"
          then "Charging effects" else _, type text}}),

  // Step 8: Map to Run/Change only
  DetailWithRunChange = Table.AddColumn(DetailGroupFixed, "Change Run Indicator Final",
      each if [Group Nature] = "Charging effects" then "Run"
           else if List.Contains({"Run", "Not assigned"}, [Change Run Indicator]) then "Run"
           else if List.Contains({"Change", "Project"}, [Change Run Indicator]) then "Change"
           else null),

  DetailFinal = Table.RemoveColumns(DetailWithRunChange, {"Change Run Indicator"}),
  DetailFinalRenamed = Table.RenameColumns(DetailFinal,
      {{"Change Run Indicator Final", "Change Run Indicator"}}),

  #"Changed column type" = Table.TransformColumnTypes(DetailFinalRenamed, {
      {"Amount", type number},
      {"Amount Adjusted", type number},
      {"Change Run Indicator", type text},
      {"Change Run Indicator Original", type text},
      {"Group Nature Original", type text}
  }),
  #"Added custom" = Table.AddColumn(#"Changed column type", "Overhead Indicator", each if [Costcenter Typ 1] = "O" and [#"AMOS REP - L2"] = "5.93.1 - Overhead costs (total)" then "Overhead" else "Non-Overhead"),
  #"Removed columns" = Table.RemoveColumns(#"Added custom", {"Change Run Indicator Original", "Group Nature Original", "Group Nature", "Group Nature Short", "CbN - Revised categorization", "Change Run Indicator Intial", "Sort", "Costcenter Typ 1", "File Name", "Month", "Year", "TO-BE P&L - L2", "Cost Element Old", "Cost Element Old Name"}),
  #"Merged queries" = Table.NestedJoin(#"Removed columns", {"Profit Center Key"}, dim_profit_centers, {"Profit Center Key"}, "dim_profit_centers", JoinKind.LeftOuter),
  #"Expanded dim_profit_centers" = Table.ExpandTableColumn(#"Merged queries", "dim_profit_centers", {"Landing Zone OE", "Global Local Indicator", "Target Service Cluster"}, {"Landing Zone OE", "Global Local Indicator", "Target Service Cluster"}),
  #"Appended query" = Table.Combine({#"Expanded dim_profit_centers", fact_costs_cbn_restructuring}),
  #"Merged queries 1" = Table.NestedJoin(#"Appended query", {"Cost Element"}, dim_cost_elements, {"Cost Element ID"}, "dim_cost_elements", JoinKind.LeftOuter),
  #"Expanded dim_cost_elements" = Table.ExpandTableColumn(#"Merged queries 1", "dim_cost_elements", {"Global Local Indicator Correction"}, {"Global Local Indicator Correction"}),
  #"Added custom 1" = Table.AddColumn(#"Expanded dim_cost_elements", "Final Global Local Indicator", each if [Global Local Indicator Correction] <> null then [Global Local Indicator Correction] else [Global Local Indicator]),
  #"Removed columns 1" = Table.RemoveColumns(#"Added custom 1", {"Global Local Indicator", "Global Local Indicator Correction"}),
  #"Renamed columns" = Table.RenameColumns(#"Removed columns 1", {{"Final Global Local Indicator", "Global Local Indicator"}}),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Renamed columns", {{"Overhead Indicator", type text}, {"Landing Zone OE", type text}, {"Target Service Cluster", type text}, {"Global Local Indicator", type text}})

in
  #"Changed column type 1";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "dim_cost_elements_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared dim_cost_elements = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = Variable.ValueOrDefault("$(/**/vl_main/WorkspaceID)",  "c70edda0-25b6-4c4e-ad60-5a2466e1851f")]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = Variable.ValueOrDefault("$(/**/vl_main/SilverLakehouseID)",  "6d567d3b-f85d-4055-a4b1-100b9da83cf0")]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "dim_cost_elements", ItemKind = "Table"]}[Data]
in
  #"Navigation 2";
shared map_cbn_oh_allocation = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = Variable.ValueOrDefault("$(/**/vl_main/WorkspaceID)",  "c70edda0-25b6-4c4e-ad60-5a2466e1851f")]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = Variable.ValueOrDefault("$(/**/vl_main/SilverLakehouseID)",  "6d567d3b-f85d-4055-a4b1-100b9da83cf0")]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "map_cbn_oh_allocation", ItemKind = "Table"]}[Data]
in
  #"Navigation 2";
shared dim_date_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[lakehouseName = "lh_finance_global_gold"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "dim_date", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared dim_company_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[lakehouseName = "lh_finance_global_gold"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "dim_company", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared fact_costs_cbn_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[lakehouseName = "lh_finance_global_gold"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "fact_costs_cbn", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared dim_cost_elements_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[lakehouseName = "lh_finance_global_gold"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "dim_cost_elements", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared dim_profit_centers_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[lakehouseName = "lh_finance_global_gold"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "dim_profit_centers", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared fact_costs_cbn_restructuring = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "c70edda0-25b6-4c4e-ad60-5a2466e1851f"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "6d567d3b-f85d-4055-a4b1-100b9da83cf0"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "fact_costs_restructuring", ItemKind = "Table"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 2", {{"Amount", type number}, {"Period", type date}}),
  #"Added custom" = Table.AddColumn(#"Changed column type", "Local Global Indicator", each "Restructuring & Financing"),
  #"Duplicated column" = Table.DuplicateColumn(#"Added custom", "Amount", "Amount - Copy"),
  #"Renamed columns" = Table.RenameColumns(#"Duplicated column", {{"Amount - Copy", "Amount Adjusted"}, {"Period", "Month Date"}}),
  #"Removed columns" = Table.RemoveColumns(#"Renamed columns", {"Cost Type"}),
  #"Added custom 1" = Table.AddColumn(#"Removed columns", "Overhead Indicator", each "Non-Overhead"),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Added custom 1", {{"Overhead Indicator", type text}, {"Local Global Indicator", type text}}),
  #"Added custom 2" = Table.AddColumn(#"Changed column type 1", "Target Service Cluster", each "Other"),
  #"Added custom 3" = Table.AddColumn(#"Added custom 2", "Landing Zone OE", each "Other OEs"),
  #"Renamed columns 1" = Table.RenameColumns(#"Added custom 3", {{"Local Global Indicator", "Global Local Indicator"}}),
  #"Multiplied column" = Table.TransformColumns(#"Renamed columns 1", {{"Amount", each _ * -1, type number}}),
  #"Multiplied column 1" = Table.TransformColumns(#"Multiplied column", {{"Amount Adjusted", each _ * -1, type number}})
in
  #"Multiplied column 1";
