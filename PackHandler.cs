
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
        public void InactiveListPopulate()
        {
            var imageList = new ImageList();
            imageList.ImageSize = new Size(32, 32);
            inactiveListView.SmallImageList = imageList;

            inactiveListView.BeginUpdate(); //Prevent the control from drawing until the EndUpdate method is called
            foreach (var pack in inactiveList)
            {
                // Check if the checkbox is checked or if the pack name is not excluded
                if (!Program.hideDefaultPacks || !IsExcludedPack(pack.name)) 
                {
                    // If the item is already in the ListView don't add it again. 
                    bool itemExists = inactiveListView.Items.Cast<ListViewItem>().Any(item => item.Text == pack.name); 
                    if (!itemExists)
                    {
                        ListViewItem item = new ListViewItem(pack.name);
                        item.ImageIndex = imageList.Images.Add(pack.pack_icon, Color.Transparent);
                        item.SubItems.Add(pack.description);
                        item.SubItems.Add(string.Join(", ", pack.version));
                        item.Tag = pack;
                        inactiveListView.Items.Add(item);
                        Logger.Log("Pack: " + pack.name + " was added to " + inactiveListView.Name);
                    }
                }
            }
            inactiveListView.EndUpdate(); //Enable the control to redraw
        }
        public void ActiveListPopulate()
        {
            var imageList = new ImageList();
            imageList.ImageSize = new Size(32, 32);
            activeListView.SmallImageList = imageList;

            activeListView.BeginUpdate();
            foreach (var pack in activeList)
            {
                ListViewItem item = new ListViewItem(pack.name);
                item.ImageIndex = imageList.Images.Add(pack.pack_icon, Color.Transparent);
                item.SubItems.Add(pack.description);
                item.SubItems.Add(string.Join(", ", pack.version));
                item.Tag = pack;
                activeListView.Items.Add(item);
                Logger.Log("Pack: " + pack.name + " was added to " + activeListView.Name);
            }
            activeListView.EndUpdate();
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
        public void HandleMouseClick(object sender, MouseEventArgs e, Action<ListViewItem> openFolderAction, Action<ListViewItem> deletePackAction)
        {
            if (e.Button == MouseButtons.Right)
            {
                // Cast the 'sender' object to a ListView type to access ListView-specific properties
                ListView listView = sender as ListView; 
                var focusedItem = listView.FocusedItem;
                // Check if the focused item is not null and the mouse click occurred within its bounds
                if (focusedItem != null && focusedItem.Bounds.Contains(e.Location)) 
                {
                    ContextMenuStrip menu = new ContextMenuStrip();
                    menu.Items.Add("Open pack files", null, (sender, args) => openFolderAction(focusedItem));
                    menu.Items.Add("Delete pack", null, (sender, args) => deletePackAction(focusedItem));
                    menu.Show(listView, e.Location);
                }
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
            DialogResult result = MessageBox.Show("Are you sure you want to delete this pack? This action cannot be undone.", "Warning", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
            if (result == DialogResult.Yes)
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
                Logger.Log("Pack: " + pack.name + "was deleted from the disk!");
            }
        }
    }
}
