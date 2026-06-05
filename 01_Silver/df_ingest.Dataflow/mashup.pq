[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared fact_costs_cbn_actuals = let
    Source = SharePoint.Files("https://allianzms.sharepoint.com/teams/AT0090-10144432/", [ApiVersion = 15]),
  #"Filtered rows" = Table.SelectRows(Source, each Text.Contains([Folder Path], "Shared Documents/01_Power BI/05_Group/01_Data/01_SAP BW/04_CbN")),
    #"Added custom 1" = Table.TransformColumns(
        #"Filtered rows",
        {{"Folder Path", each Text.Start(Text.End(_, 5), 4), type text}}
    ),
  #"Added custom 2" = Table.AddColumn(#"Added custom 1", "Current Year", each Date.Year(DateTime.LocalNow())),
    #"Renamed Columns" = Table.RenameColumns(#"Added custom 2",{{"Folder Path", "Year"}}),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Renamed Columns", {{"Year", type text}, {"Current Year", type text}}),
  #"Filtered rows 1" = Table.SelectRows(#"Changed column type 1", each (([Year] = [Current Year] or [Year] <> [Current Year]) and Text.Contains([Name],"Costs") and Text.Contains([Name],"Actuals") and not Text.Contains([Name],"_template") )),
    #"Removed Other Columns4" = Table.SelectColumns(#"Filtered rows 1", {"Content", "Name", "Date modified","Year"}),
    #"Added Custom1" = Table.AddColumn(#"Removed Other Columns4", "Extracted Data", each Table.SelectRows(Excel.Workbook([Content]), each [Item] = "Sheet1")),
    #"Expanded Extracted Data2" = Table.ExpandTableColumn(#"Added Custom1", "Extracted Data", {"Data"}, {"Data"}),
    #"Expanded Data" = Table.ExpandTableColumn(#"Expanded Extracted Data2", "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22"}),
    #"Added Custom2" = Table.AddColumn(#"Expanded Data", "File Name", each if [Column1] = "Company Code" then "File Name" else [Name]),
    #"Added Custom4" = Table.AddColumn(#"Added Custom2", "Refresh Date", each if [Column1] = "Company Code" then "Refresh Date" else [Date modified]),
    #"Added custom 5" = Table.AddColumn(#"Added Custom4", "Year1", each if [Column1] = "Company Code" then "Year" else [Year]),
    #"Removed Columns" = Table.RemoveColumns(#"Added custom 5",{"Year"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Removed Columns",{{"Year1", "Year"}}),
    #"Removed columns" = Table.RemoveColumns(#"Renamed Columns1", {"Content", "Name", "Date modified"}),
    #"Promoted Headers" = Table.PromoteHeaders(#"Removed columns", [PromoteAllScalars=true]),
  #"Removed top rows" = Table.Skip(#"Promoted Headers", 3),
    #"Filtered Rows1" = Table.SelectRows(#"Removed top rows", each ([Company Name] <> "" and [Company Name] <> "Company Code" and [Company Code] <> "Company Code") ),
    #"Unpivoted Other Columns1" = Table.UnpivotOtherColumns(#"Filtered Rows1", {"Company Code", "Company Name", "Profit Center", "Profit Center Name", "Cost Center", "Cost Center Name", "WBS Element", "WBS Element Name", "Cost Element", "Cost Element Name", "File Name", "Refresh Date", "Year"}, "Attribute", "Value"),
    #"Renamed Columns12" = Table.RenameColumns(#"Unpivoted Other Columns1",{{"Value", "Amount"}}),
    #"Added Custom5" = Table.AddColumn(#"Renamed Columns12", "Type", each if Text.Contains([Attribute], "PY") then "PY" else if Text.Contains([Attribute], "Actual") then "Actuals" else if Text.Contains([Attribute], "FC") then "FC" else "Plan"),
    #"Split Column by Delimiter" = Table.SplitColumn(#"Added Custom5", "Attribute", Splitter.SplitTextByEachDelimiter({"-"}, QuoteStyle.Csv, true), {"Attribute.1", "Attribute.2"}),
    #"Removed Columns1" = Table.RemoveColumns(#"Split Column by Delimiter",{"Attribute.1"}),
    #"Renamed Columns3" = Table.RenameColumns(#"Removed Columns1",{{"Attribute.2", "Month"}}),
    #"Changed Type2" = Table.TransformColumnTypes(#"Renamed Columns3",{{"Month", type text}, {"Year", type text}}),
    #"Added Custom44" = Table.AddColumn(#"Changed Type2", "Month Date", each [Year] & "-" & [Month]),
    #"Changed Type1" = Table.TransformColumnTypes(#"Added Custom44",{{"Amount", Currency.Type}}),
    #"Removed Columns3" = Table.RemoveColumns(#"Changed Type1",{"Company Name"}),
    #"Renamed Columns2" = Table.RenameColumns(#"Removed Columns3",{{"Type", "Amount Type"}}),
    #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns2",{{"Month Date", type date},  {"Refresh Date", type datetime}}),
    #"Multiplied Column" = Table.TransformColumns(#"Changed Type", {{"Amount", each _ * -1, Currency.Type}}),
    #"Added Custom" = Table.AddColumn(#"Multiplied Column", "Pl Type", each "Costs"),
    #"Changed Type3" = Table.TransformColumnTypes(#"Added Custom",{{"Month", Int64.Type}}),
    #"Filtered Rows" = Table.SelectRows(#"Changed Type3", each [Amount] <> 0)
in
    #"Filtered Rows";
shared fact_costs_cbn_plan = let
    Source = SharePoint.Files("https://allianzms.sharepoint.com/teams/AT0090-10144432/", [ApiVersion = 15]),
  #"Filtered rows" = Table.SelectRows(Source, each Text.Contains([Folder Path], "Shared Documents/01_Power BI/05_Group/01_Data/01_SAP BW/04_CbN")),
    #"Added custom 1" = Table.TransformColumns(
        #"Filtered rows",
        {{"Folder Path", each Text.Start(Text.End(_, 5), 4), type text}}
    ),
  #"Added custom 2" = Table.AddColumn(#"Added custom 1", "Current Year", each Date.Year(DateTime.LocalNow())),
    #"Renamed Columns" = Table.RenameColumns(#"Added custom 2",{{"Folder Path", "Year"}}),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Renamed Columns", {{"Year", type text}, {"Current Year", type text}}),
  #"Filtered rows 1" = Table.SelectRows(#"Changed column type 1", each (([Year] = [Current Year] or [Year] <> [Current Year]) and Text.Contains([Name],"Costs") and Text.Contains([Name],"Plan") and not Text.Contains([Name],"_template"))),
    #"Removed Other Columns4" = Table.SelectColumns(#"Filtered rows 1", {"Content", "Name", "Date modified","Year"}),
    #"Added Custom1" = Table.AddColumn(#"Removed Other Columns4", "Extracted Data", each Table.SelectRows(Excel.Workbook([Content]), each [Item] = "Sheet1")),
    #"Expanded Extracted Data2" = Table.ExpandTableColumn(#"Added Custom1", "Extracted Data", {"Data"}, {"Data"}),
    #"Expanded Data" = Table.ExpandTableColumn(#"Expanded Extracted Data2", "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22"}),
    #"Added Custom2" = Table.AddColumn(#"Expanded Data", "File Name", each if [Column1] = "Company Code" then "File Name" else [Name]),
    #"Added Custom4" = Table.AddColumn(#"Added Custom2", "Refresh Date", each if [Column1] = "Company Code" then "Refresh Date" else [Date modified]),
    #"Added custom 5" = Table.AddColumn(#"Added Custom4", "Year1", each if [Column1] = "Company Code" then "Year" else [Year]),
    #"Removed Columns" = Table.RemoveColumns(#"Added custom 5",{"Year"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Removed Columns",{{"Year1", "Year"}}),
    #"Removed columns" = Table.RemoveColumns(#"Renamed Columns1", {"Content", "Name", "Date modified"}),
    #"Promoted Headers" = Table.PromoteHeaders(#"Removed columns", [PromoteAllScalars=true]),
  #"Removed top rows" = Table.Skip(#"Promoted Headers", 3),
    #"Filtered Rows1" = Table.SelectRows(#"Removed top rows", each ([Company Name] <> "" and [Company Name] <> "Company Code" and [Company Code] <> "Company Code") ),
    #"Unpivoted Other Columns1" = Table.UnpivotOtherColumns(#"Filtered Rows1", {"Company Code", "Company Name", "Profit Center", "Profit Center Name", "Cost Center", "Cost Center Name", "WBS Element", "WBS Element Name", "Cost Element", "Cost Element Name", "File Name", "Refresh Date", "Year"}, "Attribute", "Value"),
    #"Renamed Columns12" = Table.RenameColumns(#"Unpivoted Other Columns1",{{"Value", "Amount"}}),
    #"Added Custom5" = Table.AddColumn(#"Renamed Columns12", "Type", each if Text.Contains([Attribute], "PY") then "PY" else if Text.Contains([Attribute], "Actual") then "Actuals" else if Text.Contains([Attribute], "FC") then "FC" else "Plan"),
    #"Split Column by Delimiter" = Table.SplitColumn(#"Added Custom5", "Attribute", Splitter.SplitTextByEachDelimiter({"-"}, QuoteStyle.Csv, true), {"Attribute.1", "Attribute.2"}),
    #"Removed Columns1" = Table.RemoveColumns(#"Split Column by Delimiter",{"Attribute.1"}),
    #"Renamed Columns3" = Table.RenameColumns(#"Removed Columns1",{{"Attribute.2", "Month"}}),
    #"Changed Type2" = Table.TransformColumnTypes(#"Renamed Columns3",{{"Month", type text}, {"Year", type text}}),
    #"Added Custom44" = Table.AddColumn(#"Changed Type2", "Month Date", each [Year] & "-" & [Month]),
    #"Changed Type1" = Table.TransformColumnTypes(#"Added Custom44",{{"Amount", Currency.Type}}),
    #"Removed Columns3" = Table.RemoveColumns(#"Changed Type1",{"Company Name"}),
    #"Renamed Columns2" = Table.RenameColumns(#"Removed Columns3",{{"Type", "Amount Type"}}),
    #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns2",{{"Month Date", type date},  {"Refresh Date", type datetime}}),
    #"Multiplied Column" = Table.TransformColumns(#"Changed Type", {{"Amount", each _ * -1, Currency.Type}}),
    #"Added Custom" = Table.AddColumn(#"Multiplied Column", "Pl Type", each "Costs"),
    #"Changed Type3" = Table.TransformColumnTypes(#"Added Custom",{{"Month", Int64.Type}}),
    #"Filtered Rows" = Table.SelectRows(#"Changed Type3", each [Amount] <> 0)
