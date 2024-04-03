using AddonManager.Forms;
using System.Diagnostics;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace AddonManager
{
    public class ManifestInfo
    {
        public string? pack_folder { get; set; }
        public string? name { get; set; }
        public string? description { get; set; }
        public Guid? pack_id { get; set; }
        public int[]? version { get; set; }
    }
    public class ResultLists
    {
        public static List<ManifestInfo>? rpList { get; set; } = new List<ManifestInfo>();       //list of all detected resource packs
        public static List<ManifestInfo>? bpList { get; set; } = new List<ManifestInfo>();       //list of all detected behavior packs
        public static List<ManifestInfo>? currentlyActiveRpList { get; set; } = new List<ManifestInfo>(); //simple list of active resource packs (pack id, version)
        public static List<ManifestInfo>? currentlyActiveBpList { get; set; } = new List<ManifestInfo>(); //simple list of active behavior packs (pack id, version)
        public static List<ManifestInfo>? activeRpList { get; set; } = new List<ManifestInfo>(); //list of currently active resource packs (full - all data)
        public static List<ManifestInfo>? activeBpList { get; set; } = new List<ManifestInfo>(); //list of currently active behavior packs (full - all data)
        public static List<ManifestInfo>? inactiveRpList { get; set; } = new List<ManifestInfo>(); //list of currently inactive resource packs (full - all data)
        public static List<ManifestInfo>? inactiveBpList { get; set; } = new List<ManifestInfo>(); //list of currently inactive behavior packs (full - all data)

        public List<ManifestInfo> GetList(string listName)
        {
            switch (listName)
            {
                case "inactiveRpList":
                    return inactiveRpList;
                case "inactiveBpList":
                    return inactiveBpList;
                case "activeRpList":
                    return activeRpList;
                case "activeBpList":
                    return activeBpList;
                default:
                    throw new ArgumentException("Invalid list name");
            }
        }
    }
    public static class ListExtensions //Extension method to move items in a list
    {
        public static void Move<T>(this List<T> list, int oldIndex, int newIndex)
        {
            T item = list[oldIndex];
            list.RemoveAt(oldIndex);
            list.Insert(newIndex, item);
        }
    }
    public class JsonParser
    {
        public void ParseWorldJson()
        {
            string rpJsonFilePath = Path.Combine(DirectoryForm.worldLocation, "world_resource_packs.json");
            string bpJsonFilePath = Path.Combine(DirectoryForm.worldLocation, "world_behavior_packs.json");

            string rpJsonContent = File.ReadAllText(rpJsonFilePath);
            string bpJsonContent = File.ReadAllText(bpJsonFilePath);

            ParseManifestJson(rpJsonContent, ResultLists.currentlyActiveRpList);
            ParseManifestJson(bpJsonContent, ResultLists.currentlyActiveBpList);
            Logger.Log("Active world .json packs have been parsed!");
        }
        private void ParseManifestJson(string jsonContent, List<ManifestInfo> manifestList) //parse and store active lists
        {
            var manifestJson = JsonDocument.Parse(jsonContent);

            foreach (var entry in manifestJson.RootElement.EnumerateArray())
            {
                var manifestInfo = new ManifestInfo
                {
                    pack_id = entry.GetProperty("pack_id").GetGuid(),
                    version = entry.GetProperty("version").EnumerateArray().Select(element => element.GetInt32()).ToArray()
                };
                manifestList.Add(manifestInfo);
            }
            Logger.Log("Currently active lists have been populated!");
        }
        public void ParsePackFolder(string path, List<ManifestInfo> list) //Example: DirectoryForm.rpLocation, ResultLists.rpList
        {
            foreach (var directory in Directory.GetDirectories(path, "*", SearchOption.AllDirectories))
            {
                var manifestPath = Path.Combine(directory, "manifest.json");

                if (File.Exists(manifestPath)) //Check if the manifest.json file exists
                {
                    try
                    {
                        var manifestContent = File.ReadAllText(manifestPath); //Read the content of the manifest file              
                        var manifestJson = JsonDocument.Parse(manifestContent); //Parse the JSON content of the manifest

                        if (manifestJson.RootElement.TryGetProperty("header", out var header)) //Check for the 'header' property in the JSON
                        {
                            var manifestInfo = new ManifestInfo //Create a new ManifestInfo object and get the properties from the JSON
                            {
                                pack_folder = directory,
                                name = header.GetProperty("name").GetString(),
                                description = header.GetProperty("description").GetString(),
                                pack_id = header.GetProperty("uuid").GetGuid(),
                                version = header.GetProperty("version").EnumerateArray().Select(element => element.GetInt32()).ToArray()
                            };
                            list.Add(manifestInfo); //Add the ManifestInfo object to the provided list
                        }
                    }
                    catch (Exception ex)
                    {
                        Debug.WriteLine("Error parsing manifest: " + ex.Message);
                        Logger.Log("Invalid manifest file was found and was could not be parsed.", "WARN");
                    }
                }
            }
            StringCleaner(list);
            GetInactivePacks();
            GetActivePacks();
        }
        private void StringCleaner(List<ManifestInfo> list) //removes '§' symbol and the next character (Bedrock text modifier codes)
        {
            string RemoveSectionSignAndNextChar(string input) { return Regex.Replace(input, @"§.", string.Empty); }

            foreach (var manifestInfo in list)
            {
                manifestInfo.name = RemoveSectionSignAndNextChar(manifestInfo.name);
                manifestInfo.description = RemoveSectionSignAndNextChar(manifestInfo.description);
            }
            Logger.Log("Removed Bedrock color code modifiers from pack names!");
        }
        private void GetActivePacks()
        {
            ResultLists.activeRpList = ResultLists.rpList.Where(rp => ResultLists.currentlyActiveRpList.Any(activeRp => activeRp.pack_id == rp.pack_id && Enumerable.SequenceEqual(activeRp.version, rp.version))).ToList();
            ResultLists.activeBpList = ResultLists.bpList.Where(bp => ResultLists.currentlyActiveBpList.Any(activeBp => activeBp.pack_id == bp.pack_id && Enumerable.SequenceEqual(activeBp.version, bp.version))).ToList();
            Logger.Log("Active lists populated!");
            SortAndFilterActiveRpList();
            SortAndFilterActiveBpList();
        }
        private void GetInactivePacks() //Compares each pack in the full list with the active list. If a pack is not found in the active list (based on both pack_id and version), it is considered inactive and added to the inactive list.
        {
            ResultLists.inactiveRpList = ResultLists.rpList.Where(rp => !ResultLists.currentlyActiveRpList.Any(activeRp => activeRp.pack_id == rp.pack_id && Enumerable.SequenceEqual(activeRp.version, rp.version))).ToList();
            ResultLists.inactiveBpList = ResultLists.bpList.Where(bp => !ResultLists.currentlyActiveBpList.Any(activeBp => activeBp.pack_id == bp.pack_id && Enumerable.SequenceEqual(activeBp.version, bp.version))).ToList();
            Logger.Log("Inactive lists populated!");
        }
        private void SortAndFilterActiveRpList() //Create a HashSet for fast lookup of GUIDs in the currentlyActiveList
        {
            var activePackIds = new HashSet<Guid>(ResultLists.currentlyActiveRpList.Select(pack => pack.pack_id.Value));
            ResultLists.activeRpList = ResultLists.activeRpList.Where(pack => activePackIds.Contains(pack.pack_id.Value)).OrderBy(pack => ResultLists.currentlyActiveRpList.FindIndex(activePack => activePack.pack_id.Value == pack.pack_id.Value)).ToList();
        }
        private void SortAndFilterActiveBpList()
        {   
            var activePackIds = new HashSet<Guid>(ResultLists.currentlyActiveBpList.Select(pack => pack.pack_id.Value));
            ResultLists.activeBpList = ResultLists.activeBpList.Where(pack => activePackIds.Contains(pack.pack_id.Value)).OrderBy(pack => ResultLists.currentlyActiveBpList.FindIndex(activePack => activePack.pack_id == pack.pack_id)).ToList();
        }
        public static void SaveToJson()
        {
            //Create a temporary list to hold only the pack_id and version
            var tempRpListToSave = ResultLists.activeRpList.Select(pack => new { pack.pack_id, pack.version }).ToList();
            var tempBpListToSave = ResultLists.activeBpList.Select(pack => new { pack.pack_id, pack.version }).ToList();

            string rpJsonPath = Path.Combine(DirectoryForm.worldLocation, "world_resource_packs.json");
            string bpJsonPath = Path.Combine(DirectoryForm.worldLocation, "world_behavior_packs.json");

            // Serialize and save the projected resource packs list
            string rpJsonData = JsonSerializer.Serialize(tempRpListToSave, new JsonSerializerOptions { WriteIndented = true });
            File.WriteAllText(rpJsonPath, rpJsonData);
            Logger.Log("world_resource_packs.json has been written to disk!");

            // Serialize and save the projected behavior packs list
            string bpJsonData = JsonSerializer.Serialize(tempBpListToSave, new JsonSerializerOptions { WriteIndented = true });
            File.WriteAllText(bpJsonPath, bpJsonData);
            Logger.Log("world_behavior_packs.json has been written to disk!");
        }
    }
}

