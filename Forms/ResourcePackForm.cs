using System.Data;

namespace AddonManager.Forms
{
    public partial class ResourcePackForm : Form
    {
        public ResourcePackForm()
        {
            InitializeComponent();
            this.Text = "SELECT RESOURCE PACKS"; //Header title
            InactiveListPopulate();
            ActiveListPopulate();
        }
        private bool IsExcludedPack(string packName)
        {
            string[] excludedPrefixes = { "resourcePack.education", "resourcePack.vanilla", "experimental" };

            foreach (var prefix in excludedPrefixes)
            {
                if (packName.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
                {
                    return true; //Exclude this pack
                }
            }
            return false; //Include this pack
        }
        private void InactiveListPopulate()
        {
            rpInactiveListView.BeginUpdate(); //Prevent the control from drawing until the EndUpdate method is called. Used mainly for large lists
            foreach (var pack in ResultLists.inactiveRpList)
            {
                // Check if the checkbox is checked or if the pack name is not excluded
                if (!Program.hideDefaultPacks || !IsExcludedPack(pack.name))
                {
                    ListViewItem item = new ListViewItem(pack.name);
                    item.SubItems.Add(pack.description);
                    item.SubItems.Add(pack.pack_folder);
                    item.Tag = pack;
                    rpInactiveListView.Items.Add(item);
                }
            }
            rpInactiveListView.EndUpdate(); //Enable the control to redraw
        }
        private void ActiveListPopulate()
        {
            rpActiveListView.BeginUpdate();
            foreach (var pack in ResultLists.activeRpList)
            {
                ListViewItem item = new ListViewItem(pack.name);
                item.SubItems.Add(pack.description);
                item.Tag = pack;
                rpActiveListView.Items.Add(item);
            }
            rpActiveListView.EndUpdate();
        }
        private void MoveSelectedItems(System.Windows.Forms.ListView source, System.Windows.Forms.ListView destination, List<ManifestInfo> sourceList, List<ManifestInfo> destinationList)
        {
            var itemsToMove = source.SelectedItems.Cast<ListViewItem>().ToList(); //Get the selected items to move
            foreach (ListViewItem item in itemsToMove) //Iterate through the selected items
            {
                var pack = (ManifestInfo)item.Tag; //Retrieve the full data object from the Tag property
                sourceList.Remove(pack); //Remove the pack from the source list
                destinationList.Add(pack); //Add the pack to the destination list

                source.Items.Remove(item); //Remove the item from the source list view
                destination.Items.Add(item); //Add the item to the destination list view
            }
        }
        private void moveToInactiveButton_Click(object sender, EventArgs e)
        {
            MoveSelectedItems(rpActiveListView, rpInactiveListView, ResultLists.activeRpList, ResultLists.inactiveRpList); //Move items from the active to the inactive list
        }
        private void moveToActiveButton_Click(object sender, EventArgs e)
        {
            MoveSelectedItems(rpInactiveListView, rpActiveListView, ResultLists.inactiveRpList, ResultLists.activeRpList); //Move items from the inactive to the active list
        }
        private void moveUpButton_Click(object sender, EventArgs e)
        {
            if (rpActiveListView.SelectedItems.Count > 0)
            {
                var selectedItem = rpActiveListView.SelectedItems[0];
                int index = selectedItem.Index;
                if (index > 0)
                {
                    rpActiveListView.Items.Remove(selectedItem);
                    rpActiveListView.Items.Insert(index - 1, selectedItem);
                    ResultLists.activeRpList.Move(index, index - 1);
                }
            }
        }
        private void moveDownButton_Click(object sender, EventArgs e)
        {
            if (rpActiveListView.SelectedItems.Count > 0)
            {
                var selectedItem = rpActiveListView.SelectedItems[0];
                int index = selectedItem.Index;
                if (index < rpActiveListView.Items.Count - 1)
                {
                    rpActiveListView.Items.Remove(selectedItem);
                    rpActiveListView.Items.Insert(index + 1, selectedItem);
                    ResultLists.activeRpList.Move(index, index + 1);
                }
            }
        }
        private void ListView_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Right)
            {
                ListView listView = sender as ListView;         //Cast the 'sender' object to a ListView type to access ListView-specific properties.
                var focusedItem = listView.FocusedItem;
                if (focusedItem != null && focusedItem.Bounds.Contains(e.Location))  //Check if the focused item is not null and the mouse click occurred within its bounds.
                {
                    ContextMenuStrip menu = new ContextMenuStrip();
                    menu.Items.Add("Open pack files", null, (sender, args) => openFolderOption_Click(focusedItem));
                    menu.Items.Add("Delete pack", null, (sender, args) => deletePackOption_Click(focusedItem));
                    menu.Show(listView, e.Location);
                }
            }
        }
        private void openFolderOption_Click(ListViewItem item) //Opens file explorer to selected pack folder
        {
            var pack = (ManifestInfo)item.Tag;
            string folderPath = pack.pack_folder;
            if (!string.IsNullOrEmpty(folderPath))
            {
                System.Diagnostics.Process.Start("explorer.exe", folderPath);
            }
        }
        private void deletePackOption_Click(ListViewItem item) //Deletes selected pack
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
                        Directory.Delete(folderPath, true); //Attempt to delete the pack folder                     
                        item.Remove(); //Remove the item from the ListView
                      
                        if (ResultLists.inactiveRpList.Contains(pack)) //Remove the pack from the corresponding list
                        {
                            ResultLists.inactiveRpList.Remove(pack);
                        }
                        else if (ResultLists.activeRpList.Contains(pack))
                        {
                            ResultLists.activeRpList.Remove(pack);
                        }
                    }
                    catch (IOException ioEx)
                    {
                        MessageBox.Show($"An error occurred while trying to delete the folder: {ioEx.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                    catch (UnauthorizedAccessException unAuthEx)
                    {
                        MessageBox.Show($"You do not have permission to delete this folder: {unAuthEx.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
                else
                {
                    MessageBox.Show("The directory does not exist.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }
    }
}
    