in
    #"Filtered Rows";
shared fact_costs_cbn_py = let
    Source = SharePoint.Files("https://allianzms.sharepoint.com/teams/AT0090-10144432/", [ApiVersion = 15]),
  #"Filtered rows" = Table.SelectRows(Source, each Text.Contains([Folder Path], "Shared Documents/01_Power BI/05_Group/01_Data/01_SAP BW/04_CbN")),
    #"Added custom 1" = Table.TransformColumns(
        #"Filtered rows",
        {{"Folder Path", each Text.Start(Text.End(_, 5), 4), type text}}
    ),
  #"Added custom 2" = Table.AddColumn(#"Added custom 1", "Current Year", each Date.Year(DateTime.LocalNow())),
    #"Renamed Columns" = Table.RenameColumns(#"Added custom 2",{{"Folder Path", "Year"}}),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Renamed Columns", {{"Year", type text}, {"Current Year", type text}}),
  #"Filtered rows 1" = Table.SelectRows(#"Changed column type 1", each (([Year] = [Current Year] or [Year] <> [Current Year]) and Text.Contains([Name],"Costs") and Text.Contains([Name],"PY") )),
    #"Removed Other Columns4" = Table.SelectColumns(#"Filtered rows 1", {"Content", "Name", "Date modified","Year"}),
    #"Added Custom1" = Table.AddColumn(#"Removed Other Columns4", "Extracted Data", each Table.SelectRows(Excel.Workbook([Content]), each [Item] = "Sheet1")),
    #"Expanded Extracted Data2" = Table.ExpandTableColumn(#"Added Custom1", "Extracted Data", {"Data"}, {"Data"}),
    #"Expanded Data" = Table.ExpandTableColumn(#"Expanded Extracted Data2", "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22"}),
    #"Added Custom2" = Table.AddColumn(#"Expanded Data", "File Name", each if [Column1] = "Company Code" then "File Name" else [Name]),
    #"Added Custom4" = Table.AddColumn(#"Added Custom2", "Refresh Date", each if [Column1] = "Company Code" then "Refresh Date" else [Date modified]),
    #"Added custom 5" = Table.AddColumn(#"Added Custom4", "Year1", each if [Column1] = "Company Code" then "Year" else [Year]),
    #"Removed Columns" = Table.RemoveColumns(#"Added custom 5",{"Year"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Removed Columns",{{"Year1", "Year"}}),
    #"Removed columns" = Table.RemoveColumns(#"Renamed Columns1", {"Content", "Name", "Date modified"}),
    #"Promoted Headers" = Table.PromoteHeaders(#"Removed columns", [PromoteAllScalars=true]),
  #"Removed top rows" = Table.Skip(#"Promoted Headers", 3),
    #"Filtered Rows1" = Table.SelectRows(#"Removed top rows", each ([Company Code] <> "" and [Company Code] <> "Company Code") ),
    #"Unpivoted Other Columns1" = Table.UnpivotOtherColumns(#"Filtered Rows1", {"Company Code", "Company Name", "Profit Center", "Profit Center Name", "Cost Center", "Cost Center Name", "WBS Element", "WBS Element Name", "Cost Element", "Cost Element Name", "File Name", "Refresh Date", "Year"}, "Attribute", "Value"),
    #"Renamed Columns12" = Table.RenameColumns(#"Unpivoted Other Columns1",{{"Value", "Amount"}}),
    #"Added Custom5" = Table.AddColumn(#"Renamed Columns12", "Type", each if Text.Contains([Attribute], "PY") then "PY" else if Text.Contains([Attribute], "Actual") then "Actuals" else if Text.Contains([Attribute], "FC") then "FC" else "Plan"),
    #"Split Column by Delimiter" = Table.SplitColumn(#"Added Custom5", "Attribute", Splitter.SplitTextByEachDelimiter({"-"}, QuoteStyle.Csv, true), {"Attribute.1", "Attribute.2"}),
    #"Removed Columns1" = Table.RemoveColumns(#"Split Column by Delimiter",{"Attribute.1"}),
    #"Renamed Columns3" = Table.RenameColumns(#"Removed Columns1",{{"Attribute.2", "Month"}}),
    #"Changed Type2" = Table.TransformColumnTypes(#"Renamed Columns3",{{"Month", type text}, {"Year", type text}}),
    #"Added Custom44" = Table.AddColumn(#"Changed Type2", "Month Date", each [Year] & "-" & [Month]),
    #"Changed Type1" = Table.TransformColumnTypes(#"Added Custom44",{{"Amount", Currency.Type}}),
    #"Removed Columns3" = Table.RemoveColumns(#"Changed Type1",{"Company Name"}),
    #"Renamed Columns2" = Table.RenameColumns(#"Removed Columns3",{{"Type", "Amount Type"}}),
    #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns2",{{"Month Date", type date},  {"Refresh Date", type datetime}}),
    #"Multiplied Column" = Table.TransformColumns(#"Changed Type", {{"Amount", each _ * -1, Currency.Type}}),
    #"Added Custom" = Table.AddColumn(#"Multiplied Column", "Pl Type", each "Costs"),
    #"Changed Type3" = Table.TransformColumnTypes(#"Added Custom",{{"Month", Int64.Type}}),
    #"Filtered Rows" = Table.SelectRows(#"Changed Type3", each [Amount] <> 0)
in
    #"Filtered Rows";
