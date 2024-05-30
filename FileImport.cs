
using System.IO.Compression;
using System.Text.Json;
using AddonManager.Forms;

namespace AddonManager
{
    public class FileImport
    {
        JsonParser parser = new JsonParser();

        public void ProcessPack(string filePath, string folderLocation)
        {
            Cursor.Current = Cursors.WaitCursor;
            var extension = Path.GetExtension(filePath);
            if (extension.Equals(".mcaddon", StringComparison.OrdinalIgnoreCase))
            {
                ProcessMcAddon(filePath, folderLocation);
            }
            else
            {
                ProcessOtherFiles(filePath, folderLocation);
            }
        }
        private void ProcessMcAddon(string filePath, string folderLocation)
        {
            // Extract the .mcaddon file to a temporary directory
            string tempFolder = Path.Combine(Path.GetTempPath(), Path.GetFileNameWithoutExtension(Path.GetRandomFileName()));
            using (var archive = ZipFile.OpenRead(filePath))
            {
                archive.ExtractToDirectory(tempFolder, true);
            }
            // Process each .mcpack file or directory in the temporary directory
            foreach (var file in Directory.GetFiles(tempFolder))
            {
                var fileExtension = Path.GetExtension(file);
                if (fileExtension.Equals(".mcpack", StringComparison.OrdinalIgnoreCase) || fileExtension.Equals(".zip", StringComparison.OrdinalIgnoreCase))
                {
                    ProcessOtherFiles(file, folderLocation);
                }
            }
            foreach (var directory in Directory.GetDirectories(tempFolder))
            {
                ProcessOtherFiles(directory, folderLocation);
            }
            Directory.Delete(tempFolder, true);
        }
        private void ProcessOtherFiles(string filePath, string folderLocation)
        {
            try
            {
                string extension = Path.GetExtension(filePath);
                if (extension.Equals(".zip", StringComparison.OrdinalIgnoreCase) || extension.Equals(".mcpack", StringComparison.OrdinalIgnoreCase) || Directory.Exists(filePath))
                {
                    string tempFolder = string.Empty;
                    string destFolder = string.Empty;

                    if (Directory.Exists(filePath))
                    {
                        tempFolder = filePath;
                    }
                    else
                    {
                        tempFolder = Path.Combine(Path.GetTempPath(), Path.GetFileNameWithoutExtension(Path.GetRandomFileName()));
                        using (var archive = ZipFile.OpenRead(filePath))
                        {
                            archive.ExtractToDirectory(tempFolder, true);
                        }
                    }
                    string manifestPath = Path.Combine(tempFolder, "manifest.json");
                    // Checks manifest and changes save directory if incorrect pack is imported
                    if (File.Exists(manifestPath))
                    {
                        var manifest = System.Text.Json.JsonSerializer.Deserialize<Dictionary<string, object>>(File.ReadAllText(manifestPath));
                        if (manifest.ContainsKey("modules"))
                        {
                            var modules = (JsonElement)manifest["modules"];
                            foreach (var module in modules.EnumerateArray())
                            {
                                if (module.TryGetProperty("type", out JsonElement typeElement))
                                {
                                    var type = typeElement.GetString();
                                    if (type == "resources")
                                    {
                                        destFolder = Path.Combine(DirectoryForm.rpLocation, Path.GetFileNameWithoutExtension(filePath));
                                        if (!DirectoryForm.rpLocation.Equals(folderLocation))
                                        {
                                            MessageBox.Show("You've input a resource pack on the behavior pack screen. The pack has been placed in the correct directory.", "Information", MessageBoxButtons.OK, MessageBoxIcon.Information);
                                        }
                                    }
                                    if (type == "data" || type == "script")
                                    {
                                        destFolder = Path.Combine(DirectoryForm.bpLocation, Path.GetFileNameWithoutExtension(filePath));
                                        if (!DirectoryForm.bpLocation.Equals(folderLocation))
                                        {
                                            MessageBox.Show("You've input a behavior pack on the resource pack screen. The pack has been placed in the correct directory.", "Information", MessageBoxButtons.OK, MessageBoxIcon.Information);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if (Directory.Exists(destFolder))
                    {
                        DialogResult result = MessageBox.Show("A folder with the same name already exists in the directory. Do you want to replace it?", "Existing pack detected!", MessageBoxButtons.YesNo, MessageBoxIcon.Error);
                        if (result == DialogResult.Yes)
                        {
                            try
                            {
                                Directory.Delete(destFolder, true);
                            }
                            catch (Exception ex)
                            {
                                MessageBox.Show($"An error occurred: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                                return;
                            }
                        }
                        else { return; }
                        Logger.Log("Replaced pack folder!");
                    }
                    if (!Directory.Exists(destFolder))
                    {
                        Directory.CreateDirectory(destFolder);
                    }
                    foreach (var dirPath in Directory.GetDirectories(tempFolder, "*", SearchOption.AllDirectories))
                    {
                        Directory.CreateDirectory(dirPath.Replace(tempFolder, destFolder));
                    }
                    foreach (var newPath in Directory.GetFiles(tempFolder, "*.*", SearchOption.AllDirectories))
                    {
                        File.Copy(newPath, newPath.Replace(tempFolder, destFolder), true);
                    }
                    if (!filePath.Equals(tempFolder))
                    {
                        Directory.Delete(tempFolder, true);
                    }
                    ResultLists.rpList.Clear();
                    ResultLists.bpList.Clear();
                    parser.ParsePackFolder(DirectoryForm.rpLocation, ResultLists.rpList);
                    parser.ParsePackFolder(DirectoryForm.bpLocation, ResultLists.bpList);
                }
                else
                {
                    MessageBox.Show("No valid pack found!", "Import Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    Logger.Log("No valid pack found!", "ERROR");
                }
            }
            catch (Exception)
            {
                MessageBox.Show("Please select a world first!", "Import Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                Logger.Log("Pack import failed because a world hasn't been selected yet!", "ERROR");
            }
            finally
            {
                Cursor.Current = Cursors.Default;
            }
        }
    }
}