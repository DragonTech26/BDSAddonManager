using System.IO.Compression;
using AddonManager.Forms;

namespace AddonManager
{
    public class FileImport
    {
        // Processes a file at a given path, extracts its contents to a specified location, and updates the resource and behavior pack lists
        public void ProcessFile(string filePath, string folderLocation)
        {
            JsonParser parser = new JsonParser();
            try
            {
                Cursor.Current = Cursors.WaitCursor;
                using (var archive = ZipFile.OpenRead(filePath))
                {
                    var entry = archive.Entries.FirstOrDefault(e => Path.GetFileName(e.FullName).Equals("manifest.json", StringComparison.OrdinalIgnoreCase));
                    if (entry == null) 
                    {
                        MessageBox.Show("Invalid pack!", "Import Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return;
                    }
                    var zipFileName = Path.GetFileNameWithoutExtension(filePath);
                    var destFolder = Path.Combine(folderLocation, zipFileName);

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
                            }
                        }
                        else { return; }
                        Logger.Log("Replaced pack folder!");
                    }
                    archive.ExtractToDirectory(destFolder, true);

                    var manifestDir = Directory.GetDirectories(destFolder, "*", SearchOption.AllDirectories).FirstOrDefault(dir => File.Exists(Path.Combine(dir, "manifest.json")));
                    if (manifestDir != null && manifestDir != destFolder)
                    {
                        //Move the contents of the subfolder to the root folder
                        foreach (var dirPath in Directory.GetDirectories(manifestDir, "*", SearchOption.AllDirectories))
                            Directory.Move(dirPath, dirPath.Replace(manifestDir, destFolder));
                        foreach (var newPath in Directory.GetFiles(manifestDir, "*.*", SearchOption.AllDirectories))
                            File.Move(newPath, newPath.Replace(manifestDir, destFolder));
                        //Delete the empty subfolder
                        Directory.Delete(manifestDir, true);
                    }
                }
                // Reset and parse the updated lists
                ResultLists.rpList.Clear();
                ResultLists.bpList.Clear();
                parser.ParsePackFolder(DirectoryForm.rpLocation, ResultLists.rpList);
                parser.ParsePackFolder(DirectoryForm.bpLocation, ResultLists.bpList);
                Cursor.Current = Cursors.Default;
            }
            catch (Exception)
            {
                MessageBox.Show("Please select a world first!", "Import Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                Logger.Log("Pack import failed because a world hasn't been selected yet!", "ERROR");
            }
        }
    }
}