shared fact_costs_cbn_fc = let
    Source = SharePoint.Files("https://allianzms.sharepoint.com/teams/AT0090-10144432/", [ApiVersion = 15]),
  #"Filtered rows" = Table.SelectRows(Source, each Text.Contains([Folder Path], "Shared Documents/01_Power BI/05_Group/01_Data/01_SAP BW/04_CbN")),
    #"Added custom 1" = Table.TransformColumns(
        #"Filtered rows",
        {{"Folder Path", each Text.Start(Text.End(_, 5), 4), type text}}
    ),
  #"Added custom 2" = Table.AddColumn(#"Added custom 1", "Current Year", each Date.Year(DateTime.LocalNow())),
    #"Renamed Columns" = Table.RenameColumns(#"Added custom 2",{{"Folder Path", "Year"}}),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Renamed Columns", {{"Year", type text}, {"Current Year", type text}}),
  #"Filtered rows 1" = Table.SelectRows(#"Changed column type 1", each (([Year] = [Current Year] or [Year] <> [Current Year]) and Text.Contains([Name],"Costs") and Text.Contains([Name],"FC") and not Text.Contains([Name],"_template") )),
    #"Removed Other Columns4" = Table.SelectColumns(#"Filtered rows 1", {"Content", "Name", "Date modified","Year"}),
    #"Added Custom1" = Table.AddColumn(#"Removed Other Columns4", "Extracted Data", each Table.SelectRows(Excel.Workbook([Content]), each [Item] = "Sheet1")),
    #"Expanded Extracted Data2" = Table.ExpandTableColumn(#"Added Custom1", "Extracted Data", {"Data"}, {"Data"}),
    #"Expanded Data" = Table.ExpandTableColumn(#"Expanded Extracted Data2", "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22"}),
    #"Added Custom2" = Table.AddColumn(#"Expanded Data", "File Name", each if [Column1] = "Company Code" then "File Name" else [Name]),
    #"Added Custom4" = Table.AddColumn(#"Added Custom2", "Refresh Date", each if [Column1] = "Company Code" then "Refresh Date" else [Date modified]),
    #"Added custom 5" = Table.AddColumn(#"Added Custom4", "Year1", each if [Column1] = "Company Code" then "Year" else [Year]),
    #"Removed Columns" = Table.RemoveColumns(#"Added custom 5",{"Year"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Removed Columns",{{"Year1", "Year"}}),
    #"Removed columns" = Table.RemoveColumns(#"Renamed Columns1", {"Content", "Name", "Date modified"}),
    #"Promoted Headers" = Table.PromoteHeaders(#"Removed columns", [PromoteAllScalars=true]),
  #"Removed top rows" = Table.Skip(#"Promoted Headers", 3),
    #"Filtered Rows1" = Table.SelectRows(#"Removed top rows", each ([Company Name] <> "" and [Company Name] <> "Company Code" and [Company Code] <> "Company Code")  ),
    #"Unpivoted Other Columns1" = Table.UnpivotOtherColumns(#"Filtered Rows1", {"Company Code", "Company Name", "Profit Center", "Profit Center Name", "Cost Center", "Cost Center Name", "WBS Element", "WBS Element Name", "Cost Element", "Cost Element Name", "File Name", "Refresh Date", "Year"}, "Attribute", "Value"),
    #"Renamed Columns12" = Table.RenameColumns(#"Unpivoted Other Columns1",{{"Value", "Amount"}}),
    #"Added Custom5" = Table.AddColumn(#"Renamed Columns12", "Type", each if Text.Contains([Attribute], "PY") then "PY" else if Text.Contains([Attribute], "Actual") then "Actuals" else if Text.Contains([Attribute], "FC") then "FC" else "Plan"),
    #"Split Column by Delimiter" = Table.SplitColumn(#"Added Custom5", "Attribute", Splitter.SplitTextByEachDelimiter({"-"}, QuoteStyle.Csv, true), {"Attribute.1", "Attribute.2"}),
    #"Removed Columns1" = Table.RemoveColumns(#"Split Column by Delimiter",{"Attribute.1"}),
    #"Renamed Columns3" = Table.RenameColumns(#"Removed Columns1",{{"Attribute.2", "Month"}}),
    #"Changed Type2" = Table.TransformColumnTypes(#"Renamed Columns3",{{"Month", type text}, {"Year", type text}}),
    #"Added Custom44" = Table.AddColumn(#"Changed Type2", "Month Date", each [Year] & "-" & [Month]),
    #"Changed Type1" = Table.TransformColumnTypes(#"Added Custom44",{{"Amount", Currency.Type}}),
    #"Removed Columns3" = Table.RemoveColumns(#"Changed Type1",{"Company Name"}),
    #"Renamed Columns2" = Table.RenameColumns(#"Removed Columns3",{{"Type", "Amount Type"}}),
    #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns2",{{"Month Date", type date},  {"Refresh Date", type datetime}}),
    #"Multiplied Column" = Table.TransformColumns(#"Changed Type", {{"Amount", each _ * -1, Currency.Type}}),
    #"Added Custom" = Table.AddColumn(#"Multiplied Column", "Pl Type", each "Costs"),
        // 🔹 Add 12 monthly columns = FC / 12
    #"Added 12 Months" = List.Accumulate(
        {1..12},
        #"Added Custom",
        (state, current) => Table.AddColumn(state, Text.From(current), each try [Amount] / 12 otherwise null)
    ),

    // 🔹 Unpivot those 12 month columns
    #"Unpivoted Months" = Table.Unpivot(
        #"Added 12 Months",
        List.Transform({1..12}, each Text.From(_)),
        "MonthNum",
        "Amount FC"
    ),
    #"Added Custom3" = Table.AddColumn(#"Unpivoted Months", "Month Date New", each [Year] & "/"&[MonthNum]),
    #"Changed Type3" = Table.TransformColumnTypes(#"Added Custom3",{{"Month Date New", type date}}),
    #"Removed Columns2" = Table.RemoveColumns(#"Changed Type3",{"Month"}),
    #"Renamed Columns4" = Table.RenameColumns(#"Removed Columns2",{{"MonthNum", "Month"}}),
    #"Removed Columns4" = Table.RemoveColumns(#"Renamed Columns4",{"Amount"}),
    #"Renamed Columns5" = Table.RenameColumns(#"Removed Columns4",{{"Amount FC", "Amount"}}),
    #"Removed Columns5" = Table.RemoveColumns(#"Renamed Columns5",{"Month Date"}),
    #"Renamed Columns6" = Table.RenameColumns(#"Removed Columns5",{{"Month Date New", "Month Date"}}),
    #"Changed Type4" = Table.TransformColumnTypes(#"Renamed Columns6",{{"Amount", Currency.Type}}),
    #"Filtered Rows" = Table.SelectRows(#"Changed Type4", each [Amount] <> 0)
