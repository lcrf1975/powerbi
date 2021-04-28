// This file contains your Data Connector logic
section RNA;

[DataSource.Kind="RNA", Publish="RNA.Publish"]
shared RNA.Contents = (optional message as text) =>
    let
        _message = if (message <> null) then message else "(no message)",

        Body_Login = "{""username"":""lucianofontes@company.com"",""password"":""put your password here""}",

        Data_Login = Web.Contents ("https://api.aws.company.com/integration/v1/login", [Content = Text.ToBinary (Body_Login), Headers = [#"Content-Type"="application/json"]]),
        DataRecord_Login = Json.Document (Data_Login),

        Token = Record.Field (DataRecord_Login, "token"),

        BaseUrl = "https://api.aws.company.com/integration/v1/admin/locations?pageIndex=",
        PageLimit = 9999,
 
        GetPage = (Index) =>
            let 
                Options = [Headers=[ #"Authorization" = "Bearer " & Token ]],
                RawData = Web.Contents(BaseUrl & Number.ToText(Index), Options),
                Doc = Json.Document(RawData),
                Items = Doc [items]
            in  
                Items,

        Data = List.Generate (
            () => [P = 0, R = GetPage (0)],
            each List.Count([R]) > 0 and [P] < PageLimit,
            each [P = [P] + 1, R = GetPage ([P])],
            each [R]),

        Result = Table.FromList (Data, Splitter.SplitByNothing(), null, null, ExtraValues.Error)
        /*
        Expand1 = Table.ExpandListColumn (Result, "Column1"),
        Expand2 = Table.ExpandRecordColumn (Expand1, "Column1", {"identity", "locationType", "description", "version", "regionVisibility", "modifiedBy", "modifiedTimestamp", "address", "timeZone", "serviceArea", "coordinate", "depotInfo", "standardInstructions", "createdBy", "createdTimestamp", "geocodeAccuracy", "serviceLocationInfo", "accountIdentity"}, {"identity", "locationType", "description", "version", "regionVisibility", "modifiedBy", "modifiedTimestamp", "address", "timeZone", "serviceArea", "coordinate", "depotInfo", "standardInstructions", "createdBy", "createdTimestamp", "geocodeAccuracy", "serviceLocationInfo", "accountIdentity"}),
		Expand3 = Table.ExpandRecordColumn (Expand2, "identity", {"identifier", "entityKey"}, {"identifier", "entityKey"}),
        Expand4 = Table.ExpandRecordColumn (Expand3, "regionVisibility", {"visibleInAllRegions", "regionIdentities"}, {"visibleInAllRegions", "regionIdentities"}),
        Expand5 = Table.ExpandListColumn (Expand4, "regionIdentities"),
        Expand6 = Table.ExpandRecordColumn (Expand5, "regionIdentities", {"entityKey"}, {"regionIdentities.entityKey"}),
        Expand7 = Table.ExpandRecordColumn (Expand6, "address", {"addressLine1", "city", "stateOrProvince", "postalCode", "country"}, {"addressLine1", "city", "stateOrProvince", "postalCode", "country"}),
        Expand8 = Table.ExpandRecordColumn (Expand7, "serviceArea", {"polygonInfo", "areaType"}, {"polygonInfo", "areaType"}),
        Expand9 = Table.ExpandRecordColumn (Expand8, "polygonInfo", {"points"}, {"points"}),
        Expand10 = Table.ExpandRecordColumn (Expand9, "coordinate", {"latitude", "longitude"}, {"latitude", "longitude"}),
        Expand11 = Table.ExpandRecordColumn (Expand10, "depotInfo", {"openCloseTimes", "serviceTimeDetails"}, {"openCloseTimes", "serviceTimeDetails"}),
        Expand12 = Table.ExpandListColumn (Expand11, "openCloseTimes"),
        Expand13 = Table.ExpandRecordColumn (Expand12, "openCloseTimes", {"daysOfWeek", "startTimeOfDay", "endTimeOfDay"}, {"daysOfWeek", "startTimeOfDay", "endTimeOfDay"}),
        Expand14 = Table.ExpandListColumn (Expand13, "points")
        */
    in
        Result;

// Data Source Kind description
RNA = [
    Authentication = [
        // Key = [],
        // UsernamePassword = [],
        // Windows = [],
        Implicit = []
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// Data Source UI publishing description
RNA.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = RNA.Icons,
    SourceTypeImage = RNA.Icons
];

RNA.Icons = [
    Icon16 = { Extension.Contents("RNA16.png"), Extension.Contents("RNA20.png"), Extension.Contents("RNA24.png"), Extension.Contents("RNA32.png") },
    Icon32 = { Extension.Contents("RNA32.png"), Extension.Contents("RNA40.png"), Extension.Contents("RNA48.png"), Extension.Contents("RNA64.png") }
];
