using System.Diagnostics;
using System.Text.Json;
using System.Text.RegularExpressions;
using AddonManager.Forms;

namespace AddonManager
{
    public class ManifestInfo
    {
        public string? pack_folder { get; set; }
        public string? name { get; set; }
        public string? description { get; set; }
        public Guid? pack_id { get; set; }
        public int[]? version { get; set; }
        public Image? pack_icon { get; set; }
        public string? type { get; set; }
    }
    public class ResultLists
    {
        public static List<ManifestInfo>? rpList { get; set; } = new List<ManifestInfo>(); // List of all detected resource packs
        public static List<ManifestInfo>? bpList { get; set; } = new List<ManifestInfo>(); // List of all detected behavior packs
        public static List<ManifestInfo>? currentlyActiveRpList { get; set; } = new List<ManifestInfo>(); // Simple list of active resource packs (pack id, version)
        public static List<ManifestInfo>? currentlyActiveBpList { get; set; } = new List<ManifestInfo>(); // Simple list of active behavior packs (pack id, version)
        public static List<ManifestInfo>? activeRpList { get; set; } = new List<ManifestInfo>(); // List of currently active resource packs (full - all data)
        public static List<ManifestInfo>? activeBpList { get; set; } = new List<ManifestInfo>(); // List of currently active behavior packs (full - all data)
        public static List<ManifestInfo>? inactiveRpList { get; set; } = new List<ManifestInfo>(); // List of currently inactive resource packs (full - all data)
        public static List<ManifestInfo>? inactiveBpList { get; set; } = new List<ManifestInfo>(); // List of currently inactive behavior packs (full - all data)

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
    public static class ListExtensions
    {
        // Extension method to move items in a list
        public static void Move<T>(this List<T> list, int oldIndex, int newIndex)
        {
            T item = list[oldIndex];
            list.RemoveAt(oldIndex);
            list.Insert(newIndex, item);
        }
    }
    public class JsonParser
    {
        // Parses the world's resource and behavior pack JSON files
        public void ParseWorldJson()
        {
            // Define the paths to the resource and behavior pack JSON files
            string rpJsonFilePath = Path.Combine(DirectoryForm.worldLocation, "world_resource_packs.json");
            string bpJsonFilePath = Path.Combine(DirectoryForm.worldLocation, "world_behavior_packs.json");

            // Read the contents of the JSON files.
            string rpJsonContent = File.ReadAllText(rpJsonFilePath);
            string bpJsonContent = File.ReadAllText(bpJsonFilePath);

            // Parse the JSON content and populate the active resource and behavior pack lists
            ParseManifestJson(rpJsonContent, ResultLists.currentlyActiveRpList);
            ParseManifestJson(bpJsonContent, ResultLists.currentlyActiveBpList);

            Logger.Log("Active world .json packs have been parsed!");
        }
        // Parses a manifest JSON string and populates a list with the parsed data
        private void ParseManifestJson(string jsonContent, List<ManifestInfo> manifestList)
        {
            var manifestJson = JsonDocument.Parse(jsonContent);

            foreach (var entry in manifestJson.RootElement.EnumerateArray())
            {
                // Create a new ManifestInfo object and populate it with data from the JSON entry
                var manifestInfo = new ManifestInfo { pack_id = entry.GetProperty("pack_id").GetGuid(), version = entry.GetProperty("version").EnumerateArray().Select(element => element.GetInt32()).ToArray() };
                manifestList.Add(manifestInfo);
            }
            Logger.Log("Currently active lists have been populated!");
        }
        // Parses the pack folders at a given path and populates a list with the parsed data
        public void ParsePackFolder(string path, List<ManifestInfo> list)
        {
            Parallel.ForEach(Directory.GetDirectories(path), (directory) =>
                {
                    var manifestPath = Path.Combine(directory, "manifest.json");

                    if (File.Exists(manifestPath))
                    {
                        try
                        {
                            var manifestContent = File.ReadAllText(manifestPath);
                            var manifestJson = JsonDocument.Parse(manifestContent);
                            Image fallbackIcon = Properties.Resources.pack_icon_fallback;

                            // If the JSON content contains a 'header' property, collect the pack properties
                            if (manifestJson.RootElement.TryGetProperty("header", out var header))
                            {
                                var manifestInfo = new ManifestInfo
                                {
                                    pack_folder = directory,
                                    name = header.GetProperty("name").GetString(),
                                    description = header.GetProperty("description").GetString(),
                                    pack_id = header.GetProperty("uuid").GetGuid(),
                                    version = header.GetProperty("version").EnumerateArray().Select(element => element.GetInt32()).ToArray()
                                };
                                // Check if the JSON content contains a 'modules' property
                                if (manifestJson.RootElement.TryGetProperty("modules", out var modules))
                                {
                                    // Iterate over each object in the 'modules' array
                                    foreach (var module in modules.EnumerateArray())
                                    {
                                        // Get the 'type' property from each object in the 'modules' array
                                        if (module.TryGetProperty("type", out var type))
                                        {
                                            manifestInfo.type = type.GetString();
                                        }
                                    }
                                }
                                try
                                {
                                    // Attempt to load the pack icon.
                                    using (Image temp = Image.FromFile(Path.Combine(directory, "pack_icon.png")))
                                    {
                                        manifestInfo.pack_icon = new Bitmap(temp);
                                    }
                                }
                                catch (Exception)
                                {
                                    manifestInfo.pack_icon = fallbackIcon;
                                    Logger.Log("No pack icon was found for pack: " + manifestInfo.name);
                                }
                                lock (list) { list.Add(manifestInfo); }
                            }
                        }
                        catch (Exception ex)
                        {
                            Debug.WriteLine("Error parsing manifest: " + ex.Message);
                            Logger.Log("Invalid manifest file was found and was could not be parsed.", "WARN");
                        }
                    }
                }
            );
            StringCleaner(list);
            GetInactivePacks();
            GetActivePacks();
        }
        private void StringCleaner(List<ManifestInfo> list)
        {
            // Remove '§' symbol and the next character (Bedrock text modifier codes)
            if (!SettingsForm.disableStringCleaner)
            {
                string RemoveSectionSignAndNextChar(string input)
                {
                    return Regex.Replace(input, @"§.", string.Empty);
                }

                foreach (var manifestInfo in list)
                {
                    manifestInfo.name = RemoveSectionSignAndNextChar(manifestInfo.name);
                    manifestInfo.description = RemoveSectionSignAndNextChar(manifestInfo.description);
                }
                Logger.Log("Removed Bedrock color code modifiers from pack names!");
            }
            else
            {
                Logger.Log("Pack name cleaning has been disabled!");
            }
        }
        private void GetInactivePacks()
        {
            // Compares each pack in the full list with the active list. If a pack is not found in the active list (based on both pack_id and version), it is considered inactive and added to the inactive list
            ResultLists.inactiveRpList = ResultLists.rpList.Where(rp => !ResultLists.currentlyActiveRpList.Any(activeRp => activeRp.pack_id == rp.pack_id && Enumerable.SequenceEqual(activeRp.version, rp.version))).ToList();
            ResultLists.inactiveBpList = ResultLists.bpList.Where(bp => !ResultLists.currentlyActiveBpList.Any(activeBp => activeBp.pack_id == bp.pack_id && Enumerable.SequenceEqual(activeBp.version, bp.version))).ToList();
            Logger.Log("Inactive lists populated!");
        }
        private void GetActivePacks()
        {
            ResultLists.activeRpList = ResultLists.rpList.Where(rp => ResultLists.currentlyActiveRpList.Any(activeRp => activeRp.pack_id == rp.pack_id && Enumerable.SequenceEqual(activeRp.version, rp.version))).ToList();
            ResultLists.activeBpList = ResultLists.bpList.Where(bp => ResultLists.currentlyActiveBpList.Any(activeBp => activeBp.pack_id == bp.pack_id && Enumerable.SequenceEqual(activeBp.version, bp.version))).ToList();
            Logger.Log("Active lists populated!");
            SortAndFilterActiveRpList();
            SortAndFilterActiveBpList();
        }
        private void SortAndFilterActiveRpList()
        {
            // Create a HashSet for fast lookup of GUIDs in the currentlyActiveList
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
            // Create a temporary list to hold only the pack_id and version
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