in
    #"Filtered Rows";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "fact_costs_cbn_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared fact_costs_cbn = let
  Source = Table.Combine({fact_costs_cbn_plan, fact_costs_cbn_actuals, fact_costs_cbn_fc, fact_costs_cbn_py}),
  #"Merged Queries" = Table.NestedJoin(Source, {"WBS Element"}, map_wbs, {"WBS Element"}, "dim_wbs", JoinKind.LeftOuter),
  #"Expanded dim_wbs" = Table.ExpandTableColumn(#"Merged Queries", "dim_wbs", {"Change Run Indicator"}, {"Change Run Indicator"}),
  #"Replaced Value" = Table.ReplaceValue(#"Expanded dim_wbs", null, "Not assigned", Replacer.ReplaceValue, {"Change Run Indicator"}),
  #"Merged Queries2" = Table.NestedJoin(#"Replaced Value", {"Company Code"}, dim_company, {"Company Code"}, "dim_company", JoinKind.LeftOuter),
  #"Expanded dim_company" = Table.ExpandTableColumn(#"Merged Queries2", "dim_company", {"Country 2025", "Country 2026"}, {"Country 2025", "Country 2026"}),
  #"Changed Type" = Table.TransformColumnTypes(#"Expanded dim_company", {{"Year", Int64.Type}}),
  #"Added Custom" = Table.AddColumn(#"Changed Type", "Country", each if [Year] < 2026 then [Country 2025] else [Country 2026]),
  #"Filtered Rows" = Table.SelectRows(#"Added Custom", each [Country] <> "AZ Serv"),
  #"Removed Columns" = Table.RemoveColumns(#"Filtered Rows", {"Country 2025", "Country 2026", "Country"}),
  #"Changed Type1" = Table.TransformColumnTypes(#"Removed Columns", {{"Year", type text}}),
  #"Added Custom1" = Table.AddColumn(#"Changed Type1", "Profit Center Key", each [Year] & "-" & [Profit Center]),
  #"Changed Type2" = Table.TransformColumnTypes(#"Added Custom1", {{"Cost Element", type text}}),

  // Build full VAT lookup table once via cross join + compound key
  VATElementsWithDummy = Table.AddColumn(map_cbn_vat_elements, "dummy", each 1),
  VATSplitsWithDummy = Table.AddColumn(map_cbn_vat_splits, "dummy", each 1),
  VATCross = Table.Join(VATElementsWithDummy, {"dummy"}, VATSplitsWithDummy, {"dummy"}, JoinKind.Inner),
  VATFull = Table.AddColumn(
      Table.RemoveColumns(VATCross, {"dummy"}),
      "VAT Key", each [Cost Element] & "-" & [Year]),

  // Add VAT lookup key to fact rows
  #"Added VAT Key" = Table.AddColumn(#"Changed Type2", "VAT Key",
      each if ([Amount Type] = "Plan" or [Amount Type] = "FC")
          then [Cost Element] & "-" & Text.From(Number.FromText([Year]) - 1)
          else [Cost Element] & "-" & [Year]),

  // Single join on compound key
  #"Merged VAT" = Table.NestedJoin(#"Added VAT Key", {"VAT Key"},
      VATFull, {"VAT Key"}, "vat", JoinKind.LeftOuter),
  #"Expanded VAT" = Table.ExpandTableColumn(#"Merged VAT", "vat",
      {"New Cost Element", "New Cost Element Name", "Split"},
      {"New Cost Element", "New Cost Element Name", "Split"}),
  #"Added Amount VAT" = Table.AddColumn(#"Expanded VAT", "Amount VAT",
      each if [New Cost Element] <> null
          then [Amount] * [Split]
          else null),

  // map_cbn_main join
  #"Merged Queries1" = Table.NestedJoin(#"Added Amount VAT", {"Cost Element"}, map_cbn_main, {"Cost Element"}, "map_cbn_main", JoinKind.LeftOuter),
  #"Expanded map_cbn_main" = Table.ExpandTableColumn(#"Merged Queries1", "map_cbn_main",
      {"CbN - Revised categorization", "Consolidate into", "TO-BE P&L - L2","AMOS REP - L2"},
      {"CbN - Revised categorization", "Consolidate into", "TO-BE P&L - L2", "AMOS REP - L2"}),
  #"Renamed Columns" = Table.RenameColumns(#"Expanded map_cbn_main", {{"Consolidate into", "Consolidated Cost Element"}}),
  #"Added Custom4" = Table.AddColumn(#"Renamed Columns", "Final Cost Element",
      each if [Consolidated Cost Element] = null or [Consolidated Cost Element] = ""
          then if [New Cost Element] <> null then [New Cost Element] else [Cost Element]
          else [Consolidated Cost Element]),
  #"Added Custom5" = Table.AddColumn(#"Added Custom4", "Final Amount",
      each if [New Cost Element] <> null
          then [Amount VAT]
          else if [Consolidated Cost Element] <> null and [Consolidated Cost Element] <> ""
          then [Amount]
          else [Amount]),
  #"Removed Columns1" = Table.RemoveColumns(#"Added Custom5",
      {"Amount", "VAT Key", "New Cost Element", "New Cost Element Name",
       "Split", "Amount VAT", "Consolidated Cost Element"}),
  #"Renamed Columns1" = Table.RenameColumns(#"Removed Columns1",
      {{"Cost Element", "Cost Element Old"}, {"Cost Element Name", "Cost Element Old Name"},
       {"Final Cost Element", "Cost Element"}, {"Final Amount", "Amount"}}),
  #"Changed Type3" = Table.TransformColumnTypes(#"Renamed Columns1", {{"Amount", Currency.Type}}),

  // Save initial CRI
  #"Renamed columns 2" = Table.RenameColumns(#"Changed Type3", {{"Change Run Indicator", "Change Run Indicator Intial"}}),
  #"Added CRI Base" = Table.AddColumn(#"Renamed columns 2", "Change Run Indicator", each [#"Change Run Indicator Intial"]),

  // Fast CRI corrections via three joins (one per Match Type)
  CorrCompanyCode = Table.SelectRows(map_cri_corrections, each [#"Match Type"] = "Company Code"),
  CorrProfitCenter = Table.SelectRows(map_cri_corrections, each [#"Match Type"] = "Profit Center"),
  CorrWBSElement = Table.SelectRows(map_cri_corrections, each [#"Match Type"] = "WBS Element"),

  // Join 1: Company Code corrections
  #"Join CorrCC" = Table.NestedJoin(#"Added CRI Base",
      {"Company Code", "Year", "Amount Type"},
      Table.RenameColumns(CorrCompanyCode, {{"Match Value", "Company Code"}}),
      {"Company Code", "Year", "Amount Type"},
      "corr_cc", JoinKind.LeftOuter),
  #"Expand CorrCC" = Table.ExpandTableColumn(#"Join CorrCC", "corr_cc",
      {"Exclude CbN", "Current CRI", "Target CRI"},
      {"CC Exclude CbN", "CC Current CRI", "CC Target CRI"}),
  #"Apply CorrCC" = Table.AddColumn(#"Expand CorrCC", "CRI After CC",
      each if [CC Target CRI] = null then [Change Run Indicator]
           else if [CC Exclude CbN] <> null and [#"CbN - Revised categorization"] = [CC Exclude CbN] then [Change Run Indicator]
           else if [CC Current CRI] <> null and [Change Run Indicator] <> [CC Current CRI] then [Change Run Indicator]
           else [CC Target CRI]),
  #"Clean CorrCC" = Table.RemoveColumns(#"Apply CorrCC",
      {"Change Run Indicator", "CC Exclude CbN", "CC Current CRI", "CC Target CRI"}),
  #"Rename CorrCC" = Table.RenameColumns(#"Clean CorrCC", {{"CRI After CC", "Change Run Indicator"}}),

  // Join 2: Profit Center corrections
  #"Join CorrPC" = Table.NestedJoin(#"Rename CorrCC",
      {"Profit Center", "Year", "Amount Type"},
      Table.RenameColumns(CorrProfitCenter, {{"Match Value", "Profit Center"}}),
      {"Profit Center", "Year", "Amount Type"},
      "corr_pc", JoinKind.LeftOuter),
  #"Expand CorrPC" = Table.ExpandTableColumn(#"Join CorrPC", "corr_pc",
      {"Exclude CbN", "Current CRI", "Target CRI"},
      {"PC Exclude CbN", "PC Current CRI", "PC Target CRI"}),
  #"Apply CorrPC" = Table.AddColumn(#"Expand CorrPC", "CRI After PC",
      each if [PC Target CRI] = null then [Change Run Indicator]
           else if [PC Exclude CbN] <> null and [#"CbN - Revised categorization"] = [PC Exclude CbN] then [Change Run Indicator]
           else if [PC Current CRI] <> null and [Change Run Indicator] <> [PC Current CRI] then [Change Run Indicator]
           else [PC Target CRI]),
  #"Clean CorrPC" = Table.RemoveColumns(#"Apply CorrPC",
      {"Change Run Indicator", "PC Exclude CbN", "PC Current CRI", "PC Target CRI"}),
  #"Rename CorrPC" = Table.RenameColumns(#"Clean CorrPC", {{"CRI After PC", "Change Run Indicator"}}),

  // Join 3: WBS Element corrections
  #"Join CorrWBS" = Table.NestedJoin(#"Rename CorrPC",
      {"WBS Element", "Year", "Amount Type"},
      Table.RenameColumns(CorrWBSElement, {{"Match Value", "WBS Element"}}),
      {"WBS Element", "Year", "Amount Type"},
      "corr_wbs", JoinKind.LeftOuter),
  #"Expand CorrWBS" = Table.ExpandTableColumn(#"Join CorrWBS", "corr_wbs",
      {"Exclude CbN", "Current CRI", "Target CRI"},
      {"WBS Exclude CbN", "WBS Current CRI", "WBS Target CRI"}),
  #"Apply CorrWBS" = Table.AddColumn(#"Expand CorrWBS", "CRI After WBS",
      each if [WBS Target CRI] = null then [Change Run Indicator]
           else if [WBS Exclude CbN] <> null and [#"CbN - Revised categorization"] = [WBS Exclude CbN] then [Change Run Indicator]
           else if [WBS Current CRI] <> null and [Change Run Indicator] <> [WBS Current CRI] then [Change Run Indicator]
           else [WBS Target CRI]),
  #"Clean CorrWBS" = Table.RemoveColumns(#"Apply CorrWBS",
      {"Change Run Indicator", "WBS Exclude CbN", "WBS Current CRI", "WBS Target CRI"}),
  #"Rename CorrWBS" = Table.RenameColumns(#"Clean CorrWBS", {{"CRI After WBS", "Change Run Indicator"}}),

  // Final steps
  #"Changed column type" = Table.TransformColumnTypes(#"Rename CorrWBS", {{"Cost Element", type text}}),
  #"Trimmed text" = Table.TransformColumns(#"Changed column type", {{"Cost Element", each Text.Trim(_), type text}}),
  #"Cleaned text" = Table.TransformColumns(#"Trimmed text", {{"Cost Element", each Text.Clean(_), type nullable text}}),
  #"Merged queries 1" = Table.NestedJoin(#"Cleaned text", {"Cost Element"}, dim_cost_elements, {"Cost Element ID"}, "dim_cost_elements_cbn", JoinKind.LeftOuter),
  #"Expanded dim_cost_elements_cbn" = Table.ExpandTableColumn(#"Merged queries 1", "dim_cost_elements_cbn",
      {"Group Nature", "Group Nature Short", "Sort"}, {"Group Nature", "Group Nature Short", "Sort"}),
  #"Transform columns" = Table.TransformColumnTypes(#"Expanded dim_cost_elements_cbn",
      {{"Company Code", type text}, {"Profit Center", type text}, {"Profit Center Name", type text},
       {"Cost Center", type text}, {"Cost Center Name", type text}, {"WBS Element", type text},
       {"WBS Element Name", type text}, {"Cost Element Old Name", type text}, {"File Name", type text},
       {"Month", type text}, {"Amount Type", type text}, {"Pl Type", type text},
       {"Profit Center Key", type text}, {"CbN - Revised categorization", type text},
       {"TO-BE P&L - L2", type text}, {"Cost Element", type text}, {"Group Nature", type text},
       {"Group Nature Short", type text}}),
  #"Replace errors" = Table.ReplaceErrorValues(#"Transform columns",
      {{"Company Code", null}, {"Profit Center", null}, {"Profit Center Name", null},
       {"Cost Center", null}, {"Cost Center Name", null}, {"WBS Element", null},
       {"WBS Element Name", null}, {"Cost Element Old Name", null}, {"File Name", null},
       {"Month", null}, {"Amount Type", null}, {"Pl Type", null}, {"Profit Center Key", null},
       {"CbN - Revised categorization", null}, {"TO-BE P&L - L2", null}, {"Cost Element", null},
       {"Group Nature", null}, {"Group Nature Short", null}}),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Replace errors", {{"Change Run Indicator", type text}}),
  #"Merged queries 2" = Table.NestedJoin(#"Changed column type 1", {"Cost Center"}, map_cost_center, {"Cost Center"}, "map_cost_center_current", JoinKind.LeftOuter),
  #"Expanded map_cost_center_current" = Table.ExpandTableColumn(#"Merged queries 2", "map_cost_center_current", {"Costcenter Typ 1"}, {"Costcenter Typ 1"})

