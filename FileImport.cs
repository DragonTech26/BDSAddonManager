using AddonManager.Forms;
using System.IO.Compression;

namespace AddonManager
{
    public class FileImport
    {
        public void ProcessFile(string filePath, string folderLocation)
        {
            JsonParser parser = new JsonParser();
            try
            {
                using (var archive = ZipFile.OpenRead(filePath))
                {
                    var entry = archive.Entries.FirstOrDefault(e => Path.GetFileName(e.FullName).Equals("manifest.json", StringComparison.OrdinalIgnoreCase));
                    if (entry == null) return;
                    var zipFileName = Path.GetFileNameWithoutExtension(filePath);
                    var destFolder = Path.Combine(folderLocation, zipFileName);

                    if (Directory.Exists(destFolder)) //Add -copy if directory already exists to prevent accidental overwrites
                    {
                        destFolder += "-copy";
                    }
                    archive.ExtractToDirectory(destFolder, true);

                    var manifestDir = Directory.GetDirectories(destFolder, "*", SearchOption.AllDirectories).FirstOrDefault(dir => File.Exists(Path.Combine(dir, "manifest.json")));
                    if (manifestDir != null && manifestDir != destFolder)
                    {
                        foreach (var dirPath in Directory.GetDirectories(manifestDir, "*", SearchOption.AllDirectories)) //Move the contents of the subfolder to the root folder
                            Directory.Move(dirPath, dirPath.Replace(manifestDir, destFolder));
                        foreach (var newPath in Directory.GetFiles(manifestDir, "*.*", SearchOption.AllDirectories))
                            File.Move(newPath, newPath.Replace(manifestDir, destFolder));

                        Directory.Delete(manifestDir, true); //Delete the empty subfolder
                    }
                }
                ResultLists.rpList.Clear(); //Reset and parse the updated lists
                ResultLists.bpList.Clear();
                parser.ParsePackFolder(DirectoryForm.rpLocation, ResultLists.rpList);
                parser.ParsePackFolder(DirectoryForm.bpLocation, ResultLists.bpList);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Please select a world first!", "Import Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
    }
}
