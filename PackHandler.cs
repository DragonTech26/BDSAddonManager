
using AddonManager.Forms;

namespace AddonManager
{
    public class PackHandler
    {
        ListView inactiveListView;
        ListView activeListView;
        List<ManifestInfo> inactiveList;
        List<ManifestInfo> activeList;

        ResultLists resultLists = new ResultLists();

        private string inactiveListName;
        private string activeListName;

        public void FormDeclaration(ListView iLV, ListView aLV, string inactiveListName, string activeListName)
        {
            inactiveListView = iLV;
            activeListView = aLV;
            inactiveList = resultLists.GetList(inactiveListName);
            activeList = resultLists.GetList(activeListName);

            this.inactiveListName = inactiveListName;
            this.activeListName = activeListName;
        }
        // Determines if a pack is excluded based on its name prefix
        public bool IsExcludedPack(string packName)
        {
            string[] excludedPrefixes = { "resourcePack.education", "resourcePack.vanilla", "behaviorPack.education", "behaviorPack.vanilla", "experimental" };

            foreach (var prefix in excludedPrefixes)
            {
                if (packName.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
                {
                    Logger.Log("Pack: " + packName + " was hidden. Toggle 'Hide default packs' in Settings to view! ");
                    return true;
                }
            }
            return false;
        }
        private void PopulateList(List<ManifestInfo> packList, ListView listView, string listName)
        {
            var imageList = new ImageList();
            imageList.ImageSize = new Size(32, 32);
            listView.SmallImageList = imageList;

            listView.BeginUpdate(); //Prevent the control from drawing until the EndUpdate method is called
            foreach (var pack in packList)
            {
                // Check if the checkbox is checked or if the pack name is not excluded
                if (!SettingsForm.hideDefaultPacks || !IsExcludedPack(pack.name))
                {
                    // If the item is already in the ListView don't add it again. 
                    bool itemExists = listView.Items.Cast<ListViewItem>().Any(item => item.Text == pack.name);
                    if (!itemExists)
                    {
                        if (pack.type == "resources" && listName != "inactiveRpList" && listName != "activeRpList")
                        {
                            pack.description = "⚠️ This is a resource pack!";
                        }
                        if ((pack.type == "data" || pack.type == "script") && listName != "inactiveBpList" && listName != "activeBpList")
                        {
                            pack.description = "⚠️ This is a behavior pack!";
                        }
                        ListViewItem item = new ListViewItem(pack.name);
                        item.ImageIndex = imageList.Images.Add(pack.pack_icon, Color.Transparent);
                        item.SubItems.Add(pack.description);
                        item.SubItems.Add(string.Join(", ", pack.version));
                        item.Tag = pack;
                        listView.Items.Add(item);
                        Logger.Log("Pack: " + pack.name + " was added to " + listView.Name);
                    }
                }
            }
            listView.EndUpdate(); //Enable the control to redraw
        }
        public void InactiveListPopulate()
        {
            PopulateList(inactiveList, inactiveListView, inactiveListName);
        }
        public void ActiveListPopulate()
        {
            PopulateList(activeList, activeListView, activeListName);
        }
        // Moves selected items from one ListView to another and updates the corresponding lists
        public void MoveSelectedItems(System.Windows.Forms.ListView source, System.Windows.Forms.ListView destination, List<ManifestInfo> sourceList, List<ManifestInfo> destinationList)
        {
            var itemsToMove = source.SelectedItems.Cast<ListViewItem>().ToList();
            foreach (ListViewItem item in itemsToMove)
            {
                var pack = (ManifestInfo)item.Tag;
                int imageIndex = destination.SmallImageList.Images.Add(source.SmallImageList.Images[item.ImageIndex], Color.Transparent);
                sourceList.Remove(pack);
                destinationList.Add(pack);

                if (activeList == ResultLists.activeRpList)
                {
                    ResultLists.currentlyActiveRpList.RemoveAll(p => p.pack_id == pack.pack_id);
                }
                if (activeList == ResultLists.activeBpList)
                {
                    ResultLists.currentlyActiveBpList.RemoveAll(p => p.pack_id == pack.pack_id);
                }

                ListViewItem newItem = new ListViewItem(item.Text, imageIndex);
                newItem.SubItems.Add(pack.description);
                newItem.SubItems.Add(string.Join(", ", pack.version));
                newItem.Tag = pack;
                source.Items.Remove(item);
                destination.Items.Add(newItem);
                Logger.Log("Pack: " + item.Text + " was moved to " + destination.Name);
            }
        }
        // Moves a selected item up or down within a ListView and updates the corresponding list
        public void MoveItemUpOrDown(System.Windows.Forms.ListView listView, List<ManifestInfo> list, int direction)
        {
            if (listView.SelectedItems.Count > 0)
            {
                var selectedItem = listView.SelectedItems[0];
                int index = selectedItem.Index;
                if (direction < 0 && index > 0 || direction > 0 && index < listView.Items.Count - 1)
                {
                    listView.Items.Remove(selectedItem);
                    listView.Items.Insert(index + direction, selectedItem);
                    list.Move(index, index + direction);
                }
                Logger.Log("Pack: " + selectedItem.Text + " was moved " + direction + " on side: " + listView.Name);
            }
        }
        // Handles the DragEnter event for the listview, allowing only files with .zip or .mcpack extensions to be dropped
        public void DragEnterHandler(DragEventArgs e)
        {
            //Check if the dragged data is a valid file
            if (e.Data.GetDataPresent(DataFormats.FileDrop))
            {
                var files = (string[])e.Data.GetData(DataFormats.FileDrop);
                if (files.All(file => Path.GetExtension(file).Equals(".zip", StringComparison.OrdinalIgnoreCase) || Path.GetExtension(file).Equals(".mcpack", StringComparison.OrdinalIgnoreCase)))
                {
                    e.Effect = DragDropEffects.Copy;
                }
                else { e.Effect = DragDropEffects.None; }
            }
            else { e.Effect = DragDropEffects.None; }
        }
        // Handles the DragDrop event for a control, which processes each file, updates the active and inactive lists, and repopulates the inactive list view
        public void DragDropHandler(DragEventArgs e, string location)
        {
            FileImport import = new FileImport();
            foreach (var filePath in (string[])e.Data.GetData(DataFormats.FileDrop))
            {
                var extension = Path.GetExtension(filePath);
                if (File.Exists(filePath) && (extension.Equals(".zip", StringComparison.OrdinalIgnoreCase) || extension.Equals(".mcpack", StringComparison.OrdinalIgnoreCase)))
                {
                    import.ProcessFile(filePath, location);
                }
            }
            inactiveList = resultLists.GetList(inactiveListName);
            activeList = resultLists.GetList(activeListName);
            inactiveListView.Items.Clear();
            InactiveListPopulate();
            Logger.Log("New pack was successfully imported and added!");
        }
        // Show a context menu with options for the right-clicked item.
        public void HandleMouseClick(object sender, MouseEventArgs e, Action<ListViewItem> openFolderAction, Action<ListViewItem> deletePackAction, Action importFileAction)
        {
            ListView listView = sender as ListView;
            ContextMenuStrip menu = new ContextMenuStrip();

            if (e.Button == MouseButtons.Right)
            {
                // Check if an item is selected
                if (listView.SelectedItems.Count > 0)
                {
                    menu.Items.Add("Open pack files", null, (sender, args) =>
                    {
                        foreach (ListViewItem item in listView.SelectedItems)
                        {
                            openFolderAction(item);
                        }
                    });
                    menu.Items.Add($"Delete {listView.SelectedItems.Count} pack(s)", null, (sender, args) =>
                    {
                        DialogResult result = MessageBox.Show($"Are you sure you want to delete these {listView.SelectedItems.Count} pack(s)? This action cannot be undone.", "Warning", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
                        if (result == DialogResult.Yes)
                        {
                            foreach (ListViewItem item in listView.SelectedItems)
                            {
                                deletePackAction(item);
                            }
                        }
                    });
                    menu.Items.Add("Import pack", null, (sender, args) =>
                    {
                        importFileAction();
                    });
                }
                else
                {
                    menu.Items.Add("Import pack", null, (sender, args) =>
                    {
                        importFileAction();
                    });
                }
                menu.Show(Cursor.Position);
            }
        }
        public void OpenFolder(ListViewItem item)
        {
            var pack = (ManifestInfo)item.Tag;
            string folderPath = pack.pack_folder;
            if (!string.IsNullOrEmpty(folderPath))
            {
                System.Diagnostics.Process.Start("explorer.exe", folderPath);
                Logger.Log("Pack location opened from context menu!");
            }
        }
        public void DeletePack(ListViewItem item)
        {
            var pack = (ManifestInfo)item.Tag;
            string folderPath = pack.pack_folder;

            if (Directory.Exists(folderPath))
            {
                try
                {
                    Directory.Delete(folderPath, true);
                    item.Remove();

                    if (inactiveList.Contains(pack))
                    {
                        inactiveList.Remove(pack);
                    }
                    else if (activeList.Contains(pack))
                    {
                        activeList.Remove(pack);
                    }
                }
                catch (IOException ioEx)
                {
                    MessageBox.Show($"An error occurred while trying to delete the folder: {ioEx.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    Logger.Log("Something happened and the pack was unable to be deleted.", "ERROR");
                }
                catch (UnauthorizedAccessException unAuthEx)
                {
                    MessageBox.Show($"You do not have permission to delete this folder: {unAuthEx.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    Logger.Log("Invalid permissions to delete pack.", "ERROR");
                }
            }
            else
            {
                MessageBox.Show("The directory does not exist.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                Logger.Log("The directory was probably manually removed or renamed. Pack could not be deleted (or found).", "ERROR");
            }
            Logger.Log("Pack: " + pack.name + " was deleted from the disk!");
        }
        public void ImportPack(string location) 
        {
            FileImport import = new FileImport();
            using (OpenFileDialog openFileDialog = new OpenFileDialog())
            {
                openFileDialog.Filter = "Addon files (*.mcpack;*.mcaddon;*.zip)|*.mcpack;*.mcaddon;*.zip|All files (*.*)|*.*";

                if (openFileDialog.ShowDialog() == DialogResult.OK)
                {
                   string filePath = openFileDialog.FileName;
                   import.ProcessFile(filePath, location);
                }
            }
        }        
    }
}