in
  #"Expanded map_cost_center_current";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "fact_costs_restructuring_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared fact_costs_restructuring = let
  Source = Excel.Workbook(Web.Contents("https://allianzms.sharepoint.com/teams/AT0090-10144432/Shared%20Documents/01_Power%20BI/05_Group/01_Data/00_Master%20Data/Local%20Master%20Data.xlsx"), null, true),
  Navigation = Source{[Item = "fact_restructuring_costs", Kind = "Sheet"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(Navigation, [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"Cost Element", type text}, {"Cost Type", type text}, {"Amount", type text}, {"Change Run Indicator", type text}, {"Amount Type", type text}, {"Pl Type", type text}, {"Period", type text}})
in
  #"Changed column type";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "dim_date_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared dim_date = let
    // Define date range
    StartDate = #date(2016, 1, 1),
    EndDate   = #date(2028, 12, 31),

    // Create list of all days
    DateList = List.Dates(
        StartDate,
        Duration.Days(EndDate - StartDate) + 1,
        #duration(1,0,0,0)
    ),

    // Convert to table
    DateTable = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}),

    // Add core parts
    AddYear = Table.AddColumn(DateTable, "Year", each Date.Year([Date]), Int64.Type),
    AddQuarterNumber = Table.AddColumn(AddYear, "Quarter Number", each Date.QuarterOfYear([Date]), Int64.Type),
    AddQuarterName = Table.AddColumn(AddQuarterNumber, "Quarter Name", each "Q" & Text.From(Date.QuarterOfYear([Date]))),
    AddMonthNumberShort = Table.AddColumn(AddQuarterName, "Month Number Short", each Date.Month([Date]), Int64.Type),
    AddMonthNameShort = Table.AddColumn(AddMonthNumberShort, "Month Name Short", each Date.ToText([Date], "MMM", "en-US")),
    AddMonthService = Table.AddColumn(AddMonthNameShort, "Month Service", each Date.ToText([Date], "MMM yyyy", "en-US")),
    AddMonthNumber = Table.AddColumn(AddMonthService, "Month Number", each Number.FromText(Date.ToText([Date], "yyMM")), Int64.Type),

    // First day of month
    AddMonthDate = Table.AddColumn(AddMonthNumber, "Month Date", each #date(Date.Year([Date]), Date.Month([Date]), 1), type date),

    // Flags
    CurrentYYMM = Number.FromText(Date.ToText(DateTime.Date(DateTime.LocalNow()), "yyMM")),
    AddIsCurrentMonth = Table.AddColumn(AddMonthDate, "Is Current Month", each CurrentYYMM = Number.FromText(Date.ToText([Date], "yyMM")), type logical),
    AddIsPreviousMonth = Table.AddColumn(AddIsCurrentMonth, "Is Previous Month", each CurrentYYMM - 1 = Number.FromText(Date.ToText([Date], "yyMM")), type logical),
    AddIsCurrentYear = Table.AddColumn(AddIsPreviousMonth, "Is Current Year", each Date.Year(DateTime.Date(DateTime.LocalNow())) = Date.Year([Date]), type logical),

    // Reorder for clarity
    Result = Table.ReorderColumns(AddIsCurrentYear,{
        "Date","Year","Quarter Number","Quarter Name","Month Number Short","Month Name Short",
        "Month Service","Month Number","Month Date","Is Current Month","Is Previous Month","Is Current Year"
    }),
  #"Changed column type" = Table.TransformColumnTypes(Result, {{"Date", type text}, {"Quarter Name", type text}, {"Month Name Short", type text}, {"Month Service", type text}}),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Changed column type", {{"Date", type date}})
in
    #"Changed column type 1";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "dim_company_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared dim_company = let
  Source = Excel.Workbook(Web.Contents("https://allianzms.sharepoint.com/teams/AT0090-10144432/Shared%20Documents/01_Power%20BI/05_Group/01_Data/00_Master%20Data/Local%20Master%20Data.xlsx"), null, true),
  Navigation = Source{[Item = "Locations", Kind = "Sheet"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(Navigation, [PromoteAllScalars = true]),
  #"Changed Type" = Table.TransformColumnTypes(#"Promoted headers", {{"Company Code", type text}, {"Location", type text}, {"Sort", Int64.Type}, {"Sort Flag", Int64.Type}}),
  #"Added Custom" = Table.AddColumn(#"Changed Type", "Flag", each "https://flagpedia.net/data/flags/w1160/" & Text.Lower([Country Code]) & ".webp"),
  #"Added Custom1" = Table.AddColumn(#"Added Custom", "Flag Unicode", each if Text.Length([Country Code]) = 2 then
           Character.FromNumber(127397 + Character.ToNumber(Text.At([Country Code], 0))) &
           Character.FromNumber(127397 + Character.ToNumber(Text.At([Country Code], 1)))
       else
           null),
  #"Transform columns" = Table.TransformColumnTypes(#"Added Custom1", {{"Company Name", type text}, {"Country Code", type text}, {"Cost Clasification", type text}, {"Pillar", type text}, {"Pillar Short", type text}, {"Country 2025", type text}, {"Country 2026", type text}, {"Flag", type text}, {"Flag Unicode", type text}}),
  #"Replace errors" = Table.ReplaceErrorValues(#"Transform columns", {{"Company Name", null}, {"Country Code", null}, {"Cost Clasification", null}, {"Pillar", null}, {"Pillar Short", null}, {"Country 2025", null}, {"Country 2026", null}, {"Flag", null}, {"Flag Unicode", null}})
in
  #"Replace errors";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "dim_cost_elements_cbn_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared dim_cost_elements = let
  Source = Excel.Workbook(Web.Contents("https://allianzms.sharepoint.com/teams/AT0090-10144432/Shared%20Documents/01_Power%20BI/05_Group/01_Data/00_Master%20Data/Local%20Master%20Data.xlsx"), null, true),
  Navigation = Source{[Item = "dim_cost_elements", Kind = "Sheet"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(Navigation, [PromoteAllScalars = true]),
  #"Removed Duplicates" = Table.Distinct(#"Promoted headers", {"Cost Element ID"}),
  #"Merged Queries" = Table.NestedJoin(#"Removed Duplicates", {"Group Nature"}, map_cbn_sort, {"Group Nature"}, "map_cbn_sort", JoinKind.LeftOuter),
  #"Expanded map_cbn_sort" = Table.ExpandTableColumn(#"Merged Queries", "map_cbn_sort", 
      {"Grouping CRI","Grouping CRI Aggregated", "Global Local Indicator Correction","Sort"}, 
      {"Grouping CRI", "Grouping CRI Aggregated", "Global Local Indicator Correction", "Sort"}),
  #"Transform columns" = Table.TransformColumnTypes(#"Expanded map_cbn_sort", {
      {"Cost Element ID", type text}, {"L0", type text}, {"L1", type text}, {"L2", type text}, 
      {" P&L - L0", type text}, {"TO-BE P&L - L1", type text}, {"TO-BE P&L - L2", type text}, 
      {"Create/ Delete/ Keep", type text}, {"New Cost Element Name", type text}, 
      {"Group Nature", type text}, {"Comments", type text},
      {"Grouping CRI", type text}, {"Sort", Int64.Type}}),
  #"Replace errors" = Table.ReplaceErrorValues(#"Transform columns", {
      {"Cost Element ID", null}, {"L0", null}, {"L1", null}, {"L2", null}, 
      {" P&L - L0", null}, {"TO-BE P&L - L1", null}, {"TO-BE P&L - L2", null}, 
      {"Create/ Delete/ Keep", null}, {"New Cost Element Name", null}, 
      {"Group Nature", null}, {"Comments", null},
      {"Grouping CRI", null}, {"Sort", null}}),
  #"Renamed columns" = Table.RenameColumns(#"Replace errors", {{" P&L - L0", "P&L - L0"}}),
  #"Trimmed text" = Table.TransformColumns(#"Renamed columns", {{"Cost Element ID", each Text.Trim(_), type nullable text}}),
  #"Cleaned text" = Table.TransformColumns(#"Trimmed text", {{"Cost Element ID", each Text.Clean(_), type nullable text}})
in
  #"Cleaned text";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "dim_profit_centers_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared dim_profit_centers = let
    Source = SharePoint.Files("https://allianzms.sharepoint.com/teams/AT0090-10144432/", [ApiVersion = 15]),
    #"Filtered rows" = Table.SelectRows(Source, each ([Folder Path] = "https://allianzms.sharepoint.com/teams/AT0090-10144432/Shared Documents/01_Power BI/05_Group/01_Data/01_SAP BW/03_Master Data/2026/") and ([Name] = "2026_Master Data Reporting SAP_PC.xlsx")),
    #"Removed Other Columns4" = Table.SelectColumns(#"Filtered rows",{"Content", "Name", "Date modified"}),
    #"Added Custom1" = Table.AddColumn(#"Removed Other Columns4", "Extracted Data", each Table.SelectRows(Excel.Workbook([Content]), each [Item] = "Sheet1")),
    #"Expanded Extracted Data2" = Table.ExpandTableColumn(#"Added Custom1", "Extracted Data", {"Data"}, {"Data"}),
  #"Expanded Data 1" = Table.ExpandTableColumn(#"Expanded Extracted Data2", "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22", "Column23"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22", "Column23"}),
    #"Added Custom2" = Table.AddColumn(#"Expanded Data 1", "File Name", each if [Column1] = "Profit Center" then "File Name" else [Name]),
    #"Added Custom4" = Table.AddColumn(#"Added Custom2", "Refresh Date", each if [Column1] = "Profit Center" then "Refresh Date" else [Date modified]),
  #"Removed columns" = Table.RemoveColumns(#"Added Custom4", {"Content", "Date modified", "Name"}),
    #"Promoted Headers" = Table.PromoteHeaders(#"Removed columns", [PromoteAllScalars=true]),
  #"Removed top rows" = Table.Skip(#"Promoted Headers", 1),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Removed top rows", {{"Refresh Date", type datetime}}),
  #"Added custom" = Table.AddColumn(#"Changed column type 1", "Year", each Text.Middle([File Name],0,4)),
  #"Added custom 1" = Table.AddColumn(#"Added custom", "CurrentYear", each Date.Year(DateTime.LocalNow())),
    #"Changed Type" = Table.TransformColumnTypes(#"Added custom 1",{{"Year", Int64.Type}, {"CurrentYear", Int64.Type}}),
  #"Filtered rows 1" = Table.SelectRows(#"Changed Type", each [#"CurrentYear"] = [Year]),
  #"Removed columns 1" = Table.RemoveColumns(#"Filtered rows 1", {"CurrentYear"}),
  #"Filtered rows 2" = Table.SelectRows(#"Removed columns 1", each ([Pillar] <> "Not assigned")),
  #"Changed column type" = Table.TransformColumnTypes(#"Filtered rows 2", {{"Profit Center", type text}, {"Profit Center Name", type text}, {"Valid From", type text}, {"Valid To", type text}, {"Person Responsible", type text}, {"Lock Indicator", type text}, {"Pillar", type text}, {"Profit Center Category", type text}, {"Division", type text}, {"Department", type text}, {"Status", type text}, {"Investment Type", type text}, {"Portfolio", type text}, {"Program Cluster", type text}, {"Program Cluster Name", type text}, {"Program", type text}, {"Program Name", type text}, {"Service Landscape", type text}, {"Service Landscape Name", type text}, {"Service Class", type text}, {"Service Class Name", type text}, {"Service Package", type text}, {"Service Package Name", type text}, {"File Name", type text}, {"Refresh Date", type text}, {"Year", type text}}),
  #"Trimmed text" = Table.TransformColumns(#"Changed column type", {{"Profit Center", each Text.Trim(_), type nullable text}}),
  #"Cleaned text" = Table.TransformColumns(#"Trimmed text", {{"Profit Center", each Text.Clean(_), type nullable text}}),
    #"Merged Queries" = Table.NestedJoin(#"Cleaned text", {"Profit Center"}, map_local_global, {"Profit center"}, "map_local_global", JoinKind.LeftOuter),
    #"Expanded map_local_global" = Table.ExpandTableColumn(#"Merged Queries", "map_local_global", {"Landing Group/OE", "Landing Zone 0", "Landing Zone 1", "Landing Zone 1 - Other"}, {"Landing Group/OE", "Landing Zone 0", "Landing Zone 1","Landing Zone 1 - Other"}),
  #"Filtered rows 3" = Table.SelectRows(#"Expanded map_local_global", each ([#"Landing Group/OE"] <> null)),
    #"Added Custom" = Table.AddColumn(#"Filtered rows 3", "Global Local Indicator", each if Text.Contains([#"Landing Group/OE"],"Group")  then "Global" else "Local"),
    #"Filtered Rows" = Table.SelectRows(#"Added Custom", each ([Profit Center] <> "#" and [Profit Center] <> "'")),
    #"Appended Query" = Table.Combine({#"Filtered Rows", dim_profit_centers_bw_archive}),
    #"Added Custom3" = Table.AddColumn(#"Appended Query", "Profit Center Key", each [Year] & "-" & [Profit Center]),
  #"Changed column type 2" = Table.TransformColumnTypes(#"Added Custom3", {{"Landing Group/OE", type text}, {"Landing Zone 0", type text}, {"Landing Zone 1", type text}, {"Global Local Indicator", type text}, {"Profit Center Key", type text}}),
  #"Merged queries 1" = Table.NestedJoin(#"Changed column type 2", {"Profit Center"}, map_target_service_cluster, {"Profit center"}, "map_target_service_cluster", JoinKind.LeftOuter),
  #"Expanded map_target_service_cluster" = Table.ExpandTableColumn(#"Merged queries 1", "map_target_service_cluster", {"Service Cluster - 1"}, {"Service Cluster - 1"}),
  #"Renamed columns" = Table.RenameColumns(#"Expanded map_target_service_cluster", {{"Service Cluster - 1", "Target Service Cluster"}}),
  #"Replaced value" = Table.ReplaceValue(#"Renamed columns", null, "Other", Replacer.ReplaceValue, {"Target Service Cluster"}),
  #"Changed column type 3" = Table.TransformColumnTypes(#"Replaced value", {{"Target Service Cluster", type text}, {"Landing Zone 1 - Other", type text}})
in
    #"Changed column type 3";
shared dim_profit_centers_bw_archive = let
    Source = SharePoint.Files("https://allianzms.sharepoint.com/teams/AT0090-10144432/", [ApiVersion = 15]),
    #"Filtered rows" = Table.SelectRows(Source, each ([Folder Path] = "https://allianzms.sharepoint.com/teams/AT0090-10144432/Shared Documents/01_Power BI/05_Group/01_Data/01_SAP BW/03_Master Data/2025/") and ([Name] = "2025_Master Data Reporting SAP_PC.xlsx")),
    #"Removed Other Columns4" = Table.SelectColumns(#"Filtered rows",{"Content", "Name", "Date modified"}),
    #"Added Custom1" = Table.AddColumn(#"Removed Other Columns4", "Extracted Data", each Table.SelectRows(Excel.Workbook([Content]), each [Item] = "Sheet1")),
    #"Expanded Extracted Data2" = Table.ExpandTableColumn(#"Added Custom1", "Extracted Data", {"Data"}, {"Data"}),
  #"Expanded Data 1" = Table.ExpandTableColumn(#"Expanded Extracted Data2", "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22", "Column23"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22", "Column23"}),
    #"Added Custom2" = Table.AddColumn(#"Expanded Data 1", "File Name", each if [Column1] = "Profit Center" then "File Name" else [Name]),
    #"Added Custom4" = Table.AddColumn(#"Added Custom2", "Refresh Date", each if [Column1] = "Profit Center" then "Refresh Date" else [Date modified]),
  #"Removed columns" = Table.RemoveColumns(#"Added Custom4", {"Content", "Date modified", "Name"}),
    #"Promoted Headers" = Table.PromoteHeaders(#"Removed columns", [PromoteAllScalars=true]),
  #"Removed top rows" = Table.Skip(#"Promoted Headers", 1),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Removed top rows", {{"Refresh Date", type datetime}}),
  #"Added custom" = Table.AddColumn(#"Changed column type 1", "Year", each Text.Middle([File Name],0,4)),
  #"Added custom 1" = Table.AddColumn(#"Added custom", "CurrentYear", each Date.Year(DateTime.LocalNow())),
    #"Changed Type" = Table.TransformColumnTypes(#"Added custom 1",{{"Year", Int64.Type}, {"CurrentYear", Int64.Type}}),
  #"Filtered rows 1" = Table.SelectRows(#"Changed Type", each [#"CurrentYear"] > [Year]),
  #"Removed columns 1" = Table.RemoveColumns(#"Filtered rows 1", {"CurrentYear"}),
  #"Filtered rows 2" = Table.SelectRows(#"Removed columns 1", each ([Pillar] <> "Not assigned")),
  #"Changed column type" = Table.TransformColumnTypes(#"Filtered rows 2", {{"Profit Center", type text}, {"Profit Center Name", type text}, {"Valid From", type text}, {"Valid To", type text}, {"Person Responsible", type text}, {"Lock Indicator", type text}, {"Pillar", type text}, {"Profit Center Category", type text}, {"Division", type text}, {"Department", type text}, {"Status", type text}, {"Investment Type", type text}, {"Portfolio", type text}, {"Program Cluster", type text}, {"Program Cluster Name", type text}, {"Program", type text}, {"Program Name", type text}, {"Service Landscape", type text}, {"Service Landscape Name", type text}, {"Service Class", type text}, {"Service Class Name", type text}, {"Service Package", type text}, {"Service Package Name", type text}, {"File Name", type text}, {"Refresh Date", type text}, {"Year", type text}}),
  #"Trimmed text" = Table.TransformColumns(#"Changed column type", {{"Profit Center", each Text.Trim(_), type nullable text}}),
  #"Cleaned text" = Table.TransformColumns(#"Trimmed text", {{"Profit Center", each Text.Clean(_), type nullable text}}),
    #"Merged Queries" = Table.NestedJoin(#"Cleaned text", {"Profit Center"}, map_local_global, {"Profit center"}, "map_local_global", JoinKind.LeftOuter),
    #"Expanded map_local_global" = Table.ExpandTableColumn(#"Merged Queries", "map_local_global", {"Landing Group/OE", "Landing Zone 0", "Landing Zone 1", "Landing Zone 1 - Other"}, {"Landing Group/OE", "Landing Zone 0", "Landing Zone 1","Landing Zone 1 - Other"}),
  #"Filtered rows 3" = Table.SelectRows(#"Expanded map_local_global", each ([#"Landing Group/OE"] <> null)),
    #"Added Custom" = Table.AddColumn(#"Filtered rows 3", "Global Local Indicator", each if Text.Contains([#"Landing Group/OE"],"Group")  then "Global" else "Local"),
    #"Filtered Rows" = Table.SelectRows(#"Added Custom", each ([Profit Center] <> "#" and [Profit Center] <> "'"))
in
    #"Filtered Rows";
shared map_wbs = let
    Source = SharePoint.Files("https://allianzms.sharepoint.com/teams/AT0090-10144432/", [ApiVersion = 15]),
  #"Filtered rows" = Table.SelectRows(Source, each ([Folder Path] = "https://allianzms.sharepoint.com/teams/AT0090-10144432/Shared Documents/01_Power BI/05_Group/01_Data/01_SAP BW/03_Master Data/2025/") and ([Name] = "2025_Master Data Reporting SAP_WBS.xlsx")),
    #"Removed Other Columns4" = Table.SelectColumns(#"Filtered rows",{"Content", "Name", "Date modified"}),
    #"Added Custom1" = Table.AddColumn(#"Removed Other Columns4", "Extracted Data", each Table.SelectRows(Excel.Workbook([Content]), each [Item] = "Sheet1")),
    #"Expanded Extracted Data2" = Table.ExpandTableColumn(#"Added Custom1", "Extracted Data", {"Data"}, {"Data"}),
  #"Expanded Data" = Table.ExpandTableColumn(#"Expanded Extracted Data2", "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17"}),
    #"Added Custom2" = Table.AddColumn(#"Expanded Data", "File Name", each if [Column1] = "WBS Element" then "File Name" else [Name]),
    #"Added Custom4" = Table.AddColumn(#"Added Custom2", "Refresh Date", each if [Column1] = "WBS Element" then "Refresh Date" else [Date modified]),
  #"Removed columns" = Table.RemoveColumns(#"Added Custom4", {"Content", "Date modified", "Name"}),
    #"Promoted Headers" = Table.PromoteHeaders(#"Removed columns", [PromoteAllScalars=true]),
  #"Removed top rows" = Table.Skip(#"Promoted Headers", 1),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Removed top rows", {{"Refresh Date", type datetime}}),
  #"Added custom" = Table.AddColumn(#"Changed column type 1", "Year", each Date.Year([Refresh Date])),
  #"Added custom 1" = Table.AddColumn(#"Added custom", "CurrentYear", each Date.Year(DateTime.LocalNow())),
  #"Filtered rows 1" = Table.SelectRows(#"Added custom 1", each [#"CurrentYear"] = [Year]),
  #"Removed columns 1" = Table.RemoveColumns(#"Filtered rows 1", {"CurrentYear"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Removed columns 1", {{"WBS Element", type text}, {"WBS Element Name", type text}, {"Change Run Indicator", type text}, {"Creation Date", type text}, {"Changed on", type text}, {"PSP System Status", type text}, {"Project Start Date", type text}, {"Project End Date", type text}, {"Company Code", type text}, {"Company Code Name", type text}, {"Profit Center", type text}, {"Profit Center Name", type text}, {"Responsible Cost Centre", type text}, {"Responsible Cost Centre Name", type text}, {"Short ID", type text}, {"Main WBS Element", type text}, {"Project Leader", type text}, {"File Name", type text}, {"Refresh Date", type text}, {"Year", type text}})
in
    #"Changed column type";
shared map_cbn_main = let
  Source = Excel.Workbook(Web.Contents("https://allianzms.sharepoint.com/teams/AT0090-10144432/Shared%20Documents/01_Power%20BI/05_Group/01_Data/00_Master%20Data/Local%20Master%20Data.xlsx"), null, true),
  Navigation = Source{[Item = "map_cbn_main", Kind = "Sheet"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(Navigation, [PromoteAllScalars = true]),
  #"Transform columns" = Table.TransformColumnTypes(#"Promoted headers", {{"Cost Element", type text}, {"Old Cost Element Name", type text}, {"CoE pre-24", type text}, {"AMOS REP - L0", type text}, {"AMOS REP - L1", type text}, {"AMOS REP - L2", type text}, {"New CoE", type text}, {" P&L - L0", type text}, {"TO-BE P&L - L1", type text}, {"TO-BE P&L - L2", type text}, {"Create/ Delete/ Keep", type text}, {"NEW COST ELEMENT NAME", type text}, {"CoE Renamed", type text}, {"Consolidation Logic", type text}, {"Exception - Consolidated From", type text}, {"Exception - Consolidated To", type text}, {"Complex Consolidation applied", type text}, {"CbN - Revised categorization (w/o Depr.)", type text}, {"CbN - Revised categorization", type text}, {"CoA Categories", type text}, {"CbN - Revised categorization (pre-ISC labor)", type text}, {"Consolidate into", type text}}),
  #"Replace errors" = Table.ReplaceErrorValues(#"Transform columns", {{"Cost Element", null}, {"Old Cost Element Name", null}, {"CoE pre-24", null}, {"AMOS REP - L0", null}, {"AMOS REP - L1", null}, {"AMOS REP - L2", null}, {"New CoE", null}, {" P&L - L0", null}, {"TO-BE P&L - L1", null}, {"TO-BE P&L - L2", null}, {"Create/ Delete/ Keep", null}, {"NEW COST ELEMENT NAME", null}, {"CoE Renamed", null}, {"Consolidation Logic", null}, {"Exception - Consolidated From", null}, {"Exception - Consolidated To", null}, {"Complex Consolidation applied", null}, {"CbN - Revised categorization (w/o Depr.)", null}, {"CbN - Revised categorization", null}, {"CoA Categories", null}, {"CbN - Revised categorization (pre-ISC labor)", null}, {"Consolidate into", null}}),
  #"Renamed columns" = Table.RenameColumns(#"Replace errors", {{" P&L - L0", "P&L - L0"}})
in
  #"Renamed columns";
shared map_cbn_vat_elements = let
    Source = Excel.Workbook(Web.Contents("https://allianzms.sharepoint.com/teams/AT0090-10144432/Shared%20Documents/01_Power%20BI/05_Group/01_Data/00_Master%20Data/Local%20Master%20Data.xlsx"), null, true),
  Navigation = Source{[Item = "map_cbn_vat_elements", Kind = "Sheet"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(Navigation, [PromoteAllScalars = true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted headers",{{"Cost Element", type text}})
in
    #"Changed Type";
shared map_cbn_vat_splits = let
    Source = Excel.Workbook(Web.Contents("https://allianzms.sharepoint.com/teams/AT0090-10144432/Shared%20Documents/01_Power%20BI/05_Group/01_Data/00_Master%20Data/Local%20Master%20Data.xlsx"), null, true),
  Navigation = Source{[Item = "map_cbn_vat_splits", Kind = "Sheet"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(Navigation, [PromoteAllScalars = true]),
  #"Unpivoted other columns" = Table.UnpivotOtherColumns(#"Promoted headers", {"New Cost Element", "New Cost Element Name"}, "Attribute", "Value"),
    #"Renamed Columns" = Table.RenameColumns(#"Unpivoted other columns",{{"Attribute", "Year"}, {"Value", "Split"}}),
  #"Changed column type" = Table.TransformColumnTypes(#"Renamed Columns", {{"New Cost Element", type text}}),
    #"Added Custom" = Table.AddColumn(#"Changed column type", "Cost Element VAT Key", each [Year] & "-" & [New Cost Element]),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Added Custom", {{"Split", type number}})
in
    #"Changed column type 1";
shared map_cbn_sort = let
    Source = Excel.Workbook(Web.Contents("https://allianzms.sharepoint.com/teams/AT0090-10144432/Shared%20Documents/01_Power%20BI/05_Group/01_Data/00_Master%20Data/Local%20Master%20Data.xlsx"), null, true),
  Navigation = Source{[Item = "map_cbn_sort", Kind = "Sheet"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(Navigation, [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"Group Nature", type text}, {"Grouping CRI", type text}, {"Grouping CRI Aggregated", type text}, {"Sort", Int64.Type}, {"Global Local Indicator Correction", type text}})
in
    #"Changed column type";
shared map_local_global = let
    Source = Excel.Workbook(Web.Contents("https://allianzms.sharepoint.com/teams/AT0090-10144432/Shared%20Documents/01_Power%20BI/05_Group/01_Data/00_Master%20Data/Local%20Master%20Data.xlsx"), null, true),
  Navigation = Source{[Item = "map_global_local", Kind = "Sheet"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(Navigation, [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"Profit center", type text}}),
  #"Trimmed text" = Table.TransformColumns(#"Changed column type", {{"Profit center", each Text.Trim(_), type nullable text}}),
  #"Cleaned text" = Table.TransformColumns(#"Trimmed text", {{"Profit center", each Text.Clean(_), type nullable text}}),
  #"Filtered rows" = Table.SelectRows(#"Cleaned text", each ([Pillar] <> "Not assigned"))
in
    #"Filtered rows";
shared dim_date_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[lakehouseName = "lh_finance_global_silver"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "dim_date", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared dim_company_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[lakehouseName = "lh_finance_global_silver"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "dim_company", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared dim_profit_centers_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[lakehouseName = "lh_finance_global_silver"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "dim_profit_centers", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "map_cbn_oh_allocation_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared map_cbn_oh_allocation = let
    Source = Excel.Workbook(Web.Contents("https://allianzms.sharepoint.com/teams/AT0090-10144432/Shared%20Documents/01_Power%20BI/05_Group/01_Data/00_Master%20Data/Local%20Master%20Data.xlsx"), null, true),
  Navigation = Source{[Item = "map_cbn_oh_allocation", Kind = "Sheet"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(Navigation, [PromoteAllScalars = true]),
    #"Removed Columns" = Table.RemoveColumns(#"Promoted headers",{"Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Removed Columns",{{"Other", type number}, {"External Service Provider", type number}, {"Hardware", type number}, {"Depreciations", type number}, {"Premises", type number}, {"Software", type number}, {"IT Consulting", type number}, {"HR Expenses", type number}}),
    #"Unpivoted Columns" = Table.UnpivotOtherColumns(#"Changed Type", {"Company Code", "Year", "Amount Type"}, "Attribute", "Value"),
    #"Renamed Columns" = Table.RenameColumns(#"Unpivoted Columns",{{"Attribute", "Cost By Nature"}, {"Value", "Split"}}),
    #"Changed Type1" = Table.TransformColumnTypes(#"Renamed Columns",{{"Amount Type", type text}, {"Year", type text}, {"Company Code", type text}}),
    #"Added Custom" = Table.AddColumn(#"Changed Type1", "Key", each [Year] & "-" & [Amount Type] & "-" & [Company Code]),
  #"Changed column type" = Table.TransformColumnTypes(#"Added Custom", {{"Key", type text}})
in
    #"Changed column type";
shared fact_costs_cbn_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[lakehouseName = "lh_finance_global_silver"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "fact_costs_cbn", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared dim_cost_elements_cbn_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[lakehouseName = "lh_finance_global_silver"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "dim_cost_elements", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared map_cri_corrections = let
  Source = Excel.Workbook(Web.Contents("https://allianzms.sharepoint.com/teams/AT0090-10144432/Shared%20Documents/01_Power%20BI/05_Group/01_Data/00_Master%20Data/Local%20Master%20Data.xlsx"), null, true),
  Navigation = Source{[Item = "map_cri_corrections", Kind = "Sheet"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(Navigation, [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"Match Type", type text}, {"Target CRI", type text}, {"Current CRI", type text}, {"Exclude CbN", type text}, {"Amount Type", type text}, {"Year", type text}, {"Match Value", type text}})
in
  #"Changed column type";
shared map_cbn_oh_allocation_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[lakehouseName = "lh_finance_global_silver"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "map_cbn_oh_allocation", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared map_target_service_cluster = let
  Source = Excel.Workbook(Web.Contents("https://allianzms.sharepoint.com/teams/AT0090-10144432/Shared%20Documents/01_Power%20BI/05_Group/01_Data/00_Master%20Data/Local%20Master%20Data.xlsx"), null, true),
  Navigation = Source{[Item = "map_target_service_cluster", Kind = "Sheet"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(Navigation, [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"Profit center", type text}}),
  #"Trimmed text" = Table.TransformColumns(#"Changed column type", {{"Profit center", each Text.Trim(_), type nullable text}}),
  #"Cleaned text" = Table.TransformColumns(#"Trimmed text", {{"Profit center", each Text.Clean(_), type nullable text}})
in
  #"Cleaned text";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "dim_cost_center_current_DataDestination", IsNewTarget = true], Settings = [Kind = "Manual", AllowCreation = true, ColumnSettings = [Mappings = {[SourceColumnName = "Cost Center", DestinationColumnName = "Cost Center"], [SourceColumnName = "Cost Center Name", DestinationColumnName = "Cost Center Name"], [SourceColumnName = "Company Code", DestinationColumnName = "Company Code"], [SourceColumnName = "Company Code Name", DestinationColumnName = "Company Code Name"], [SourceColumnName = "Profit Center", DestinationColumnName = "Profit Center"], [SourceColumnName = "Profit Center Name", DestinationColumnName = "Profit Center Name"], [SourceColumnName = "Pillar", DestinationColumnName = "Pillar"], [SourceColumnName = "Person Responsible", DestinationColumnName = "Person Responsible"], [SourceColumnName = "Department", DestinationColumnName = "Department"], [SourceColumnName = "Costcenter Typ 1", DestinationColumnName = "Costcenter Typ 1"], [SourceColumnName = "Costcenter Typ 2", DestinationColumnName = "Costcenter Typ 2"], [SourceColumnName = "Costcenter Typ 3", DestinationColumnName = "Costcenter Typ 3"], [SourceColumnName = "Lock Indicator  Actuals Primary Cost", DestinationColumnName = "Lock Indicator  Actuals Primary Cost"], [SourceColumnName = "Lock Indicator Actuals Secondary Cost", DestinationColumnName = "Lock Indicator Actuals Secondary Cost"], [SourceColumnName = "Valid From", DestinationColumnName = "Valid From"], [SourceColumnName = "Valid To", DestinationColumnName = "Valid To"], [SourceColumnName = "File Name", DestinationColumnName = "File Name"], [SourceColumnName = "Refresh Date", DestinationColumnName = "Refresh Date"], [SourceColumnName = "Year", DestinationColumnName = "Year"]}], DynamicSchema = true, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared map_cost_center = let
    Source = SharePoint.Files("https://allianzms.sharepoint.com/teams/AT0090-10144432/", [ApiVersion = 15]),
  #"Filtered rows" = Table.SelectRows(Source, each (Text.Contains([Folder Path], "https://allianzms.sharepoint.com/teams/AT0090-10144432/Shared Documents/01_Power BI/05_Group/01_Data/01_SAP BW/03_Master Data/") and (Text.Contains([Name], "SAP_CC.xlsx")))),
    #"Removed Other Columns4" = Table.SelectColumns(#"Filtered rows",{"Content", "Name", "Date modified"}),
    #"Added Custom1" = Table.AddColumn(#"Removed Other Columns4", "Extracted Data", each Table.SelectRows(Excel.Workbook([Content]), each [Item] = "Sheet1")),
    #"Expanded Extracted Data2" = Table.ExpandTableColumn(#"Added Custom1", "Extracted Data", {"Data"}, {"Data"}),
  #"Expanded Data" = Table.ExpandTableColumn(#"Expanded Extracted Data2", "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16"}),
    #"Added Custom2" = Table.AddColumn(#"Expanded Data", "File Name", each if [Column1] = "Cost Center" then "File Name" else [Name]),
    #"Added Custom4" = Table.AddColumn(#"Added Custom2", "Refresh Date", each if [Column1] = "Cost Center" then "Refresh Date" else [Date modified]),
  #"Removed columns" = Table.RemoveColumns(#"Added Custom4", {"Content", "Date modified", "Name"}),
    #"Promoted Headers" = Table.PromoteHeaders(#"Removed columns", [PromoteAllScalars=true]),
  #"Removed top rows" = Table.Skip(#"Promoted Headers", 1),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Removed top rows", {{"Refresh Date", type datetime}}),
  #"Added custom" = Table.AddColumn(#"Changed column type 1", "Year", each Text.Middle([File Name],0,4)),
  #"Added custom 1" = Table.AddColumn(#"Added custom", "CurrentYear", each Date.Year(DateTime.LocalNow())),
  #"Filtered rows 2" = Table.SelectRows(#"Added custom 1", each ([Company Code] <> "Company Code")),
  #"Changed column type 2" = Table.TransformColumnTypes(#"Filtered rows 2", {{"Year", type text}, {"CurrentYear", type text}}),
  #"Filtered rows 1" = Table.SelectRows(#"Changed column type 2", each [#"CurrentYear"] > [Year]),
  #"Removed columns 1" = Table.RemoveColumns(#"Filtered rows 1", {"CurrentYear"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Removed columns 1", {{"Cost Center", type text}, {"Cost Center Name", type text}, {"Company Code", type text}, {"Company Code Name", type text}, {"Profit Center", type text}, {"Profit Center Name", type text}, {"Pillar", type text}, {"Person Responsible", type text}, {"Department", type text}, {"Costcenter Typ 1", type text}, {"Costcenter Typ 2", type text}, {"Costcenter Typ 3", type text}, {"Lock Indicator  Actuals Primary Cost", type text}, {"Lock Indicator Actuals Secondary Cost", type text}, {"Valid From", type text}, {"Valid To", type text}, {"File Name", type text}, {"Refresh Date", type text}, {"Year", type text}})
in
    #"Changed column type";
shared dim_cost_center_current_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = Variable.ValueOrDefault("$(/**/vl_main/WorkspaceID)",  "c70edda0-25b6-4c4e-ad60-5a2466e1851f")]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = Variable.ValueOrDefault("$(/**/vl_main/SilverLakehouseID)",  "d6534641-b8b1-49f6-b4c4-5902e79b3a2b")]}[Data],
  TableNavigation = Navigation_2{[Id = "dim_cost_center_current", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared fact_costs_restructuring_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[lakehouseName = "lh_finance_global_silver"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "fact_costs_restructuring", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
